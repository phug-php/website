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

## Advanced methods

See the [complete API documentation](/api/namespaces/Phug.html).
