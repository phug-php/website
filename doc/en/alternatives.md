# Alternatives

It exists alternative ways to get pug templates with a PHP back-end.

## V8Js

http://php.net/manual/fr/book.v8js.php

You can run the V8 engine from PHP. You might need to use the
`setModuleLoader` to require the pug node module and its
dependencies in an automated way.

Then you could require the native pug engine with `executeString`
and call pug using PHP data. That could be a very fast way to
get the exact pugjs behavior with PHP data.

As far as we know, no such wrapper out-of-the-box yet exists.
If you made or know one, please use the button [Edit] to
submit a pull-request.

## Pug-php with pugjs option

When you install **Pug-php**, you will be asked for installing
**pug-cli** node package. If you enter `Y`, it will use `npm`
if available on the machine to install the official `pug-cli`
package, and **Pug-php** has an option to use it instead of
its own engine:

```php
<?php

include 'vendor/autoload.php';

$pug = new Pug([
  'pugjs' => true,
]);

$html = $pug->render('p=9..toString()');
```

Here you call the native pug package using directly node.js,
that's why you can use any JS syntax.

If you do this, be aware we are not responsible of what happens
inside templates, it's no longer PHP used and the documentation
to refer to is https://pugjs.org

Optionally, you can specify the path to the node and pug-cli
programs with following tools:

```php
$pug = new Pug([
  'pugjs' => true,
  'nodePath' => __DIR__ . '/../bin/node',
]);
NodejsPhpFallback::setModulePath('pug-cli', __DIR__ . '/../node_modules/pug-cli');
```
