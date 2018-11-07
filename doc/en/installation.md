# Installation

## In your favorite framework

If you use one of the following frameworks, click on the link to see how to install
phug directly in your application.

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

- Silex: [implementation example](https://gist.github.com/kylekatarnls/ba13e4361ab14f4ff5d2a5775eb0cc10)

- Lumen: [bkwld/laravel-pug](https://github.com/BKWLD/laravel-pug#use-in-lumen) also works with Lumen

- Zend Expressive [infw/pug](https://github.com/kpicaza/infw-pug)

The framework adapters above are based on **Pug-php 3**, that means expressions
should be written in JS style by default, but you can use PHP native style by
setting `expressionLanguage` to `php`.

If you want us to support some other framework, please open an issue here:
https://github.com/phug-php/phug/issues/new and if your issue get some votes,
we'll work on it.

## In your favorite <acronym title="Content Management System">CMS</acronym>

- WordPress: [wordless](https://github.com/welaika/wordless)

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

echo Phug::compile('p=$userName');
```

This will display the PHP compiled code with no debug code.

See all available methods in the API reference:
- [Phug\Phug](/api/classes/Phug.Phug.html)
- [Phug\Renderer](/api/classes/Phug.Renderer.html)

## Use JavaScript expressions

By default, **Phug** and **Tale-pug** use PHP expressions. And **Pug-php**
use JS expressions, but you can easily change the default behavior.

To handle js-style expressions on **Phug** and **Tale-pug**, install the
**js-phpize** extension for **Phug**:
```shell
composer require js-phpize/js-phpize-phug
```

Replace `composer` with `php composer.phar` if you installed composer locally.

Then enable the extension before calling the render/display method:
```php
<?php

use JsPhpize\JsPhpizePhug;

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

To use PHP expressions in **Pug-php**, use the option `expressionLanguage`:

```php
<?php

use Pug\Pug;

include_once __DIR__ . '/vendor/autoload.php';

$pug = new Pug([
    'expressionLanguage' => 'php',
]);

$pug->display('p=$user->name', [
  'user' => (object) [
    'name' => 'Bob',        
  ],
]);
```

```phug
label Username
input(value=$user->name)
```
```vars
[
  'user' => (object) [
    'name' => 'Bob',        
  ],
]
```

### Switch expression language inside template

Since js-phpize-phug 2.1.0, it's now possible to switch between both styles
inside templates.

```pug
body
  //- Whatever the options, we swtich to js mode
  language js
  - counter = 0
  
  node-language php
  div
    //- This node (the div tag) and its children
    //- will use php mode by default
    - $counter++
    span= $counter++
    //- Switch to js mode until new order
    language js
    - counter++
    - counter++
    //- And php again
    language php
    p= $counter

  section
    //- Outside the node (div tag), we go back to
    //- the previous mode
    p= counter
    //- language and node-language can also be called
    //- throught comments
    //- @language php
    p= $counter
```
