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

Note: le doctype XML peut causer des bugs quand les *open short
tags* sont activés, c'est pourquoi par défaut, nous remplaçons
`<?xml` par `<<?= "?" ?>xml` quand `short_open_tag` ou
`hhvm.enable_short_tags` est `On`
(c'est le comportement lorsque l'option `short_open_tag_fix`
est réglée sur sa valeur par défaut : `"auto"`) mais vous pouvez
régler cette option à `true` (pour toujours activer lke correctif)
ou `false` (pour toujours le désactiver).

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

## Événements

Les événements sont un moyen très puissant d'intercepter
différentes étapes du processus pour récupérer, modifier
ou manipuler des objets et paramètres.

Exemple:
```php
$renderer = new \Phug\Renderer([
    'on_render' => function (\Phug\Renderer\Event\RenderEvent $event) {
        // Get new parameters
        $parameters = $event->getParameters();
        // If you pass laurel in your parameters
        if (isset($parameters['laurel'])) {
            // Then you will need hardy
            $parameters['hardy'] = 'Scandale à Hollywood';
        }

        // Set new parameters
        $event->setParameters($parameters);
    },
]);

$renderer->display('p=$hardy', [
    'laurel' => true,
]);
```
Affichera :
```html
<p>Scandale à Hollywood</p>
```

The same works with **pug-php**:
```php
$renderer = new Pug([
    'on_render' => function (\Phug\Renderer\Event\RenderEvent $event) {
        // Récupération des paramètres actuels
        $parametres = $event->getParameters();
        // Si vous avez passé laurel en paramètre
        if (isset($parametres['laurel'])) {
            // Alors vous aurez aussi besoin de hardy
            $parametres['hardy'] = '45 Minutes from Hollywood';
        }

        // Applique les nouveaux paramètres
        $event->setParameters($parametres);
    },
]);

$renderer->display('p=hardy', [
    'laurel' => true,
]);
```

Notez que toutes les options en **on_&#42;** sont des options
initiales, ce qui signifie que vous ne pouvez pas les appliquer
après l'initialisation du *renderer* ou en utilisant les façades
(`Phug::setOption()` ou `Pug\Facade::setOption()`).

Cependant, vous pouvez attacher/détacher des événements de la
manière suivante (en utilisant ou non les façades) :
```php
function ajouteHardy(\Phug\Renderer\Event\RenderEvent $event) {
    // Récupération des paramètres actuels
    $parametres = $event->getParameters();
    // Si vous avez passé laurel en paramètre
    if (isset($parametres['laurel'])) {
        // Alors vous aurez aussi besoin de hardy
        $parametres['hardy'] = '45 Minutes from Hollywood';
    }

    // Applique les nouveaux paramètres
    $event->setParameters($parametres);
}

Phug::attach(\Phug\RendererEvent::RENDER, 'ajouteHardy');

Phug::display('p=$hardy', [
    'laurel' => true,
]);

Phug::detach(\Phug\RendererEvent::RENDER, 'ajouteHardy');

Phug::display('p=$hardy', [
    'laurel' => true,
]);
```

Affichera `<p>Scandale à Hollywood</p>` puis `<p></p>`.

Donc pour toutes les options **on_&#42;** ci-dessous, nous
vous donnerons le nom de l'option initiale, la constante
d'événement (pour utiliser avec `attach`/`detach`)
et la classe de l'événement avec un lien vers la documentation
API qui vous donne toutes les méthodes disponibles sur cet
événement (toutes les valeurs que vous pouvez récupérer et
modifier).

Avant de lister tous les événements, voici une vue d'ensemble
de la chronologie des processus :
![Chronologie des processus Phug](/img/pug-processes.png)
Les lignes continues sont les processus actifs, les pointillés
sont les processus en attente d'un autre processus.

Vous pouvez donc voir que le rendu commence avant les autres
événements bien que le processus actif du rendu ne démarre
que lorsque les autres processus sont terminés.

Il en va de même pour la compilation qui attend d'abord
que le *parser* lui donne l'arbre complet des nœuds avant
de démarrer la "vraie" compilation (c-à-d. la transformation
des nœuds en éléments), puis elle va attendre le processus
de formattage avant d'appeler l'événement *output*.

Les étapes de *parsing*, *lexing* et *reading* sont des
processus parallèles, le lecteur (*reader*) identifie des
morceaux de texte, par exemple 2 espaces en début de ligne,
le *lexer* convertit la chaîne en *token*, puis le *parser*
sait alors qu'il doit indenter un niveau et ajouter ensuite
les nœuds suivants en tant qu'enfants du nœud du dessus.
Cet enchaînement est ensuite répété *token* par *token*
jusqu'à ce que toute la source soit consommée.

### on_render `callable`

Est déclenché avant qu'un fichier ou une chaîne soit rendu ou
affiché.

Dans certains cas vous pourriez hésiter entre **on_render** et
**on_compile**, vous devriez peut-être consulter
[l'option on_compile](#on-compile-callable).

Constante d'événement : `\Phug\RendererEvent::RENDER`

Type d'événement : [`\Phug\Renderer\Event\RenderEvent`](https://phug-lang.com/api/classes/Phug.Renderer.Event.RenderEvent.html#method___construct)

Paramètres utilisables/modifiables :
- input: code source si `render`/`display` a été appelé
- path: fichier source si `renderFile`/`displayFile` a été appelé
- method: la méthode qui a été appelée `"render"`, `"display"`,
`"renderFile"` ou `"displayFile"`.
- parameters: variables locales passée pour le rendu de la vue

### on_html `callable`

Est déclenché après qu'un fichier ou une chaîne soit rendu ou
affiché.

Constante d'événement : `\Phug\RendererEvent::HTML`

Type d'événement : [`\Phug\Renderer\Event\HtmlEvent`](https://phug-lang.com/api/classes/Phug.Renderer.Event.HtmlEvent.html#method___construct)

Paramètres utilisables/modifiables :
- renderEvent: lien vers le RenderEvent initial (voir
ci-dessus)
- result: résultat retourné (par `render` ou `renderFile`)
- buffer: tampon de sortie (ce que `display` ou `displayFile`
est sur le point d'afficher) généralement le code HTML, mais
ce peut être aussi du XML ou n'importe quel format personnalisé
- error: l'exception capturée si une erreur s'est produite

### on_compile `callable`

Est déclenché avant qu'un fichier ou une chaîne soit compilé.

Cette option est differente de **on_render** par les aspects
suivants :
- les méthodes `compile()` et `compileFile()` déclenchen un
événement *compile* mais pas d'événement *render*,
- l'événement *compile* est déclenché avant le *render*,
- et les méthodes *render(File)* et *display(File)* vont
toujours déclenché un événement *render* mais ne déclencheront
pas d'événement *compile* si un template compilé est servi
depuis le cache (configuration de cache active et template
à jour).

Le processus de compilation transforme du code pug en code
PHP qui est toujours le même pour un template donné quelles
que soientles valeurs des variables locales, alors que le
processus de rendu exécute ce code PHP pour obtenir du
HTML, XML ou n'importe quelle chaîne finale où les variables
locales sont remplacées par leurs valeurs. C'est pour ça
que l'événement *render* a aussi un paramètres
**parameters** avec les valeurs des variables locales
que vous pouvez récupérer et modifier.

Constante d'événement : `\Phug\CompilerEvent::COMPILE`

Type d'événement : [`\Phug\Compiler\Event\CompileEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.CompileEvent.html#method___construct)

Paramètres utilisables/modifiables :
- input: contenu source de la chaîne/le fichier compilé
- path: chemin du fichier source si
`compileFile`/`renderFile`/`displayFile` a été appelé

### on_output `callable`

Est déclenché après qu'un fichier ou une chaîne soit compilé.

Constante d'événement : `\Phug\CompilerEvent::OUTPUT`

Type d'événement : [`\Phug\Compiler\Event\OutputEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.OutputEvent.html#method___construct)

Paramètres utilisables/modifiables :
- compileEvent: lien vers l'événement CompileEvent initial
(voir ci-dessus)
- output: code PHP généré qui peut être exécuté pour obtenir
le code final

### on_node `callable`

Est déclenché pour chaque nœud avant sa compilation.

Pour bien comprendre ce qu'est un nœud, vous pouvez utiliser
le mode **parse** dans l'éditeur de code, voici un exemple :
```pug
doctype
html
  head
    title=$var
  body
    h1 Texte
    footer
      | Texte
      =date('Y')
```
<i data-options='{"mode":"parse"}'></i>

Vous pouvez voir que le *parser* de **Phug** transforme le
code pug en arbre de nœuds. Puis le *compiler* va compiler
chacun de ces nœuds en éléments récursivement. Et le
*formatter* transformera l'arbre d'éléments en code PHP
compilé.

Constante d'événement : `\Phug\CompilerEvent::NODE`

Type d'événement : [`\Phug\Compiler\Event\NodeEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.CompileEvent.html#method___construct)

Paramètres utilisables/modifiables :
- node: l'instance de nœud qui est sur le point d'être
compilée

### on_element `callable`

Est déclenché pour chaque nœud après sa compilation.

Constante d'événement : `\Phug\CompilerEvent::ELEMENT`

Type d'événement : [`\Phug\Compiler\Event\ElementEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.OutputEvent.html#method___construct)

Paramètres utilisables/modifiables :
- nodeEvent: lien vers l'événement NodeEvent initial
(voir ci-dessus)
- element: l'élément compilé

### on_format `callable`

Est déclenché pour chaque élément avant d'être formatté.

L'étape de formattage est un processus qui prend un arbre
d'éléments (objet représentant la sortie telle que stockée
après compilation, à ne pas confondre avec l'arbre de nœuds
qui représente la source d'entrée et est le résultat du
*parsing* - analyse - avant la compilation) et
convertit ces éléments en code PHP compilé capable
d'effectué le rendu.

Le formattage est récursif, en lui passant un élément,
il formatte aussi les enfants contenus dans cet élément.

#### Avant le processus de formattage
```phug
p=$var
```
<i data-options='{"mode":"compile"}'></i>
#### Après le processus de formattage
```phug
p=$var
```
<i data-options='{"mode":"format"}'></i>

Constante d'événement : `\Phug\FormatterEvent::FORMAT`

Type d'événement : [`\Phug\Formatter\Event\FormatEvent`](https://phug-lang.com/api/classes/Phug.Formatter.Event.FormatEvent.html#method___construct)

Paramètres utilisables/modifiables :
- element: l'élément compilé (implémente ElementInterface)
- format: le format utilisé (implémente FormatInterface)
sera par défaut BasicFormat ou le format pour votre
doctype (par exemple, si vous avez mis `doctype html`) le
format ici sera HtmlFormat (voir les options
[format](#format-string) et
[default_format](#default-format-string))

### on_new_format `callable`

Est déclenché quand le format change (par exemple quand
vous définissez le doctype).

Constante d'événement : `\Phug\FormatterEvent::NEW_FORMAT`

Type d'événement : [`\Phug\Formatter\Event\NewFormatEvent`](https://phug-lang.com/api/classes/Phug.Formatter.Event.NewFormatEvent.html#method___construct)

Paramètres utilisables/modifiables :
- formatter: le *formatter* courant (implémente Formatter)
- format: l'instance du nouveau format (implémente
FormatInterface)

### on_dependency_storage `callable`

Est déclenché quand une dépendance est extraire du *dependency
storage*.

Le registre des dépendances *dependency storage* est utilisé
pour stocker les fonctions utiles lors du rendu et les intégrer
aux code PHP compilé, c'est utilisé par exemple dans les
assignements :

```phug
p&attributes(['machin' => 'true'])
```
<i data-options='{"mode":"format"}'></i>

Ces méthodes sont stockées par défaut dans `$pugModule` (voir
l'option [dependencies_storage](#dependencies-storage-string)
pour le changer).

Constante d'événement : `\Phug\FormatterEvent::DEPENDENCY_STORAGE`

Type d'événement : [`\Phug\Formatter\Event\DependencyStorageEvent`](https://phug-lang.com/api/classes/Phug.Formatter.Event.DependencyStorageEvent.html#method___construct)

Paramètres utilisables/modifiables :
- dependencyStorage: variable utilisée pour stocker pour stocker
la méthode (par exemple :
`$pugModule['Phug\\Formatter\\Format\\BasicFormat::attributes_assignment']`)

### on_parse `callable`

Est déclenché avant le processus d'analyse (*parsing*).

Constante d'événement : `\Phug\ParserEvent::PARSE`

Type d'événement : [`\Phug\Parser\Event\ParseEvent`](https://phug-lang.com/api/classes/Phug.Parser.Event.ParseEvent.html#method___construct)

Paramètres utilisables/modifiables :
- input: contenu source de la chaîne/le fichier compilé
- path: chemin du fichier source si
`compileFile`/`renderFile`/`displayFile` a été appelé
- stateClassName: nom de la classe de l'objet d'état qui
va être créée pour le *parsing*
- stateOptions: array d'options qui va être passé à la
création de l'état

### on_document `callable`

Est déclenché quand le *parser* a analysé un document en entier
(fin du *parsing*).

Constante d'événement : `\Phug\ParserEvent::DOCUMENT`

Type d'événement : [`\Phug\Parser\Event\NodeEvent`](https://phug-lang.com/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Paramètres utilisables/modifiables :
- node: le document en tant qu'instance de nœud

### on_state_enter `callable`

Est déclenché quand le *parser* entre dans un nœud.

Constante d'événement : `\Phug\ParserEvent::STATE_ENTER`

Type d'événement : [`\Phug\Parser\Event\NodeEvent`](https://phug-lang.com/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Paramètres utilisables/modifiables :
- node: le nœud dans lequel le *parser* est entré

### on_state_leave `callable`

Est déclenché quand le *parser* resort d'un nœud.

Constante d'événement : `\Phug\ParserEvent::STATE_LEAVE`

Type d'événement : [`\Phug\Parser\Event\NodeEvent`](https://phug-lang.com/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Paramètres utilisables/modifiables :
- node: le nœud duquel le *parser* est resorti

### on_state_store `callable`

Est déclenché quand le *parser* enregistre et attache
un nœud à l'arbre du document.

Constante d'événement : `\Phug\ParserEvent::STATE_STORE`

Type d'événement : [`\Phug\Parser\Event\NodeEvent`](https://phug-lang.com/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Paramètres utilisables/modifiables :
- node: le nœud que le *parser* a enregistré

### on_lex `callable`

Est déclenché quand le *lexer* commence à transformer
le code source Pug en *tokens*.

Constante d'événement : `\Phug\LexerEvent::LEX`

Type d'événement : [`\Phug\Lexer\Event\LexEvent`](https://phug-lang.com/api/classes/Phug.Lexer.Event.LexEvent.html#method___construct)

Paramètres utilisables/modifiables :
- input: contenu source de la chaîne/le fichier compilé
- path: chemin du fichier source si
`compileFile`/`renderFile`/`displayFile` a été appelé
- stateClassName: nom de la classe de l'objet d'état qui
va être créée pour le *lexing*
- stateOptions: array d'options qui va être passé à la
création de l'état

### on_lex_end `callable`

Est déclenché quand le *lexer* à terminé de transformer
le code source Pug en *tokens*.

Constante d'événement : `\Phug\LexerEvent::LEX_END`

Type d'événement : [`\Phug\Lexer\Event\EndLexEvent`](https://phug-lang.com/api/classes/Phug.Lexer.Event.EndLexEvent.html#method___construct)

Paramètres utilisables/modifiables :
- lexEvent: lien vers lévénement LexEvent initial

### on_token `callable`

Est déclenché à chaque fois que le *lexer* est sur le point
de retourné un token et de l'envoyer au *parser*.

Constante d'événement : `\Phug\LexerEvent::TOKEN`

Type d'événement : [`\Phug\Lexer\Event\TokenEvent`](https://phug-lang.com/api/classes/Phug.Lexer.Event.TokenEvent.html#method___construct)

Paramètres utilisables/modifiables :
- token: le jeont créé par le *lexer*
- tokenGenerator: `null` par défaut, mais si vous passez
un *iterator* à cette propriété, il remplacera le jeton

Quelques exemples :
```php
$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    $token = $event->getToken();
    if ($token instanceof \Phug\Lexer\Token\TagToken) {
      $token->setName('a');
    }
  },
]);
$renderer->display('div'); // <a></a>

$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    if ($event->getToken() instanceof \Phug\Lexer\Token\TagToken) {
      $text = new \Phug\Lexer\Token\TextToken();
      $text->setValue('Salut');
      $event->setToken($text);
    }
  },
]);
$renderer->display('div'); // Salut

$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    if ($event->getToken() instanceof \Phug\Lexer\Token\TextToken) {
      $event->setTokenGenerator(new \ArrayIterator([
        (new \Phug\Lexer\Token\TagToken())->setName('div'),
        (new \Phug\Lexer\Token\ClassToken())->setName('machin'),
        (new \Phug\Lexer\Token\IdToken())->setName('truc'),
      ]));
    }
  },
]);
$renderer->display('| Salut'); // <div id="truc" class="machin"></div>

function replaceTextToken(\Phug\Lexer\Token\TextToken $token) {
  if (preg_match('/^(\D+)(\d+)$/', $token->getValue(), $match) {
    list(, $chars, $digit) = $match;
    for ($i = 0; $i < $digit; $i++) {
      yield (new \Phug\Lexer\Token\TagToken())->setName($chars);
    }
  }
}

$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    $token = $event->getToken();
    if ($token instanceof \Phug\Lexer\Token\TextToken) {
      $event->setTokenGenerator(replaceTextToken($token));
    }
  },
]);
$renderer->display("|i2\n|bk3"); // <i></i><i></i><bk></bk><bk></bk><bk></bk>
```

## Add-ons

Voici une liste de points d'entrée pour ajouter des contenus
et des comportements personnalisés :

### modules `array`

Les modules peuvent ajouter n'importe quoi en manipulant
les options et les événements. Par exemple si vous utilisez
**Pug-php** avec des options par défaut, vous avez déjà le
[module js-phpize pour Phug](https://github.com/pug-php/js-phpize-phug)
activé. Ce serait équivalent de l'installer avec composer et de
l'ajouter à **Phug** de la manière suivante :

```php
$renderer = new \Phug\Renderer([
    'modules' => [
        \JsPhpize\JsPhpizePhug::class,
    ],
]);

$renderer->display('p=nom.substr(0, 3)', [
    'nom' => 'Bobby',
]);
```

Ce code affiche `<p>Bob</p>` mais il échouerait
sans le module ajouté car les expressions JS
ne sont pas gérées nativement.

Vous pouvez aussi créer vos propres modules en héritant
(*extend*) l'une des classes suivantes :
- [`\Phug\AbstractRendererModule`](https://phug-lang.com/api/classes/Phug.AbstractRendererModule.html)
- [`\Phug\AbstractCompilerModule`](https://phug-lang.com/api/classes/Phug.AbstractCompilerModule.html)
- [`\Phug\AbstractFormatterModule`](https://phug-lang.com/api/classes/Phug.AbstractFormatterModule.html)
- [`\Phug\AbstractParserModule`](https://phug-lang.com/api/classes/Phug.AbstractParserModule.html)
- [`\Phug\AbstractLexerModule`](https://phug-lang.com/api/classes/Phug.AbstractLexerModule.html)

Elles étendent toutes
[la classe `\Phug\Util\AbstractModule`](https://phug-lang.com/api/classes/Phug.Util.AbstractModule.html)

Voici un exemple :

```php
class MyModule extends \Phug\AbstractCompilerModule
{
    public function __construct(\Phug\Util\ModuleContainerInterface $container)
    {
        // Ici vous pouvez changer des options
        $container->setOption('default_tag', 'p');

        parent::__construct($container);
    }

    public function getEventListeners()
    {
        // Ici vous pouvez attacher des événements
        return [
            \Phug\CompilerEvent::NODE => function (\Phug\Compiler\Event\NodeEvent $event) {
                // Faire quelque chose avant de compiler un nœud
                $node = $event->getNode();
                if ($node instanceof \Phug\Parser\Node\MixinNode) {
                    $tag = new \Phug\Parser\Node\ElementNode(
                        $event->getNode()->getToken()
                    );
                    $attribute = new \Phug\Parser\Node\AttributeNode();
                    $attribute->setName('mixin');
                    $attribute->setValue('"'.$node->getName().'"');
                    $tag->getAttributes()->attach($attribute);
                    $event->setNode($tag);
                }
            },
        ];
    }
}

$renderer = new \Phug\Renderer([
    'modules' => [
        MyModule::class,
    ],
]);

$renderer->display('mixin foo()');
```

Ce qui affichera :
```html
<p mixin="foo"></p>
```

Les modules sont délégués au
renderer/compiler/formatter/parser/lexer
selon l'interface implémentée (ou la classe abstraite
héritée).

Mais vous pouvez spécifier explicitement la cible
avec les options suivantes :

### compiler_modules `array` 

Modules réservés au compiler (voir [modules](#modules-array)).

### formatter_modules `array` 

Modules réservés au formatter (voir [modules](#modules-array)).

### parser_modules `array` 

Modules réservés au parser (voir [modules](#modules-array)).

### lexer_modules `array` 

Modules réservés au lexer (voir [modules](#modules-array)).
