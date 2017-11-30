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
supported for pugjs compatibility reason, but we recommend you
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
