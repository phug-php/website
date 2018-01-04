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
