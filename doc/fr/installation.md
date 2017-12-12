# Installation

## Dans votre framework préféré

Si vous utilisez l'un des frameworks suivant, cliquez sur le lien
correspondant pour installer phug directement dans votre
application.

- Laravel:
[![Latest Stable Version](https://poser.pugx.org/bkwld/laravel-pug/v/stable.png)](https://packagist.org/packages/bkwld/laravel-pug)
[bkwld/laravel-pug](https://github.com/BKWLD/laravel-pug)

- Symfony:
[![Latest Stable Version](https://poser.pugx.org/pug-php/pug-symfony/v/stable.png)](https://packagist.org/packages/pug-php/pug-symfony)
[pug-php/pug-symfony](https://github.com/pug-php/pug-symfony)

- Phalcon:
[![Latest Stable Version](https://poser.pugx.org/pug-php/pug-phalcon/v/stable.png)](https://packagist.org/packages/pug-php/pug-phalcon)
[pug-php/pug-phalcon](https://github.com/pug-php/pug-phalcon)

- CodeIgniter:
[![Latest Stable Version](https://poser.pugx.org/ci-pug/ci-pug/v/stable.png)](https://packagist.org/packages/ci-pug/ci-pug)
[ci-pug/ci-pug](https://github.com/pug-php/ci-pug-engine)

- Yii 2:
[![Latest Stable Version](https://poser.pugx.org/pug/yii2/v/stable.png)](https://packagist.org/packages/pug/yii2)
[pug/yii2](https://github.com/pug-php/pug-yii2)

- Slim 3:
[![Latest Stable Version](https://poser.pugx.org/pug/slim/v/stable.png)](https://packagist.org/packages/pug/slim)
[pug/slim](https://github.com/pug-php/pug-slim)

- Silex: [exemple d'implementation](https://gist.github.com/kylekatarnls/ba13e4361ab14f4ff5d2a5775eb0cc10)

- Lumen: [bkwld/laravel-pug](https://github.com/BKWLD/laravel-pug#use-in-lumen) fonctionne aussi avec Lumen

Les adapteurs ci-dessus utilisent **pug-php 3**, ce qui signifie que les
expressions doivent être écrite en JS par défaut, mais vous pouvez
utiliser le style natif PHP en règlant l'option `expressionLanguage`
sur `php`.

Si vous souhaitez que nous supportions d'autres frameworks, veuillez
ouvrir une issue (un ticket) sur GitHub :
https://github.com/phug-php/phug/issues/new et si votre issue reçoit
des vôtes, nous y travaillerons.

## Installation initiale

Premièrement, vous aurez besoin de *composer* si vous ne l'avez pas déjà :
https://getcomposer.org/download/

Puis installez phug en exécutant la commande suivante dans le dossier
de votre application :
```shell
composer require phug/phug
```

Remplacez `composer` par `php composer.phar` si vous avez installé
composer localement. IL en va de même pour toutes les autres commandes
*composer* mentionnées dans cette documentation.

Créez un fichier PHP avec le contenu suivant :
```php
<?php

include_once __DIR__ . '/vendor/autoload.php';

Phug::display('p=$message', [
  'message' => 'Bonjour',
]);
```

Vous pouvez éditer les premiers et seconds arguments de `Phug::display`
dans les éditeurs de code ci-dessous et voir le résultat dans le
panneau de droite.

```phug
p=$message
```
```vars
[
  'message' => 'Bonjour',
]
```

`Phug::display` prend le contenu du template en premier argument,
les valeurs des variables en deuxième argument optionnel et un
troisième argument optionnel permet de spécifier des options
(voir [Options chapter](#options)).

Vous pouvez utiliser `Phug::displayFile` pour afficher un fichier
de template :
```php
Phug::displayFile('dossier-des-vues/mon-template.pug');
```
Les mêmes arguments optionnels, variables et options, sont
disponibles.

Vous pouvez aussi retourner le résultat au lieu de l'afficher
avec `Phug::render` et `Phug::renderFile`.

La classe **Phug** agit aussi comment une façade de la classe
**Renderer**, ce qui veut dire que vous pouvez appeler statiquement
sur `Phug\Phug` n'importe quel méthode de `Phug\Rebderer`.
Par exemple, cela rend `compile` et `compileFile` disponibles :

```php
file_put_contents('cache/ma-page-compilée.php', Phug::compileFile('vue/mon-template.pug'));
```

Ce code va compiler le fichier de template `vue/mon-template.pug`
et l'enregistrer dans `cache/ma-page-compilée.php`, c'est basiquement
ce que fait notre option de cache.

Vous pouvez remarquer que le fichier PHP contient du code de débogage,
ce code permet de fournir des traces d'erreur précise (line et colonne
dans le fichier source pug) et des outils de profilage pour vérifier
la performance des différents composants du template.

En production, vous pouvez facilement désactiver ces outils avec
`setOption` :

```php
Phug::setOption('debug', false);

echo Phug::compile('p=$utilisateur');
```

Ceci va afficher le fichier compilé sans code de débogage.

Consultez toutes les méthodes disponibles dans la référence de l'API :
- [Phug\Phug](https://phug.selfbuild.fr/api/classes/Phug.Phug.html)
- [Phug\Renderer](https://phug.selfbuild.fr/api/classes/Phug.Renderer.html)

## Utiliser des expressions JavaScript

Pour supporter des expressions de style JS, installez l'extension
**js-phpize** pour **phug** :
```shell
composer require js-phpize/js-phpize-phug
```

Remplacez `composer` par `php composer.phar` si vous avez installé
composer localement.

Puis activez l'extension avant d'appeler la méthode render ou display :
```php
<?php

use JsPhpize\JsPhpizePhug;

include_once __DIR__ . '/vendor/autoload.php';

Phug::addExtension(JsPhpizePhug::class);

Phug::display('p=utilisateur', [
  'utilisateur' => 'Bob',
]);

```

```pug
label Nom d'utilisateur
input(value=utilisateur)
```
```vars
[
  'utilisateur' => 'Bob',
]
```

Pour utiliser les expressions PHP dans **Pug-php**, utilisez l'option
`expressionLanguage` :

```php
<?php

use Pug\Pug;

include_once __DIR__ . '/vendor/autoload.php';

$pug = new Pug([
    'expressionLanguage' => 'php',
]);

$pug->display('p=$utilisateur->nom', [
  'utilisateur' => (object) [
    'nom' => 'Bob',        
  ],
]);
```

```phug
label Nom d'utilisateur
input(value=$utilisateur->nom)
```
```vars
[
  'utilisateur' => (object) [
    'nom' => 'Bob',        
  ],
]
```
