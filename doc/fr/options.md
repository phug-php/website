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
passant l'option [up_to_date_check](#up-to-date-check-boolean)
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

Type d'événement : [`\Phug\Compiler\Event\NodeEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.NodeEvent.html#method___construct)

Paramètres utilisables/modifiables :
- node: l'instance de nœud qui est sur le point d'être
compilée

### on_element `callable`

Est déclenché pour chaque nœud après sa compilation.

Constante d'événement : `\Phug\CompilerEvent::ELEMENT`

Type d'événement : [`\Phug\Compiler\Event\ElementEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.ElementEvent.html#method___construct)

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

### includes `array`

Inclut simplement des fichiers pug avant toute compilation :

```php
// On ajoute aux includes existantes pour ne pas les écraser s'il y en a
Phug::setOption('includes', Phug::getOption('includes') + [
    'mixins.pug',
]);

Phug::display('+truc()');
```

Si le fichier `mixins.pug` contient une déclaration de mixin
**truc** ce code va correctement l'appeler.

C'est un bon moyen de rendre une librairie de mixins
disponible dans n'importe quel template.

### filter_resolvers `array`

Ajoute un moyen dynamique de résoudre un filtre par son nom
lorsqu'il n'existe pas déjà.

```php
Phug::setOption('filter_resolvers', Phug::getOption('filter_resolvers') + [
    function ($nom) {
        if (mb_substr($nom, 0, 3) === 'go-') {
            return function ($contenu) use ($nom) {
                return '<a href="'.mb_substr($nom, 3).'">'.$contenu.'</a>';
            };
        }
    },
]);

Phug::display(':go-page');
// <a href="page"></a>
Phug::display(':go-action Action');
// <a href="action">Action</a>
```

Le *resolver* est utilisé seulement si le nom de filtre
donné n'existe pas au que les précédents *resolvers* n'ont
rien retourné. Si aucun *resolver* ne retourne rien, une
erreur *Unknown filter* est lancée.

### keywords `array`

Vous permet de créer vos propre mot-clé de language :

```php
Phug::setOption('keywords', Phug::getOption('keywords') + [
    'monMotCle' => function ($valeur, \Phug\Formatter\Element\KeywordElement $element, $nom) {
        $enfants = isset($element->nodes) ? count($element->nodes) : 0;

        return "C'est un mot-clé $nom avec la valeur $valeur et $enfants enfants.";
    },
]);


Phug::display('
div
  monMotCle maValeur
    span 1
    span 2
');
```

Affiche :
```html
<div>C'est un mot-clé monMotCle avec la valeur maValeur et 2 enfants.</div>
```

Quand le *callback* du mot-clé retourne une *string*, elle remplace le
mot-clé entier avec ses enfants.

Mais vous pouvez aussi retourner un array avec *begin* et *end* qui va
préserver les nœuds enfants :

```php
Phug::setOption('keywords', Phug::getOption('keywords') + [
    'monMotCle' => function ($valeur) {
        return [
            'begin' => '<div class="'.$valeur.'">',
            'end'   => '</div>',
        ];
    },
]);


Phug::display('
monMotCle maValeur
  span 1
  span 2
');
```

Affiche :
```html
<div class="maValeur">
  <span>1</span>
  <span>2</span>
</div>
```

Ou vous pouvez spécifier un array avec *beginPhp* et *endPhp*
pour entourer les enfants d'une chaîne de début et de fin
toute deux elles-mêmes entourées de `<?php ?>`.

```php
Phug::setOption('keywords', Phug::getOption('keywords') + [
    'repete' => function ($compte) {
        return [
            'beginPhp' => 'for ($i = 0; $i < '.$compte.'; $i++) {',
            'endPhp'   => '}',
        ];
    },
]);


Phug::display('
repete 3
  section
');
```

Affiche :
```html
<section></section>
<section></section>
<section></section>
```

### php_token_handlers `array`

Ce paramètre vous permet d'intercepter
[n'importe quel token PHP](http://php.net/manual/fr/tokens.php)
et de le remplacer par un autre code PHP.
Cela fonctionne aussi avec les expressions à
l'intérieur des boucles `each`, des conditions
`if`, etc. et même si les expressions proviennent
d'une transformation. Par exemple si vous
[utilisez **js-phpize**](#utiliser-des-expressions-javascript)
et écrivez `a(href=route('profil', {id: 3}))`, alors
`{id: 3}` est convertit en `array('id' => 3)` et
le jeton (*token*) `array(` peut être intercepté avec l'identifiant
PHP `T_ARRAY`.

```php
Phug::setOption('php_token_handlers', [
    T_DNUMBER => 'round(%s)',
]);

Phug::display('
- $nombreDecimal = 9.54
- $texte = "9.45"
strong=$nombreDecimal
| !=
strong=$texte
');

```

Affiche :
```html
<strong>10</strong>!=<strong>9.45</strong>
```

Si vous passez une chaîne de caractères,
[`sprintf`](http://php.net/manual/fr/function.sprintf.php)
est utilisé pour la gérée, donc si la chaîne contient
`%s`, ce sera remplacé par la chaîne d'entrée du *token*.

Vous pouvez aussi utiliser une fonction *callback* :
```php
Phug::setOption('php_token_handlers', [
    '(' => function ($tokenString, $index, $tokens, $checked, $formatInstance) {
        return '__appelle_quelque_chose('.mt_rand(0, 4).', ';
    },
]);

echo Phug::compile('b=($variable)');
```

Ceci va appeler la fonction de calback pour chaque *token*
`(` trouvé dans l'expression et le remplacer par le résultat
retourné par la function (par exemple `__appelle_quelque_chose(2, `).

La fonction de callback reçoit 5 arguments :
- `$tokenString` le *token* d'entrée en tant que `string`;
- `$index` la position du *token* dans l'expression;
- `&$tokens` un array avec tous les *tokens* de l'expression,
passé par référence, ce qui veut dire que vous pouvez
modifier/ajouter/supprimer des *tokens* (ne fonctionne que
pour les *tokens* qui viennent après le *token* actuel);
- `$checked` vaut `true` si l'expression est vérifiée (`=exp()`
est vérifiée, `?=exp()` ne l'est pas);
- `$formatInstance` l'instance qui formatte l'expression
courante (implémente FormatInterface).

Soyez prudent, nous utilisons `php_token_handlers` pour gérer
les expressions vérifiées. Ce qui veut dire que si vous remplacez
la gestion du *token* PHP `T_VARIABLE` par votre propre traitement
comme dans l'exemple ci-dessous :

```php
Phug::setOption('php_token_handlers', [
    T_VARIABLE => function ($variable) {
        if (mb_substr($variable, 0, 5) === '$env_') {
            return '$_'.strtoupper(mb_substr($variable, 5));
        }

        return $variable;
    },
]);

Phug::display('
b=$variableNormale
i=$env_super["METHODE"]
', [
    'variableNormale' => 'machin',
    '_SUPER' => [
        'METHODE' => 'truc',
    ],
]);
```

Affiche :
```html
<b>machin</b><i>truc</i>
```

Mais si vous faites ça, vous écrasez la gestion initiale
des expressions vérifiées :

```php
Phug::display('p=$manquant'); // affiche <p></p>

Phug::setOption('php_token_handlers', [
    T_VARIABLE => function ($variable) {
        return $variable;
    },
]);

Phug::display('p=$manquant'); // Exception: Undefined variable: manquant
```

Mais vous pouvez toujours ré-appeler la méthode native de
gestion des variables avant ou après vos propres
traitements :

```php
Phug::setOption('php_token_handlers', [
    T_VARIABLE => function ($tokenString, $index, $tokens, $checked, $formatInstance) {
        // Traitement avant le processus des expressions vérifiées
        $tokenString .= 'Suffixe';
        // Processus des expressions vérifiées
        $tokenString = $formatInstance->handleVariable($tokenString, $index, $tokens, $checked);
        // Traitement après le processus des expressions vérifiées
        $tokenString = 'strtoupper('.$tokenString.')';

        return $tokenString;
    },
]);

Phug::display('p=$machin', [
    'machinSuffixe' => 'truc',
]);
```

Affiche :
```html
<p>TRUC</p>
```

## Mixins

### mixin_merge_mode `string`

Alias de `allowMixinOverride` dans **Pug-php**.

Détermine si une nouvelle déclaration de mixin avec un
nom existant va remplacer la précédente ou être ignorée :

```php
Phug::setOption('mixin_merge_mode', 'replace');

Phug::display('
mixin machin
  p A

mixin machin
  p B

+machin
');

// Affiche <p>B</p>

Phug::setOption('mixin_merge_mode', 'ignore');

Phug::display('
mixin machin
  p A

mixin machin
  p B

+machin
');

// Affiche <p>A</p>
```

Cette option est réglée sur `"replace"` par défaut.

## Formattage

### patterns `array`

Definit comment sont transformées des parties spécifiques des
éléments en PHP.

Valeur par défaut :
```php
[
  'class_attribute'        => '(is_array($_pug_temp = %s) ? implode(" ", $_pug_temp) : strval($_pug_temp))',
  'string_attribute'       => '
        (is_array($_pug_temp = %s) || is_object($_pug_temp) && !method_exists($_pug_temp, "__toString")
            ? json_encode($_pug_temp)
            : strval($_pug_temp))',
  'expression_in_text'     => '(is_bool($_pug_temp = %s) ? var_export($_pug_temp, true) : $_pug_temp)',
  'html_expression_escape' => 'htmlspecialchars(%s)',
  'html_text_escape'       => 'htmlspecialchars',
  'pair_tag'               => '%s%s%s',
  'transform_expression'   => '%s',
  'transform_code'         => '%s',
  'transform_raw_code'     => '%s',
  'php_handle_code'        => '<?php %s ?>',
  'php_display_code'       => '<?= %s ?>',
  'php_block_code'         => ' {%s}',
  'php_nested_html'        => ' ?>%s<?php ',
  'display_comment'        => '<!-- %s -->',
  'doctype'                => '<!DOCTYPE %s PUBLIC "%s" "%s">',
  'custom_doctype'         => '<!DOCTYPE %s>',
  'debug_comment'          => "\n// PUG_DEBUG:%s\n",
  'debug'                  => function ($nodeId) {
    return $this->handleCode($this->getDebugComment($nodeId));
  },
]
```

Les formats peuvent ajouter des *patterns* (comme le fait
[XmlFormat](https://phug-lang.com/api/classes/Phug.Formatter.Format.XmlFormat.html)) :
```php
class XmlFormat extends AbstractFormat
{
    //...

    const DOCTYPE = '<?xml version="1.0" encoding="utf-8" ?>';
    const OPEN_PAIR_TAG = '<%s>';
    const CLOSE_PAIR_TAG = '</%s>';
    const SELF_CLOSING_TAG = '<%s />';
    const ATTRIBUTE_PATTERN = ' %s="%s"';
    const BOOLEAN_ATTRIBUTE_PATTERN = ' %s="%s"';
    const BUFFER_VARIABLE = '$__value';

    public function __construct(Formatter $formatter = null)
    {
        //...

        $this->addPatterns([
            'open_pair_tag'             => static::OPEN_PAIR_TAG,
            'close_pair_tag'            => static::CLOSE_PAIR_TAG,
            'self_closing_tag'          => static::SELF_CLOSING_TAG,
            'attribute_pattern'         => static::ATTRIBUTE_PATTERN,
            'boolean_attribute_pattern' => static::BOOLEAN_ATTRIBUTE_PATTERN,
            'save_value'                => static::SAVE_VALUE,
            'buffer_variable'           => static::BUFFER_VARIABLE,
        ])
```

Vous pouvez voir par exemple `BOOLEAN_ATTRIBUTE_PATTERN = ' %s="%s"'`
qui implique que `input(checked)` devient `<input checked="checked">`.

Et
[HtmlFormat](https://phug-lang.com/api/classes/Phug.Formatter.Format.HtmlFormat.html)
le réécrit à son tour :

```php
class HtmlFormat extends XhtmlFormat
{
    const DOCTYPE = '<!DOCTYPE html>';
    const SELF_CLOSING_TAG = '<%s>';
    const EXPLICIT_CLOSING_TAG = '<%s/>';
    const BOOLEAN_ATTRIBUTE_PATTERN = ' %s';

    public function __construct(Formatter $formatter = null)
    {
        parent::__construct($formatter);

        $this->addPattern('explicit_closing_tag', static::EXPLICIT_CLOSING_TAG);
    }
}
```
`BOOLEAN_ATTRIBUTE_PATTERN = ' %s'` donc `input(checked)`
 devient `<input checked>`.

De la même manière vous pouvez étendre un format pour
créer votre propre format personnalisé et les supplanter
avec les options [formats](#formats-array)
et [default_format](#default-format-string).

Les *patterns* peuvent être des `string` où `%s` est replacé
par la valeur d'entrée ou des fonctions de *callback* qui
reçoivent la valeur d'entrée en argument.

Certains *patterns* ont des entrées multiples (comme `pair_tag`
qui prend `$ouverture`, `$contenu` et `$fermeture`).


Exemple d'utilisation : vous pouvez intercepter et
modifier les expressions :
```php

Phug::setOption('patterns', [
  'transform_expression' => 'strtoupper(%s)',
]);

Phug::display('p="AbcD"'); // Affiche <p>ABCD</p>
```

Ou vous pouvez changer la fonction d'échappement :
```php
Phug::setOption('patterns', [
  'html_expression_escape' => 'htmlentities(%s)',
  'html_text_escape'       => 'htmlentities',
]);
```

### pattern `callable`

L'option `pattern` est la façon dans les *patterns* sont gérés.

Valeur par défaut :
```php
function ($pattern) {
  $args = func_get_args();
  $function = 'sprintf';
  if (is_callable($pattern)) {
    $function = $pattern;
    $args = array_slice($args, 1);
  }

  return call_user_func_array($function, $args);
}
```

Cette fonction va prendre au moins un argument (le *pattern*)
et autant de valeurs que nécessaire pour ce *pattern* comme
arguments restants.

Vous pouvez voir dans le comportement par défaut que si un
*pattern* est *callable* (exécutable), nous l'appelons
simplement avec les valeurs d'entrée :
`$pattern($valeur1, $valeur2, ...)`, sinon
nous appelons `sprintf($pattern, $valeur1, $valeur2, ...)`

En changeant l'option `pattern`, vous pouvez gérer *patterns*
comme bon vous semble et supporter n'importe quels autres
types de *pattern*.

### formats `array`

Array des classes de format par *doctype*, la valeur par
défaut est :
```php
[
  'basic'        => \Phug\Formatter\Format\BasicFormat::class,
  'frameset'     => \Phug\Formatter\Format\FramesetFormat::class,
  'html'         => \Phug\Formatter\Format\HtmlFormat::class,
  'mobile'       => \Phug\Formatter\Format\MobileFormat::class,
  '1.1'          => \Phug\Formatter\Format\OneDotOneFormat::class,
  'plist'        => \Phug\Formatter\Format\PlistFormat::class,
  'strict'       => \Phug\Formatter\Format\StrictFormat::class,
  'transitional' => \Phug\Formatter\Format\TransitionalFormat::class,
  'xml'          => \Phug\Formatter\Format\XmlFormat::class,
]
```

Vous pouvez ajouter/modifier/supprimer n'importe quel
format par *doctype* :
```php
class MachinFormat extends \Phug\Formatter\Format\HtmlFormat
{
    const DOCTYPE = '#MACHIN';
    // Ici vous pouvez changer les options/méthodes/patterns
}

Phug::setOption('formats', [
    'machin' => MachinFormat::class,
] + Phug::getOption('formats'));
// Ajoute machin mais garde Phug::getOption('formats')
// Comme ça les deux arrays fusionnent

Phug::display('
doctype machin
test
');

// Affiche #MACHIN<test></test>
```

Vous pouvez aussi supprimer un format de la manière
suivante :
```php
$formats = Phug::getOption('formats');
unset($formats['xml']); // supprime le format XML

Phug::setOption('formats', $formats);

Phug::display('
doctype xml
test
');

// Affiche <!DOCTYPE xml><test></test>
// Au lieu de <?xml version="1.0" encoding="utf-8" ?><test></test>
```

### default_format `string`

C'est le format utilisé lorsqu'il n'y a pas de *doctype* ;
`\Phug\Formatter\Format\BasicFormat::class` par défaut.

```php
$renderer = new \Phug\Renderer([
  'default_format' => \Phug\Formatter\Format\XmlFormat::class,
]);
$renderer->display('input'); // <input></input>

$renderer = new \Phug\Renderer([
  'default_format' => \Phug\Formatter\Format\HtmlFormat::class,
]);
$renderer->display('input'); // <input>
```

### dependencies_storage `string`

Nom de la variable name qui contiendra les dépendances dans le
code PHP compilé ; `"pugModule"` par défaut.

### formatter_class_name `string`

Vous permet d'étendre la
[classe Formatter](https://phug-lang.com/api/classes/Phug.Formatter.html)
```php
class CustomFormatter extends \Phug\Formatter
{
    public function format(\Phug\Formatter\ElementInterface $element, $format = null)
    {
        // Ajotue des espaces partout
        return parent::format($element, $format).' ';
    }
}

Phug::display('
span machin
span truc
');

// <span>machin</span><span>truc</span>

$renderer = new Phug\Renderer([
    'formatter_class_name' => CustomFormatter::class,
]);

$renderer->display('
span machin
span truc
');

// <span>machin </span> <span>truc </span>
```

## Rendu

### adapter_class_name `string`

Cette option requiert une réinitialisation de l'*adapter*
pour être prise en compte. Donc soit vous pouvez l'utiliser
en option initiale (passée dans l'array des options lors
de l'instanciation d'un nouveau *Renderer* ou un nouveau
*Pug* si vous utilisez **Pug-php**)
sinon vous pouvez simplement utiliser la
[méthode `->setAdapterClassName()`](https://phug-lang.com/api/classes/Phug.Renderer.Partial.AdapterTrait.html#method_setAdapterClassName)
pour changer cette option puis réinitialiser l'*adapter*.

```php
Phug::getRenderer()->setAdapterClassName(\Phug\Renderer\Adapter\StreamAdapter::class);
// Phug::getRenderer()->getAdapter() instanceof \Phug\Renderer\Adapter\StreamAdapter
```

Il y a 3 *adapters* dispnibles et vous pouvez en créer
d'autres en étendant l'un d'eux ou la
[classe AbstractAdapter](https://phug-lang.com/api/classes/Phug.Renderer.AbstractAdapter.html).

Le rôle de l'*adapter* est de prendre le code compilé
formatté et de le transformer en code final rendu.
Donc le plus souvent, il s'agit d'exécuter du code
PHP pour obtenir du code HTML.

#### FileAdapter

[FileAdapter](https://phug-lang.com/api/classes/Phug.Renderer.Adapter.FileAdapter.html)
est le seul *adapter* à implémenter l'interface
[CacheInterface](https://phug-lang.com/api/classes/Phug.Renderer.CacheInterface.html)
donc lorsque vous activez ou utiliser n'importe
quelle fonctionnalité de cache, cet *adapter*
est automatiquement sélectionné si l'*adapter*
courant n'implémente pas `CacheInterface`.
`->display()` avec le FileAdapter est équivalent à :
```php
file_put_contents('fichier.php', $codePhp);
include 'fichier.php';
```

#### EvalAdapter

[EvalAdapter](https://phug-lang.com/api/classes/Phug.Renderer.Adapter.EvalAdapter.html)
est l'*adapter* par défaut et utilise
[eval](http://php.net/manual/fr/function.eval.php).
Vous pouvez avoir entendu que `eval` est dangereux. Et
oui, si vous ne filtrez pas les entrées utilisateur/externes
que la chaîne que vous passez à `eval` peut contenir, c'est
risqué. Mais ça n'arrive pas lors d'un rendu de template.
Vos variables locales ou globales ne sont jamais exécutées,
seul le code Pug converti en code PHP l'est, donc
si vous n'écrivez pas de code dangereux dans votre
code Pug, il n'y a rien de dangereux dans le code
PHP final.
C'est parfaitement aussi sûr que les 2 autres *adapters*,
vous obtiendrez exactement les mêmes exécutions et
résultats quelque soit l'*adapter* utilisé.

Regardez l'exemple suivant :
```pug
p?!=$contenuDangereux
```
```vars
[
  'contenuDangereux' => 'file_get_contents("index.php")',
]
```
Comme vous le voyez, les variables peuvent contenir
n'importe quoi et être affichées n'importe comment,
elles ne seront jamais évaluée en PHP, seulement
affichées.
Le danger n'apparaît que si vous l'écrivez directement
dans vos templates Pug, c'est donc le même danger
qu'avec n'importe quel moteur de templates, ou que
si vous l'écriviez directement dans vos fichiers
PHP.

EvalAdapter est aussi l'*adapter* le plus rapide et
le plus facile à utiliser. Dans ce mode `->display()`
est équivalent à :
```php
eval('?>'.$codePhp);
```

#### StreamAdapter

[StreamAdapter](https://phug-lang.com/api/classes/Phug.Renderer.Adapter.StreamAdapter.html)
Le flux (*stream*) est une alternative entre les deux.
Dans ce mode `->display()` est équivalent à :
```php
include 'pug.stream://data;'.$codePhp;
```
Le *stream* a des contraintes. La taille du flux
est limitée par la mémoire RAM. Et la configuration
server (comme php.ini) peut interdire les
inclusions de flux.

### stream_name `string`

Par défaut `"pug"`. Détermine le nom du flux
quand vous utilisez l'*adapter* StreamAdapter
(voir ci-dessus).

### stream_suffix `string`

Par défaut `".stream"`. Détermine le suffixe du flux
quand vous utilisez l'*adapter* StreamAdapter
(voir ci-dessus).

## Système de fichiers

### tmp_dir `string`

Le dossier à utiliser pour stocker des fichiers
temporaires.
`sys_get_temp_dir()` par défaut.

### tempnam `callable`

La fonction à utiliser pour créer un fichier
temporaire.
`"tempnam"` par défaut.

### get_file_contents `callable`

La fonction à utiliser pour récupérer le contenu
d'un fichier.
`"file_get_contents"` par défaut.

```php
$storage = new Memcached();
$storage->addServer('localhost', 11211);
Phug::setOption('get_file_contents', function ($path) use ($storage) {
  return $storage->get($path);
});
```

Dans cet exemple, au lieu de chercher les templates
(qu'ils soient rendus, inclus ou étendus) dans le fichier
correspondant au chemin, on le cherche dans un stockage
Memcached.

### up_to_date_check `boolean`

`true` par défaut, si réglé sur `false`, les fichiers
de cache n'expirent jamais jusqu'à ce que le cache
soit manuellement vidé.
