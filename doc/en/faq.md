# Frequently asked questions

## Why do I get error with UPPER_CASE
variables?

This can happen when you use
[use JS-style](#use-javascript-expressions)
(js-phpize module or **Pug-php**) simply because
nothing in the JS syntax allow to distinguish
a constant from a variable so we chose to
follow the most used convention: a all-upper-case
name is a constant, everything else is a variable:
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

Is it still possible to disable constants this way:
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

## How to use namespaces in a pug template?

By default, templates are executed with no namespace
and so you need to write full paths to access
functions and classes:

```pug
p=\SomeWhere\somefunction()
p=call_from_root_namespace()
- $a = new \SomeWhere\SomeClass()
```
<i data-options='{"mode":"format"}'></i>

You cannot set a namespace at the beginning of a pug
template as it is not the beginning of the PHP compiled
file (we prepend debug stuff, dependencies, mixins
functions, etc.)

However you can apply globally a namespace to
all templates this way:

```php
Phug::setOption('on_output', function (OutputEvent $event) {
  $event->setOutput(
    '<?php namespace SomeWhere; ?>'.
    $event->getOutput()
  );
});
```

With this output event interceptor, the previous code become:

```pug
p=somefunction()
p=\call_from_root_namespace()
- $a = new SomeClass()
```
<i data-options='{"mode":"format"}'></i>
