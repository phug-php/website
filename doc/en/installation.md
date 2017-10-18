# Installation

## In your favorite framework

If you use one of the following framework, click on the link to see how to install
phug directly in your application.

- Laravel: https://github.com/BKWLD/laravel-pug

- Symfony: https://github.com/pug-php/pug-symfony

- Phalcon: https://github.com/pug-php/pug-phalcon

- CodeIgniter: https://github.com/pug-php/ci-pug-engine

The framework adapters above are based on **pug-php 3**, that means expressions
should be written in JS style by default, but you can use PHP native style by
setting `expressionLanguage` to `php`.

Yii and Slim adapters are also available but based on **pug-php 2** and so there
are not compatible with Phug:

- Yii 2: https://github.com/rmrevin/yii2-pug

- Slim 3: https://github.com/MarcelloDuarte/pug-slim

You want us to support some other framework, please open an issue here:
https://github.com/phug-php/phug/issues/new and if your issue get some votes,
we'll work on it.

## Installation from scratch

First you need composer if you have'nt yet: https://getcomposer.org/download/

Then run:
```shell
composer require js-phpize/js-phpize-phug
composer require phug/phug
```
PHP:
```php
<?php

use JsPhpize\JsPhpizePhug;
use Phug\Phug;

include_once __DIR__ . '/vendor/autoload.php';

Phug::display('p=userName', [
  'userName' => 'Bob',
], [
  'modules' => [
    JsPhpizePhug::class,
  ],
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
