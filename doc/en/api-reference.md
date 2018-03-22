# API reference

This is a summary of main methods available. You also
can view the auto-generated documentation by clicking
the link below:

[Complete API documentation](/api/namespaces/Phug.html)

## displayFile

```php
$template = '/my/template/file.pug';
$localVariables = [
  'variableName' => 'value',
];
$options = [
  'cache_dir' => '/path/to/a/cache/folder',
];


// Facade way (with Phug)
Phug::displayFile($template, $localVariables, $options);


// Instance way (with Phug)
$renderer = new Phug\Renderer($options);
$renderer->displayFile($template, $localVariables);


// Facade way (with Pug-php)
Pug\Facade::displayFile($template, $localVariables, $options);


// Instance way (with Pug-php)
$renderer = new Pug($options);
$renderer->displayFile($template, $localVariables);
```

This output the renderer template file given to the standard
output. This is the recommended way to use **Phug**.

Check the [usage section](#usage) to see how to optimize it
in production.

Check the [options section](#options) to see the complete list
of available options.

## display

Behave like `displayFile` but take pug source code as first
argument:
```php
$template = '
div: p.examples
  em Foo
  strong(title="Bar") Bar
';
Phug::display($template, $localVariables, $options);
```

Note: If you use **Pug-php**, it will try to detect if the given
string is a file
path and fallback on `displayFile`. This behavior is for backward
compatibility but you're encouraged to disabled it by setting
the `"strict"` option to `true`.

## Advanced methods

See the [complete API documentation](/api/namespaces/Phug.html).
