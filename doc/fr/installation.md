# Installation

## Dans votre framework préféré

Si vous utilisez l'un des frameworks suivant, cliquez sur le lien
correspondant pour installer phug directement dans votre
application.

- Laravel: https://github.com/BKWLD/laravel-pug

- Symfony: https://github.com/pug-php/pug-symfony

- Phalcon: https://github.com/pug-php/pug-phalcon

- CodeIgniter: https://github.com/pug-php/ci-pug-engine

Les adapteurs ci-dessus utilisent **pug-php 3**, ce qui signifie que les
expressions doivent être écrite en JS par défaut, mais vous pouvez
utiliser le style natif PHP en règlant l'option `expressionLanguage`
sur `php`.

Des adapteurs pour Yii et Slim sont aussi disponibles mais basés sur
**pug-php 2** pour le moment et ne sont donc pas encore compatible
avec Phug:

- Yii 2: https://github.com/rmrevin/yii2-pug

- Slim 3: https://github.com/MarcelloDuarte/pug-slim

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

use Phug\Phug;

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

You may notice the PHP file contain debug code, this code allow us to provide
you accurate error trace (give you matching line and offset in the pug source)
and profiling tools to check performance.

In production, you can easily disable that stuff with `setOption`:

```php
Phug::setOption('debug', false);

echo Phug::compile('p=userName');
```

This will display the PHP compiled code with no debug code.

See all available methods in the API reference:
- [Phug\Phug](https://phug.selfbuild.fr/api/classes/Phug.Phug.html)
- [Phug\Renderer](https://phug.selfbuild.fr/api/classes/Phug.Renderer.html)

## Use JavaScript expressions

To handle js-style expressions:
```shell
composer require js-phpize/js-phpize-phug
```

Replace `composer` with `php composer.phar` if you installed composer locally.

Then enable the extension before calling the render/display method:
```php
<?php

use JsPhpize\JsPhpizePhug;
use Phug\Phug;

include_once __DIR__ . '/vendor/autoload.php';

Phug::addExtension(JsPhpizePhug::class);

Phug::display('p=userName', [
  'userName' => 'Bob',
]);

```

```pug
label Username
input(value=userName)
```
```vars
[
  'userName' => 'Bob',
]
```
