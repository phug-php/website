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
