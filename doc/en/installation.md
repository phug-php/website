# Installation

## In your favorite framework

If you use one of the following frameworks, click on the link to see how to install
phug directly in your application.

- Laravel: https://github.com/BKWLD/laravel-pug

- Symfony: https://github.com/pug-php/pug-symfony

- Phalcon: https://github.com/pug-php/pug-phalcon

- CodeIgniter: https://github.com/pug-php/ci-pug-engine

The framework adapters above are based on **pug-php 3**, that means expressions
should be written in JS style by default, but you can use PHP native style by
setting `expressionLanguage` to `php`.

Yii and Slim adapters are also available but based on **pug-php 2** right now
and so there are not yet compatible with Phug:

- Yii 2: https://github.com/rmrevin/yii2-pug

- Slim 3: https://github.com/MarcelloDuarte/pug-slim

If you want us to support some other framework, please open an issue here:
https://github.com/phug-php/phug/issues/new and if your issue get some votes,
we'll work on it.

## Installation from scratch

First you need *composer* if you have'nt yet: https://getcomposer.org/download/

Then run in your application directory:
```shell
composer require phug/phug
```

Replace `composer` with `php composer.phar` if you installed composer locally.
And same goes for every composer commands mentioned in this documentation.

Create a PHP file with the following content:
```php
<?php

use Phug\Phug;

include_once __DIR__ . '/vendor/autoload.php';

Phug::display('p=$message', [
  'message' => 'Hello',
]);
```

You can edit first and second arguments of `Phug::display` in the code editors
below and see the results in the right panel.

```phug
p=$message
```
```vars
[
  'message' => 'Hello',
]
```

`Phug::display` take a template string as first argument, variables values
as second optional argument  and a third optional argument allow you to specify
options (see [Options chapter](#options)).

You can use `Phug::displayFile` to display a template file:
```php
Phug::displayFile('views-directory/my-pug-template.pug');
```
The same optional variables and option arguments are available.

You can also return the result instead of displaying it with `Phug::render`
and `Phug::renderFile`.

The **Phug** class will also act like a facade for the **Renderer** class, it means
you can call statically on `Phug\Phug` any `Phug\Rebderer`'s method. For example,
it makes `compile` and `compileFile` available:

```php
file_put_contents('cache/my-compiled-page.php', Phug::compileFile('view/my-template.pug'));
```

This code will compile the template file `view/my-template.pug` and save it into
`cache/my-compiled-page.php`, this is basically what we do when the **cache**
option is set.

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
