# Options

## Equivalents for pugjs options

### filename `string`

The name of the file being compiled. This is used if no file specified for
path resolve and exception file detail:

```php
Phug::compile("\n  broken\nindent");
```

By default, when you `compile`, `render` or `display` an input string,
**Phug** give no source file info in exception and cannot resolve relative
include/extend.
```yaml
Failed to parse: Failed to outdent: No parent to outdent to. Seems the parser moved out too many levels.
Near: indent

Line: 3
Offset: 1 
```

With the **filename** option, it provides a fallback:

```php
Phug::setOption('filename', 'foobar.pug');
Phug::compile("\n  broken\nindent");
```
```yaml
...
Line: 3
Offset: 1
Path: foobar.pug
```

But, this option is ignored if you specify locally the filename:

```php
Phug::setOption('filename', 'foobar.pug');
Phug::compile("\n  broken\nindent", 'something.pug');
```
```yaml
...
Line: 3
Offset: 1
Path: something.pug 
```

The same goes for `compileFile`, `renderFile` and `displayFile`:

```php
Phug::displayFile('something.pug');
```
```yaml
...
Line: 3
Offset: 1
Path: something.pug 
```

### basedir `string`

The root directory of all absolute inclusion. This option is
supported for **pugjs** compatibility reason, but we recommend you
to use the [paths](#paths-array) option instead. It has the same
purpose but you can specify an array of directories that will
be all tried (in the order you give them) to resolve
absolute path on `include`/`extend` and the first found
is used.

### doctype `string`

If the `doctype` is not specified as part of the template, you
can specify it here. It is sometimes useful to get self-closing
tags and remove mirroring of boolean attributes. See
[doctype documentation](#doctype-option)
for more information.

### pretty `boolean | string`

[Deprecated.] Adds whitespace to the resulting HTML to make it
easier for a human to read using `'  '` as indentation. If a
string is specified, that will be used as indentation instead
(e.g. `'\t'`). We strongly recommend against using this option.
Too often, it creates subtle bugs in your templates because
of the way it alters the interpretation and rendering of
whitespace, and so this feature is going to be removed.
Defaults to `false`.

### filters `array`

Associative array of custom filters. Defaults to `[]`.
```php
Phug::setOption('filters', [
  'my-filter' => function ($text) {
    return strtoupper($text);
  },
]);
Phug::render("div\n  :my-filter\n    My text");
```
Returns:
```html
<div>MY TEXT</div>
```

You can also use the method `setFilter` and your callback
can take options:

```php
Phug::setFilter('add', function ($text, $options) {
  return $text + $options['value'];
});
Phug::render("div\n  :add(value=4) 5");
```
Returns:
```html
<div>9</div>
```

And note that you can also use callable classes (classes
that contains an `__invoke` method) instead of a simple
callback function for your custom filters.

### self `boolean | string`

Use a `self` namespace to hold the locals. Instead of
writing `variable` you will have to write
`self.variable` to access a property
of the locals object. Defaults to `false`.

```php
Phug::setOption('self', true);
Phug::render('p=self.message', [
    'message' => 'Hello',
]);
```
Will output:
```html
<p>Hello</p>
```

And you can pass any string as namespace as long as it's
a valid variable name, so the following is equivalent:
```php
Phug::setOption('self', 'banana');
Phug::render('p=banana.message', [
    'message' => 'Hello',
]);
```

### debug `boolean`

If set to `true`, when an error occurs at render time, you
will get a complete stack trace including line and offset
in the original pug source file.

In production, you should set it to `false` to fasten
the rendering and hide debug information. It's done
automatically if you use framework adapters such as
[pug-symfony](https://github.com/pug-php/pug-symfony) or
[laravel-pug](https://github.com/BKWLD/laravel-pug).

### shared_variables / globals `array`

List of variables stored globally to be available for
any further calls to `render`, `renderFile`, `display`
or `displayFile`.

`globals` and `shared_variables` are 2 different options
merged together, `globals` only exists to provide an
equivalent to the **pugjs** option. And methods like `->share`
and `->resetSharedVariables` only impact the the
`shared_variables` option, so we recommend you to use
`shared_variables`.

```php
Phug::setOptions([
    'globals' => [
        'top' => 1,
        'right' => 1,
        'bottom' => 1,
        'left' => 1,
    ],
    'shared_variables' => [
        'right' => 2,
        'bottom' => 2,
        'left' => 2,
    ],
]);

Phug::share([
    'bottom' => 3,
    'left' => 3,
]);

Phug::display('="$top, $right, $bottom, $left"', [
    'left' => 4,
]);

Phug::resetSharedVariables();

Phug::display('="$top, $right, $bottom, $left"', [
    'left' => 5,
]);
```

The first `display` will outputs:
```
1, 2, 3, 4
```

The second `display` will outputs:
```
1, 1, 1, 5
```

As you can note in this examples, locals always have the
precedence and `shared_variables` has the precedence
on `globals`.

The same code would look like this using **pug-php**:

```php
$pug = new Pug([
    'globals' => [
        'top' => 1,
        'right' => 1,
        'bottom' => 1,
        'left' => 1,
    ],
    'shared_variables' => [
        'right' => 2,
        'bottom' => 2,
        'left' => 2,
    ],
]);

// or $pug->setOptions([...])

$pug->share([
    'bottom' => 3,
    'left' => 3,
]);

$pug->display('=top + ", " + right + ", " + bottom + ", " + left', [
    'left' => 4,
]);

$pug->resetSharedVariables();

$pug->display('=top + ", " + right + ", " + bottom + ", " + left', [
    'left' => 5,
]);
```

### cache_dir `boolean | string`

If set to `true`, compiled templates are cached. `filename`
must be set as the cache key (automatically done when using
`renderFile` or `displayFile`). Defaults to `false`.

This option can also be a directory path where cached files
will be stored.

This option is automatically handled
when you use framework adapters such as
[pug-symfony](https://github.com/pug-php/pug-symfony) or
[laravel-pug](https://github.com/BKWLD/laravel-pug).

**pug-php** also provide a `cache` alias for this option
to match **pug-php** 2 and **pugjs** options. It can also
provide a better semantic when using boolean value, and
`cache_dir` stay more appropriate when passing a string.

