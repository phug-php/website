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
vous recommandons d'utiliser l'option [paths](#paths-array) à la place.
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
passant l'option [up_to_date_check](#up_to_date_check-boolean)
à `false`.

## Langage

### paths `array`

Spécifie la liste des chemins à utiliser pour `include` et
`extend` avec des chemins absoluts. Exemple :
```php
Phug::setOption('paths', [
  __DIR__.'/paquet',
  __DIR__.'/ressources/vues',
]);

Phug::render('include /dossier/fichier.pug');
```

Comme `/dossier/fichier.pug` commence par un slash, il est considéré
comme un chemin absolut. Phug va d'abord essayer de le trouver
dans le premier dossier : `__DIR__.'/paquet'`, s'il n'existe pas,
il passe au dossier suivant :
`__DIR__.'/ressources/vues'`.

### extensions `array`

Liste des extensions de ficheir que Phug va considérer comme fichier
pug.
`['', '.pug', '.jade']` par défaut.

Ce qui signifie :
```pug
//- mon-fichier.pug
p Truc
```
```js
// fichier-non-pug.js
alert('truc');
```

```pug
//- index.pug
//-
  mon-fichier.pug peut être importé (include or extend)
  avec ou sans extension, et son contenu sera parsé
  en tant que contenu pug.
  (ce n'est pas testable dans cet éditeur car les
  includes sont émulées)
include mon-fichier.pug
//- include mon-fichier
//-
  fichier-non-pug.js va être inclus en texte brut
include fichier-non-pug.js
```


Donc l'option `extensions` vous permet de passer une autre
liste d'extensions que Phug gèrera et ajoutera automatiquement
lorsqu'elles manquent au chemin d'un import (include/extend).

### default_doctype `string`

Le doctype à utiliser s'il n'est pas spécifié en argument.
`"html"` par défaut.

Ce qui signifie :
```phug
doctype
//- va automatiquement se transformer en :
doctype html
```

### default_tag `string`

Par défaut, quand vous ne spécifiez pas de balise, **Phug**
va générer une balise `div` :
```phug
.truc
#machin(a="b")
(c="d") Salut
```
Le même code avec `Phug::setOption('default_tag', 'section')`
va générer :
```html
<section class="truc"></section>
<section id="machin" a="b"></section>
<section c="d">Salut</section>
```

### attributes_mapping `array`

Cette option vous permet de remplacer des attributs par
d'autres :
```php
Phug::setOption('attributes_mapping', [
  'foo' => 'bar',
  'bar' => 'foo',
  'biz' => 'zut',
]);
Phug::display('p(foo="1" bar="2" biz="3" zut="4" hop="5")');
```
Va afficher :
```html
<p bar="1" foo="2" zut="3" zut="4" hop="5"></p>
```

## Profiling

**Phug** embarque un module de profiling pour surveiller,
deboguer ou limiter la consommation de mémoire et le temps
d'exécution.

### memory_limit `integer`

Fixe une limite mémoire. `-1` par défaut signifie
*pas de limite*. Mais si l'option [debug](#debug-boolean)
vaut `true`, elle passe automatiquement à
`50*1024*1024` (50Mo).

Si le profiler détecte une utilisation de mémoire
supérieure à la limite, il va jeter une exception.
Mais soyez conscient que si la limite est supérieure
à la limite de la machine ou de PHP, la limite de
Phug n'aura aucun effet. 

### execution_max_time `integer`

Fixe une limite du temps d'exécution. `-1`
par défaut signifie *pas de limite*. Mais si
l'option [debug](#debug-boolean) vaut `true`,
elle passe automatiquement à
`30*1000` (30 secondes).

Si le profiler détecte que Phug tourne depuis plus
de temps que la limite autorisée, il va jeter
une exception. Mais soyez conscient que si la
limite de PHP est inférieure, celle de Phug
n'aura aucun effet. 

### enable_profiler `boolean`

Quand cette option est réglée à `true`, Phug va générer
une frise temporelle que vous pourrez consulter dans
votre navigateur pour voir quel token/node prend le
plus de temps à être parsé, compilé, rendu.

Quand c'est activé, un sous-set d'options supplémentaire
est disponible, voici leurs valeurs par défaut :
```php
'profiler' => [
    'time_precision' => 3,     // précision décimale des chronos
    'line_height'    => 30,    // hauteur/ligne de la frise
    'display'        => true,  // affiche le résultat
                               // (true ou false)
    'log'            => false, // enregistre le résultat dans un fichier
                               // (le chemin du ficheir ou false)
],
```

## Erreurs

### error_handler `callable`

Règle un callback to gérer les exceptions Phug.
`null` par défaut.

### html_error `boolean`

Affiche les erreurs en HTML (`false` par défaut si Phug
est exécuté en CLI, `true` s'il est exécuté via un
navigateur).

### color_support `boolean`

Permet d'activer la couleur dans la sortie en ligne de
commande (pour les erreurs notamment), par défaut
nous essayons de détecter si la console utilisée
supporte la couleur.

### error_context_lines `integer`

Nous donnons du contexte en affichant le code source
lié à une erreur `7` lignes au dessus et en dessous
de la ligne d'erreur par défaut. Mais vous pouvez
passez n'importe quel nombre à cette option pour
avoir plus ou moins de contexte.
