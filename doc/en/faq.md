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

## How to run JS scripts inside templates?

There are different possible approaches:

- First of all, avoid mixing PHP and JS in your back-end
so if you already have a PHP app and find some node.js
package you would use, check there is no equivalent in PHP.

- If you don't need to call PHP functions/methods/objects
in your templates, then you can use the native npm pugjs
package. **Pug-php** have a wrapper for that:
```php
<?php

use Pug\Pug;

include 'vendor/autoload.php';

$pug = new Pug([
    'pugjs' => true,
]);

// Phug engine skipped, pugjs used instead
$pug->display('p=9..toString()');

// So this way, you can `require` any JS file or npm package:
$pug->display('
- moment = require("moment")
p=moment("20111031", "YYYYMMDD").fromNow()
');
```

- You can pass a helper function as any other variable via
`share` or `render` that can call a CLI program (so node or
anything else):
```php
$pug->share('dateDisplay', function ($date) {
    return shell_exec('node your-js-script.js ' . escapeshellarg($date));
});
```

- You can use the V8Js engine
(http://php.net/manual/en/book.v8js.php):
```php
$pug->share('dateDisplay', function ($date) {
    $v8 = new V8Js('values', array('date' => '2016-05-09'));

    return $v8->executeString('callJsFunction(values.date)');
});
```

## How to use helper functions with pugjs engine?

When you use **Pug-php** with `pugjs` option to `true` all
the data you pass to the view is encoded as JSON. So you loose
your class typing and you loose closures functions.

Nevertheless, you can write JS functions inside you templates
and use any local or shared variable in it :
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

## How to disable errors on production?

In production, you should set the `debug` option to `false`.
Then you should have a global exception handler for your PHP
application to hide errors from the user.

Best practice would be to log them (in a file for example)
using exception handler
(see [set_exception_handler](http://php.net/manual/en/function.set-exception-handler.php)).

A more radical way is to hide them completely with
`error_reporting(0);` or the same setting in **php.ini**.

## How to includes files dynamically?

The include and extend statements only allow static paths:
`include myFile` but disallow dynamic imports such as:
`include $myVariable`.

But custom keyword come to the rescue:
```php
Phug::addKeyword('dyninclude', function ($args) {
    return array(
        'beginPhp' => 'echo file_get_contents(' . $args . ');',
    );
});
```

This allow to include files as raw text:

```pug
- $styleFile = 'foo.css'
- $scriptFile = 'foo.js'

style
  // Include foo.css as inline content
  dyninclude $styleFile
  
script
  // Include foo.js as inline content
  dyninclude $scriptFile
```
<i data-options='{"static": true}'></i>

Warning: you must be sure of the variables content. If
`$styleFile` contains `"../../config.php"` and if `config.php`
contains some DB passwords, session secret, etc. it will
disclose those private information.

You must be even more prudent if you allow to include PHP
files:
```php
Phug::addKeyword('phpinclude', function ($args) {
    return array(
        'beginPhp' => 'include ' . $args . ';',
    );
});
```

It can be helpful and safe, for example if you do:
```pug
each $module in $userModules
  - $module = 'modules/'.preg_replace('/[^a-zA-Z0-9_-]/', '', $module).'.php'
  phpinclude $module
```
<i data-options='{"static": true}'></i>

In this example, by removing all characters except letters,
digits and dashes, no matter what contains `$userModules`
and where it come from, you're sure it can only include
an existing file from the directory *modules*. So you
just have to check what you put in this directory.

Finally you can also include files dynamically and render
them with **Phug** (or any transformer):
```php
Phug::addKeyword('puginclude', function ($args) {
    return array(
        'beginPhp' => 'Phug::display((' . $args . ') . ".pug");',
    );
});
```

```pug
- $path = '../dossier/template'
puginclude $path
```
<i data-options='{"static": true}'></i>

It includes `../directory/template.pug` as we concat
the extension in the keyword callback.
