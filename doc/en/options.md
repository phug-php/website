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
```
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
```
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

```
...
ine: 3
Offset: 1
Path: something.pug 
```

The same goes for `compileFile`, `renderFile` and `displayFile`:

```php
Phug::displayFile('something.pug');
```

```
...
ine: 3
Offset: 1
Path: something.pug 
```
