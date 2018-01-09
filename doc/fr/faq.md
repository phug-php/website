# Questions fréquentes

## Pourquoi ai-je une erreur avec les variables en CASSE_MAJUSCULE ?

Cela peut arriver lorsque vous
This can happen when you use
[utilisez le style JS](#utiliser-des-expressions-javascript)
(module js-phpize ou **Pug-php**) simplement parce
que rien dans la syntaxe JS ne permet de distinguer
une constante d'une variable donc nous avons choisi
de suivre la convention la plus utilisée : un nom
tout en majuscules est une constante, tout le reste
est une variable :
```pug
:php
  $fooBar = 9;
  define('FOO_BAR', 8);
  $d = 9;
  define('D', 8);
  $_ = '_';
  define('_K', 5);

p=fooBar
p=FOO_BAR
p=d
p=D
p=_
p=_K
```

Il est toujours possible de désactiver les constantes
de la manière suivante :
```php
<?php

use Pug\Pug;

include 'vendor/autoload.php';

$pug = new Pug([
    'module_options' => [
        'jsphpize' => [
            'disableConstants' => true,
        ],
    ],
]);

$pug->display('p=FOO', [
    'FOO' => 'variable',
]);
```

## Comment utiliser les namespaces dans un template pug ?

Par défaut, les templates sont exécutés sans
namespace et vous aurez besoin d'écrire les
chemins complets pour accéder aux fonctions
et classes :

```pug
p=\QuelquePart\unefonction()
p=appelle_depuis_le_namespace_racine()
- $a = new \QuelquePart\UneClasse()
```
<i data-options='{"mode":"format"}'></i>

Vous ne pouvez pas définir un namespace au début
d'un template pug car ce n'est pas le début du
fichier PHP compilé (nous ajoutons du code de
debug, les dépendances, les fonctions de mixins,
etc.)

Cependant vous pouvez appliquer globalement un
namespace à tous vos templates de la manière
suivante :

```php
Phug::setOption('on_output', function (OutputEvent $event) {
  $event->setOutput(
    '<?php namespace QuelquePart; ?>'.
    $event->getOutput()
  );
});
```

Avec cet intercepteur de l'événement *output*, le
précédent code devient :

```pug
p=unefonction()
p=\appelle_depuis_le_namespace_racine()
- $a = new UneClasse()
```
<i data-options='{"mode":"format"}'></i>

## Comment exécuter des scripts JS à l'intérieur des templates?

Il y a différentes approches possibles :

- Tout d'abord, évitez de mélanger du PHP et du JS dans
votre back-end donc si vous avez déjà une application
PHP et trouvez un paquet node.js qui vous intéresse,
vérifiez d'abord qu'il n'existe pas d'équivalent en PHP.

- Si vous n'avez pas besoin d'appeler de fonctions,
méthodes ou objets PHP dans vos templates, alors vous
pouvez utiliser le paquet pugjs natif de npm. **Pug-php**
a une option pour ça :
```php
<?php

use Pug\Pug;

include 'vendor/autoload.php';

$pug = new Pug([
    'pugjs' => true,
]);

// Moteur Phug ignoré, pugjs utilisé à la place
$pug->display('p=9..toString()');

// Dans ce mode, vous pouvez `require` n'importe quel
// fichier JS ou paquet npm :
$pug->display('
- moment = require("moment")
p=moment("20111031", "YYYYMMDD").fromNow()
');
```

- Vous pouvez passer une fonction comme n'importe quelle
autre variable via `share` ou `render` qui peut appeler un
programme CLI (comme node ou n'importe quoi d'autre) :
```php
$pug->share('afficheDate', function ($date) {
    return shell_exec('node votre-script.js ' . escapeshellarg($date));
});
```

- Vous pouvez utiliser le moteur V8Js
(http://php.net/manual/fr/book.v8js.php) :
```php
$pug->share('afficheDate', function ($date) {
    $v8 = new V8Js('valeurs', array('date' => '2016-05-09'));

    return $v8->executeString('appelleUneFonctionJs(valeurs.date)');
});
```

## Comment utiliser des fonctions *helper* avec l'option pugjs ?

Quand vous utiliser **Pug-php** avec l'option `pugjs` à `true`
toutes les données passées à la view sont encodées en JSON.
Donc vous perdez vos typage de classe et vous perdez les fonctions
de closure.

Néanmoins, vous pouvez écrire des fonctions JS à l'intérieur
de vos templates et utiliser n'importe quelle locale ou
variable partagée dedans :
```pug
-
  function asset(file) {
    return assetDirectory + '/' + file + '?v' + version;
  }

script(href=asset('app'))
```
```vars
[
  'assetDirectory' => 'assets',
  'version' => '2.3.4',
]
```
<i data-options='{"pugjs":true}'></i>

## Comment désactiver les erreurs en production ?

En production, vous devriez régler l'option `debug` à `false`.
Puis vous devriez utiliser un gestionnaire d'exceptions global
pour votre application PHP qui cache les erreurs à l'utilisateur.

L'idéal est de les enregistrer (dans un fichier de log par exemple)
en utilisant la gestion d'exception 
(voir [set_exception_handler](http://php.net/manual/fr/function.set-exception-handler.php)).

Un moyen plus radical est de les cacher complètement avec
`error_reporting(0);` ou la même configuration dans **php.ini**.

## Comment inclure dynamiquement des fichiers ?

Les mot-clés `include` et `extend` n'accepte que des chemins
statiques : `include monFichier` mais pas des variables :
`include $maVariable`.

Mais les mots-clés personnalisés arrivent à la rescousse :
```php
Phug::addKeyword('dyninclude', function ($args) {
    return array(
        'beginPhp' => 'echo file_get_contents(' . $args . ');',
    );
});
```

Cela permet d'include des fichiers en tant que texte brut :

```pug
- $fichierDeStyle = 'machin.css'
- $fichierDeScript = 'machin.js'

style
  // Inclut machin.css en contenu inline
  dyninclude $fichierDeStyle
  
script
  // Inclut machin.js en contenu inline
  dyninclude $fichierDeScript
```
<i data-options='{"static": true}'></i>

Attention : vous devez vérifier le contenu des variables
avant leur inclusion. Si `$fichierDeStyle` contient
`"../../config.php"` et que `config.php` contient des
mots de passes de BDD, des secrets de session, etc.
ces informations privées vont s'afficher.

Vous devez être encore plus prudent si vous autorisez
l'inclusion de fichiers PHP :
```php
Phug::addKeyword('phpinclude', function ($args) {
    return array(
        'beginPhp' => 'include ' . $args . ';',
    );
});
```

Cela peut être utilie et sécurisé si par exemple vous
faites ceci :
```pug
each $module in $modulesUtilisateur
  - $module = 'modules/'.preg_replace('/[^a-zA-Z0-9_-]/', '', $module).'.php'
  phpinclude $module
```
<i data-options='{"static": true}'></i>

Dans cet exemple, en supprimant tous les caractères exceptés
les lettres, chiffres et tirets, peu importe ce que contient
`$modulesUtilisateur` et d'où ça vient, vous ête sûr
d'inclure un fichier qui existe dans le dossier *modules*.
Donc vous avez juste à vérifier ce que vous mettez dans ce
dossier.

Finalement vous pouvez aussi inclure des fichiers
dynamiquement et les rendre avec **Phug** (ou n'importe
quel *transformer*) :
```php
Phug::addKeyword('puginclude', function ($args) {
    return array(
        'beginPhp' => 'Phug::display(' . $args . ');',
    );
});
```

```pug
- $path = '../dossier/template'
puginclude $path
```
<i data-options='{"static": true}'></i>

Cela inclut `../dossier/template.pug` comme l'extension
est concaténée dans le callback du mot-clé.

## Comment gérer l'internationalisation ?

Les fonctions de traduction telles que `__()` pour Laravel
ou `_()` pour gettext peuvent être appelées comme n'importe
quelle autre fonction dans un expression ou un bloc de code.

Le *parser* gettext ne supporte pas les fichiers pug mais
le mode python donne de bons résultats avec les fichiers
pug.

Les méthodes d'initialisation comme `textdomain` peuvent
être appelée dans des blocs de code. Par exemple
`- textdomain("domain")` peut être la première ligne
de votre fichier pug.

Enfin, soyez sûr que l'extension nécessaire (comme
gettext) est bien installée sur l'instance PHP qui
rend vos templates pug.

## Comment vider le cache ?

Si vous utilisez [laravel-pug](https://github.com/BKWLD/laravel-pug)
le cache est géré par Laravel et donc vous pouvez vous référer
à la documentation du framework pour les opérations sur le
cache. Le vide se fait par exemple avec `php artisan cache:clear`

Sinon en production, vous devriez utiliser
[la commande cache-directory](/#compile-directory-ou-cache-directory)
et désactiver l'option `up_to_date_check`.

En environement de développement, si vous avez le
moindre problème avec le cache, vous pouvez juste
désactiver sans risque le cache avec un code comme
celui-là :

```php
Phug::setOption('cache', $prod ? 'dossier/de/cache' : false);
```

## Quel est l'équivalent des filtres Twig ?

Si vous connaissez Twig, vous connaissez peut-être
cette syntaxe :
```html
<div>{{ param1 | filtre(param2, param3) }}</div>
```

Ou si vous connaissez AngularJS, ces filtres :
```html
<div>{{ param1 | filtre : param2 : param3 }}</div>
```

Les filtres de Pugsont un peu différents puisqu'ils
ne sont autorisés que en dehors des expressions :
```html
div
  :filter(param2=param2 param3=param3)
    param1
```
À l'intérieur du contenu d'une balise, c'est techniquement
utilisable même si cette syntaxe ne serait sûrement
pas pertinente dans ce cas.

Pour les valeurs des attributs ou à l'intérieur
des arguments de mixin, il n'y a rien de
disponible semblable aux filtres parce que
des simples fonctions marchent déjà très bien :

```html
<div>{{ filter(param1, param2, param3) }}</div>
```

Les filtres de Twig/AngularJS ne sont rien de plus
qu'une inversion du premier argument et du nom
de la fonction. La plupart des filtres Twig sont
disponible en tant que fonctions natives de PHP
(split : explode, replace :
strtr, nl2br : nl2br, etc.).

De plus, vous pouvez passer des fonctions comme
closures à l'intérieur de vos variables
locales ou des variables partagées.

Et souvenez-vous que le symbole `|` existe déjà en
PHP, c'est l'opérateur binaire *OR*.

## Comment résoudre `Warning: include() read X bytes more data than requested (Y read, Z max)` ?

Ceci arrive probablement parce que vous avez
dans votre php.ini le réglage `mbstring.func_overload`
avec le flag `2` activé.

Comme c'est un réglage obsolète, la meilleure
chose à faire est de le régler à `0` et de
remplacer manuellement les fonctions dans
votre application plutôt que d'utiliser
l'*overload*.

Si vous avez vraiment besoin de garder ce
réglage, vous pouvez toujours utiliser le
*FileAdapter* qui n'est pas sensible à ce
problème :

```php
Phug::setOption('adapter_class_name', FileAdapter::class);
```

## Comment résoudre `Maximum function nesting level of 'X' reached` ?

Cette erreur signifie que vous avez dépassé le réglage
`xdebug.max_nesting_level` du php.ini. La valeur
par défaut est 100 et peut s'avérer insuffisante.
Avec beaucoup d'*includes* et de mixins imbriqués
dans vos templates, vous pourriez atteindre
les 500 *nesting levels* (niveaux d'imbrication).
Donc tout d'abord, essayez d'augmenter ce réglage.

Si vous avez toujours l'erreur, alors vous avez
probablement une récursion infinie. Cela peut arriver
avec pug quand un template `a.pug` inclut `b.pug`
et que ce dernier inclut lui-même `a.pug`
(bien sûr il en va de même pour les fichiers
PHP). Si vous n'avez pas de conditions pour
éviter que la récursion soit infinie, vous allez
avoir une erreur *nesting level* ou *timeout exceeded*.
Cela peut aussi arriver quand un mixin s'appelle
lui-même (ou indirectement via d'autres mixins)
et la même chose est possible avec les fonctions
PHP.

Note : xdebug est une extension de débogage, donc
n'oubliez pas de la d'asctiver en production.

## Devrais-je utiliser `render` ou `renderFile` ?

Dans les anciennes versions de **Pug-php**, il n'y avait que la
méthode `render` qui convertissait un fichier si l'argument
donné correspondait au chemin d'un fichier existant, sinon
elle convertissait l'argument en tant que chaîne pug.
Alors que **Tale-pug** convertissait toujours un fichier.

Aucun de ces comportement n'était aligné avec **Pugjs** donc
on a choisit de le changer dans **Phug**. Avec **Phug**,
`render` ne prend que des chaîne, pas de fichier, et
`renderFile` a été ajotué pour convertir des fichiers.

**Pug-php** garde l'ancien comportement pour le moment pour
faciliter la mise à niveau mais il est fortement recommandé
d'utiliser l'option `strict` pour obtenir le nouveau
comportement :
```php
$pug = new Pug([
  'strict' => true,
]);
```
De cette manière `$pug->render()` va toujours prender une chaîne
pug en premier argument peu importe que l'argument corresponde
our non a un chemin de fichier. Cela peut éviter des
comportements inattendus.

Si pour des raisons de compatibilité, vous ne pouvez pas
utiliser cette option, alors vous devriez éviter d'utiliser
`render` et utiliser `renderString` pour une chaîne pug
et `renderFile` pour un fichier.

## Comment déboguer un code venant de la documentation qui ne fonctionne pas dans mon application ?

D'abord, nous supposons que vous utiliser la dernière
version de **Phug** (ou **Pug-php** >= 3).

Vous pouvez vérifier votre version de **Phug** avec
`composer show phug/phug`
et la mettre à jour avec :
`composer update`

La dernière version stable de **Phug** est
[![Latest Stable Version](https://camo.githubusercontent.com/9ff236cbfba46cf8c9a6be7502a500f1bb09bd52/68747470733a2f2f706f7365722e707567782e6f72672f706875672f706875672f762f737461626c652e706e67)](https://packagist.org/packages/phug/phug)

Si vous utiliser une version de **Pug-php** < 3.0
(vérifiez avec `composer show phug/phug`)
cette documentation n'est pas exacte pour vous
et nous vous recommandons vivement de mettre
à jour **Pug-php** à la version
[![Latest Stable Version](https://camo.githubusercontent.com/8d24c2c0b2fd374bda61453ce6c4293af68f7f88/68747470733a2f2f706f7365722e707567782e6f72672f7075672d7068702f7075672f762f737461626c652e706e67)](https://packagist.org/packages/pug-php/pug)

Si vous utilisez **Tale-jade** ou **Tale-pug**,
nous vous conseillons de migrer à **Phug**.

Ensuite, les exemples dans cette documentation sont
pour **Phug** si ce n'est pas précisé autrement.
Si vous utilisez **Pug-php** vous devez l'adapter.
Par exemple :
```php
Phug::setOption('cache_dir', 'dossier');
Phug::display('template.pug', $vars);
```

Devrait être écrit avec l'une des 2 syntaxes suivantes
pour que les fonctionnalités de **Pug-php** fonctionnent :
```php
\Pug\Facade::setOption('cache_dir', 'dossier');
\Pug\Facade::display('template.pug', $vars);
```

`\Pug\Facade` permet de remplacer facilement `Phug`
en gardant la syntaxe. Mais vous pourriez préférer
le style instancié :

```php
$pug = new Pug([
  'cache_dir' => 'dossier',
]);
$pug->display('template.pug', $vars);
```
