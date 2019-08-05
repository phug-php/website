# Frequently asked questions

## Why do I get error with UPPER_CASE variables?

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
&lt;?php

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

## How to handle internationalization?

Translations functions such as `__()` in Laravel or
`_()` with gettext can be called as any other function
in expressions and codes.

The gettext parser does not support pug files but the
python mode give pretty good results with pug files.

Init method such as `textdomain` can be called in a simple
code block: `- textdomain("domain")` for example as
your first file line.

Last, be sure all needed extension (such as gettext)
is well installed on the PHP instance that render your
pug files.

## How to clear the cache?

If you use [laravel-pug](https://github.com/BKWLD/laravel-pug)
the cache is handled by Laralve and so you can refer to the
framework documentation for cache operations. Empty it
for example can be done with `php artisan cache:clear`

Else in production, you should use the
[cache-directory command](/#compile-directory-or-cache-directory)
and disable `up_to_date_check` option.

In development environment, if you have any trouble
with the cache, you can just safely disable cache
with some code like this:

```php
Phug::setOption('cache', $prod ? 'cache/directory' : false);
```

## What is the equivalent of Twig filter?

If you know Twig, you may know this syntax:
```html
<div>{{ param1 | filter(param2, param3) }}</div>
```

Or if you know AngularJS, those filters:
```html
<div>{{ param1 | filter : param2 : param3 }}</div>
```

Pug filters are a bit different since there are
allowed only outside expressions:
```html
div
  :filter(param2=param2 param3=param3)
    param1
```
Inside tag content, it's technically usable even
if this syntax would not be so relevant in this case.

For attributes values or inside mixin arguments,
there is no such thing like filters available
because simple functions works just fine:

```html
<div>{{ filter(param1, param2, param3) }}</div>
```

Twig/AngularJS filters are nothing more than
a first argument-function name swap. Most of Twig
filters are available as native PHP functions
(split: explode, replace:
strtr, nl2br: nl2br, etc.).

Moreover, you can pass functions as closures
inside your locals or the shared variables.

And remember the `|` yet exists in PHP, it's the
*OR* bitwise operator.

## How to solve `Warning: include() read X bytes more data than requested (Y read, Z max)`?

This happens probably because you have the
php.ini `mbstring.func_overload` settings
with the `2` flag on.

As it's an obsolete setting, the best thing
to do is to set it to `0` and replace manually
functions in your app rather than overload them.

If you really need to keep this setting, you
can still use the *FileAdapter* that will not
have this problem:

```php
Phug::setOption('adapter_class_name', FileAdapter::class);
```

## How to solve `Maximum function nesting level of 'X' reached`?

This error means you overhead the `xdebug.max_nesting_level`
php.ini setting. The default value is 100 and it might
be not enough. With many includes and nested mixins
call in your pug template, you could reach 500 nesting
level. So first, try to increase this setting.

If you still get this error, then you probably
have an infinite recursion. It can happen in pug when
a template `a.pug` include `b.pug` then `b.pug`
include `a.pug` or directly `a.pug` including
`a.pug` (obviously the same goes for PHP
files). If you do not have conditions to avoid the
recursion to be infinite, you will get a *nesting level*
error, or a timeout exceeded. It can also happen
when a mixin calls it self (or indirectly via
other mixins) or the same with PHP functions.

Note: xdebug is a debug extension, so don't forget to
disable it in production.

## Should I use `render` or `renderFile`?

In old versions of **Pug-php**, only was the `render` method that
rendered a file if the given argument matched an existing file,
else it rendered as pug string. While **Tale-pug** always rendered
a file.

None of these behaviour was consistent with **Pugjs** so we chose
to change it in **Phug**. With **Phug**, `render` only take
strings, no file, and `renderFile` has been added to render
files.

**Pug-php** keep the old behaviour for the moment to ease the
upgrade but you're strongly encouraged to use the `strict` option
to get the new behaviour:
```php
$pug = new Pug([
  'strict' => true,
]);
```
This way `$pug->render()` will always take first argument as
a pug string no matter it mach a file path or not. This can
avoid some unexpected behaviors.

If for some backward compatibility reason, you can't use this
option, then you should avoid using `render` and use
`renderString` for a pug string and `renderFile` for a
file.

## How to debug a code from the documentation not working in my app?

First, we assume you use the last version of **Phug**
(or **Pug-php** >= 3).

You can check your **Phug** version with
`composer show phug/phug`
and update it with:
`composer update`

Last **Phug** stable version is
[![Latest Stable Version](https://camo.githubusercontent.com/9ff236cbfba46cf8c9a6be7502a500f1bb09bd52/68747470733a2f2f706f7365722e707567782e6f72672f706875672f706875672f762f737461626c652e706e67)](https://packagist.org/packages/phug/phug)

If you're using a version < 3.0 of **Pug-php**
(check it with `composer show phug/phug`)
this documentation is not accurate for your and
you're strongly encouraged to upgrade to **Pug-php**
[![Latest Stable Version](https://camo.githubusercontent.com/8d24c2c0b2fd374bda61453ce6c4293af68f7f88/68747470733a2f2f706f7365722e707567782e6f72672f7075672d7068702f7075672f762f737461626c652e706e67)](https://packagist.org/packages/pug-php/pug)

If you're using **Tale-jade** or **Tale-pug**,
you're advised to migrate to **Phug**.

Then, examples in this documentation are for **Phug**
if not specified otherwise. If you're using **Pug-php**
you have to adapt it. For example:
```php
Phug::setOption('cache_dir', 'directory');
Phug::display('template.pug', $vars);
```

Should have to be written as one of these 2 syntaxes
to get **Pug-php** features working:
```php
\Pug\Facade::setOption('cache_dir', 'directory');
\Pug\Facade::display('template.pug', $vars);
```

`\Pug\Facade` allow to replace easily `Phug`
keeping the same syntax. But you could prefer
the instance syntax:
```php
$pug = new Pug([
  'cache_dir' => 'directory',
]);
$pug->display('template.pug', $vars);
```
