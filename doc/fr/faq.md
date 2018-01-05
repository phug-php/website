# Questions fréquentes

## Pourquoi ai-je une erreur avec les variables
en CASSE_MAJUSCULE ?

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

## Comment utiliser les namespaces dans un
template pug ?

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

## Comment exécuter des scripts JS à l'intérieur des
templates?

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
