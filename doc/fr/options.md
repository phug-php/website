# Options

## Équivalents pour les options pugjs

### filename `string`

Le nom du fichier en cours de compilation. Cette option est utilisée pour
la résolution des chemins et le fichier mentionné en détail des erreurs :

```php
Phug::compile("\n  indentation\ncassée");
```

Par défaut, quand vous faites `compile`, `render` ou `display` (en passant
donc du code en argument),
**Phug** ne donne aucune information sur le nom du fichier dans les
exceptions et ne peut pas résoudre les chemins relatifs pour include/extend.

```yaml
Failed to parse: Failed to outdent: No parent to outdent to. Seems the parser moved out too many levels.
Near: indent

Line: 3
Offset: 1 
```

Avec l'option **filename**, un chemin est fournit :

```php
Phug::setOption('filename', 'machin-chose.pug');
Phug::compile("\n  indentation\ncassée");
```
```yaml
...
Line: 3
Offset: 1
Path: machin-chose.pug
```

Mais, cette option est ignorée si vous spécifiez localement
le *filename* :

```php
Phug::setOption('filename', 'machin-chose.pug');
Phug::compile("\n  indentation\ncassée", 'quelque-chose.pug');
```
```yaml
...
Line: 3
Offset: 1
Path: quelque-chose.pug 
```

Il en va de même pour `compileFile`, `renderFile` et `displayFile`:

```php
Phug::displayFile('quelque-chose.pug');
```
```yaml
...
Line: 3
Offset: 1
Path: quelque-chose.pug 
```

### basedir `string`

Le dossier racine pour les imports par chemin absolu. Cette option
est supportée pour raison de compatibilité avec pugjs, mais nous
vous recommandons d'utiliser l'option [paths](#paths) à la place.
Elle a le même objectif mais vous permet de passer un array de
dossiers qui vont tous être essayés (dans l'ordre dans lesquels
vous les passez) pour résoudre les chemins absolus lors des
`include`/`extend` et le premier trouvé est utilisé.

### doctype `string`

Si le `doctype` n'est pas spécifié dans le template, vous pouvez
le spécifier via cette option. C'est parfois utile pour avoir
les balises auto-fermantes et supprimer les valeurs en miroir
des attributs booléens. Voir
[la documentation de doctype](#doctype-option)
pour plus d'informations.

### pretty `boolean | string`

[Déprécié.] Ajoute des espaces blancs  dans le HTML pour le
rendre plus facile à lire pour un humain en utilisant `'  '`
comme indentation. Si une chapine de caractères est passée
à cette option, elle sera utilisée à la place comme indentation
(par exemple `'\t'`). Nous vous mettons en garde contre cette
option. Trop souvent, elle crée de subtiles problèmes dans
les rendus à cause de la manière dont elle altère le
rendu, et donc cette fonctionnalité sera prochainement
supprimée. Elle est réglée par défaut sur `false`.

### filters `array`

Array associatif de filtres personnalisé. `[]` par défaut.
```php
Phug::setOption('filters', [
  'mon-filtre' => function ($texte) {
    return strtoupper($texte);
  },
]);
Phug::render("div\n  :mon-filtre\n    Mon texte");
```
Retourne :
```html
<div>MON TEXTE</div>
```

Vous pouvez aussi utiliser la méthode `setFilter` et votre
callback peut prendre des options :

```php
Phug::setFilter('ajoute', function ($texte, $options) {
  return $texte + $options['valeur'];
});
Phug::render("div\n  :ajoute(valeur=4) 5");
```
Retourne :
```html
<div>9</div>
```

Et notez que vous pouvez utiliser des classes invocables
(classes qui ont une méthode `__invoke`) au lieu d'une
simple fonction de callback pour vos filtres personnalisés.

### self `boolean | string`

Utilise un espace de noms `self` pour contenir les variables.
Au lieu d'écrire `variable` you devrez donc écrire
`self.variable` pour accéder à une variable. `false` par
défaut.

```php
Phug::setOption('self', true);
Phug::display('p=self.message', [
    'message' => 'Salut',
]);
```
Affichera :
```html
<p>Salut</p>
```

Et vous pouvez passer n'importe quelle chaine de caractères
tant qu'elle reste un nom de variable valid, donc le code
suivant est équivalent :
```php
Phug::setOption('self', 'banane');
Phug::render('p=banane.message', [
    'message' => 'Salut',
]);
```

### debug `boolean`

Si cette option vaut `true`, quand une erreur arrive durant
le rendu, vous aurez sa trace complète, ce qui inclut la
ligne et colonne dans le fichier source pug.

En production, vous devriez la régler sur `false` pour
accélérer le rendu et cacher les informations de débogage.
C'est fait automatiquement si vous utiliser un adapteur pour
framework comme
[pug-symfony](https://github.com/pug-php/pug-symfony) ou
[laravel-pug](https://github.com/BKWLD/laravel-pug).

### shared_variables / globals `array`

Liste de variables stockée globalement pour être disponible
pour tout appel ultérieur à `render`, `renderFile`, `display`
ou `displayFile`.

`globals` et `shared_variables` sont deux options différentes
fusionnées ensemble, `globals` n'existe que pour fournir un
équivalent à l'option pugjs du même nom. Et des méthodes
comme `->share` et `->resetSharedVariables` impactent
seulement l'option `shared_variables`, donc nous vous
recommandons d'utiliser `shared_variables`.

```php
Phug::setOptions([
    'globals' => [
        'haut' => 1,
        'droite' => 1,
        'bas' => 1,
        'gauche' => 1,
    ],
    'shared_variables' => [
        'droite' => 2,
        'bas' => 2,
        'gauche' => 2,
    ],
]);

Phug::share([
    'bas' => 3,
    'gauche' => 3,
]);

Phug::display('="$haut, $droite, $bas, $gauche"', [
    'gauche' => 4,
]);

Phug::resetSharedVariables();

Phug::display('="$haut, $droite, $bas, $gauche"', [
    'gauche' => 5,
]);
```

Le premier `display` va afficher :
```
1, 2, 3, 4
```

Le second `display` va afficher :
```
1, 1, 1, 5
```

Comme vous pouvez le constater dans cet exemple, les
variables locales ont toujours la précédence et
`shared_variables` a la précédence sur `globals`.

Le même code ressemblerait à ça en utilisant
**pug-php** :

```php
$pug = new Pug([
    'globals' => [
        'haut' => 1,
        'droite' => 1,
        'bas' => 1,
        'gauche' => 1,
    ],
    'shared_variables' => [
        'droite' => 2,
        'bas' => 2,
        'gauche' => 2,
    ],
]);

// ou $pug->setOptions([...])

$pug->share([
    'bas' => 3,
    'gauche' => 3,
]);

$pug->display('=haut + ", " + droite + ", " + bas + ", " + gauche', [
    'gauche' => 4,
]);

$pug->resetSharedVariables();

$pug->display('=haut + ", " + droite + ", " + bas + ", " + gauche', [
    'gauche' => 5,
]);
```

### cache_dir `boolean | string`

Si réglée sur `true`, les templates compilés seront mis en
cache. L'option `filename` est alors nécessaire pour déterminer
la clé de cache (ce qui est fait automatiquement en utilisant
`renderFile` ou `displayFile`). `false` par défaut.

Cette option peut aussi prendre une valeur `string` qui sera
alors utilisée comme chemin du dossier où les fichiers de
cache seront stockés.

[pug-symfony](https://github.com/pug-php/pug-symfony) et
[laravel-pug](https://github.com/BKWLD/laravel-pug) gèrent
automatiquement cette option. Si vous utilisez l'un ou
l'autre, vous n'avez pas à vous en soucier.

**pug-php** fournit aussi un alias `cache` pour cette
option pour correspondre à **pug-php** 2 et **pugjs**.
Cela permet aussi une meilleure sémantique lorsque
vous passez à cette option une valeur booléenne, alors
que `cache_dir` reste plus appropriée quand vous passez
une chaîne.

Vous pouvez aussi utiliser
[la commande compile-directory](#compile-directory-or-cache-directory)
pour mettre en cache un dossier complet.

Nous vous conseillons d'utiliser cette commande au
déploiement de vos applications en production, vous
pouvez alors optimiser les performances du cache en
passant l'option [up_to_date_check](#up_to_date_check)
à `false`.