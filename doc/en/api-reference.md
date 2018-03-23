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

Behave like `displayFile` but takes pug source code as first
argument:
```php
$template = '
div: p.examples
  em Foo
  strong(title="Bar") Bar
';


// Facade way (with Phug)
Phug::display($template, $localVariables, $options);


// Instance way (with Phug)
$renderer = new Phug\Renderer($options);
$renderer->display($template, $localVariables);


// Facade way (with Pug-php)
Pug\Facade::displayString($template, $localVariables, $options);


// Instance way (with Pug-php)
$renderer = new Pug($options);
$renderer->displayString($template, $localVariables);
```

Note: If you use **Pug-php**, it will try to detect if the given
string is a file
path and fallback on `displayFile`. This behavior is for backward
compatibility but you're encouraged to disabled it by setting
the `"strict"` option to `true` or use `displayString`.

## renderFile

`renderFile` is the same as `displayFile` but returns the output
instead of display it.

## render

`render` is the same as `display` but returns the output
instead of display it.

Note: If you use **Pug-php**, it will try to detect if the given
string is a file
path and fallback on `renderFile`. This behavior is for backward
compatibility but you're encouraged to disabled it by setting
the `"strict"` option to `true` or use `renderString`.

## renderAndWriteFile

Render a pug file then write the final result (often the HTML)
in a file.

Returns `true` in case of success, `false` else.

```php
$input = '/mon/fichier/template.pug';
$output = '/ma/page.html';
$variablesLocales = [
  'nomDeVariable' => 'valeur',
];
$options = [/* ... */];


// Facade way (with Phug)
Phug::setOptions($options);
if (Phug::renderAndWriteFile($input, $output, $localVariables)) {
  echo 'File written successfully.';
}


// Instance way (with Phug)
$renderer = new Phug\Renderer($options);
if ($renderer->renderAndWriteFile($input, $output, $localVariables)) {
  echo 'File written successfully.';
}


// Facade way (with Pug-php)
Pug\Facade::setOptions($options);
Pug\Facade::renderAndWriteFile($input, $output, $localVariables)) {
  echo 'File written successfully.';
}


// Instance way (with Pug-php)
$renderer = new Pug($options);
if ($renderer->renderAndWriteFile($input, $output, $localVariables)) {
  echo 'File written successfully.';
}
```

## renderDirectory

Render all pug template files (recursively) in an input directory and output in an output directory.
If no output directory specified, the same directory is used for input and output.

Returns an array with success count and error count.

```php
$renderer = new Phug\Renderer($options); // or $renderer = new Pug($options);

$renderer->renderDirectory('./my-views'); // render with no local variables all templates in ./my-views
                                          // and write .html files next to pug files
$renderer->renderDirectory('./my-views', ['foo' => 'bar']); // the same with local variables
$renderer->renderDirectory('./my-views', './my-pages'); // render with no local variables all templates in ./my-views
                                                       // and write .html files in ./my-pages
$renderer->renderDirectory('./my-views', './my-pages', ['foo' => 'bar']); // the same with local variables
$renderer->renderDirectory('./my-views', './my-pages', '.xml'); // use .xml extension instead of the default .html
$renderer->renderDirectory('./my-views', './my-pages', '.xml', ['foo' => 'bar']); // the same with local variables
```

## compileFile

Compile a file and return the rendering code. It means when
`renderFile` typically returns HTML, `compileFile` mostly returns
PHP, by executing this PHP code, you would get the final HTML.

This may allow you for example to delegate the view rendering
and caching to an other engine/framework.

```php
$template = '/my/template/file.pug';
$options = [
  // only compilation options, since rendering options
  // will not be used.
];

// Facade way (with Phug)
Phug::setOptions($options);
Phug::compileFile($template);


// Instance way (with Phug)
$renderer = new Phug\Renderer($options);
$renderer->compileFile($template);


// Facade way (with Pug-php)
Pug\Facade::setOptions($options);
Pug\Facade::compileFile($template);


// Instance way (with Pug-php)
$renderer = new Pug($options);
$renderer->compileFile($template);
```

## compile

Behave like `compileFile` but takes pug source code as first
argument.

## cacheFile

Compile a pug file and save it in the cache directory specified
via the options.

## cacheFileIfChanged

Compile a pug file and save it in the cache directory specified
via the options except if an up-to-date file is already present
in it.

## cacheDirectory

Cache all pug files (recursively) in the directory passed as
argument.

## Advanced methods

See the [complete API documentation](/api/namespaces/Phug.html).
