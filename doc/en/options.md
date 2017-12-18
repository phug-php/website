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

Note: the XML doctype can break when open short tags are enabled,
that's why by default, we replace `<?xml` with `<<?= "?" ?>xml`
when `short_open_tag` or `hhvm.enable_short_tags` is `On`
(this is the behavior when `short_open_tag_fix` option is
set to its default value: `"auto"`) but you can switch this option
to `true` (to always enable the fix) or `false` (to always
disable it).

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

See [compile-directory command](#compile-directory-or-cache-directory)
to cache a whole directory.

We recommend to use this command when you deploy your
applications in production, it also allow you to set
the option [up_to_date_check](#up_to_date_check-boolean)
to `false` and get better performance.

## Language

### paths `array`

Specify list of paths to be used for `include` and `extend`
with absolute paths. Example:
```php
Phug::setOption('paths', [
  __DIR__.'/bundle-foo',
  __DIR__.'/resources/views',
]);

Phug::render('include /directory/file.pug');
```

As `/directory/file.pug` starts with a slash, it's considered
as an absolute path. Phug will first try to find it in the first
directory you specified: `__DIR__.'/bundle-foo'`, if it does
not exist in it, it will search in the next
`__DIR__.'/resources/views'`.

### extensions `array`

List of file extensions Phug will consider as pug files.
`['', '.pug', '.jade']` by default.

This means:
```pug
//- my-file.pug
p Foo
```
```js
// non-pug-file.js
alert('foo');
```

```pug
//- index.pug
//-
  my-file.pug can be imported (included or extended)
  with or without extension, and its content will be
  parsed as pug content.
  (cannot be tested in this live editor as includes
  are emulated)
include my-file.pug
//- include my-file
//-
  non-pug-file.js will be included as text
include non-pug-file.js
```

So the `extensions` extension allow you to pass an other
list of extensions to be handled by Phug and added
automatically to include/extend paths if missing.

### default_doctype `string`

Doctype to use if not specified as argument.
`"html"` by default.

This means:
```phug
doctype
//- will automatically fallback to:
doctype html
```

### default_tag `string`

By default, when you do not specify a tag name, **Phug**
fallback to a `div` tag:
```phug
.foo
#bar(a="b")
(c="d") Hello
```
The same code with `Phug::setOption('default_tag', 'section')`
would render as:
```html
<section class="foo"></section>
<section id="bar" a="b"></section>
<section c="d">Hello</section>
```

### attributes_mapping `array`

This option allow you to replace attributes by others:
```php
Phug::setOption('attributes_mapping', [
  'foo' => 'bar',
  'bar' => 'foo',
  'biz' => 'zut',
]);
Phug::display('p(foo="1" bar="2" biz="3" zut="4" hop="5")');
```
Will output:
```html
<p bar="1" foo="2" zut="3" zut="4" hop="5"></p>
```

## Profiling

**Phug** embed a profiler module to watch, debug or limit
memory consumption and execution time.

### memory_limit `integer`

Set a memory limit usage. `-1` by default would mean
*no limit*. But if the [debug](#debug-boolean) option is
`true`,
it automatically pass to `50*1024*1024` (50MB).

If the profiler detect the memory usage exceed the limit,
it will throw an exception. But be aware, if this limit
is greater than the machine limit or the PHP limit, the Phug
limit will have no effect. 

### execution_max_time `integer`

Set an execution time limit. `-1` by default would mean
*no limit*. But if the [debug](#debug-boolean) option is
`true`,
it automatically pass to `30*1000` (30 seconds).

If the profiler detect Phug is running for a longer
time than the specified limit, it will throw an
exception. But be aware, if this limit is greater than
the PHP limit,
the Phug limit will have no effect. 

### enable_profiler `boolean`

When set to `true`, it will output on render a timeline
you can inspect in your browser to see wich token/node
take longer to lex/parse/compile/render.

When enabled, it comes with a subset of options you can
also edit, these are the default values:
```php
'profiler' => [
    'time_precision' => 3,     // time decimal precision
    'line_height'    => 30,    // timeline height
    'display'        => true,  // output the result
                               // can be true or false
    'log'            => false, // log the result in a file
                               // can be a file path or false
],
```

## Errors

### error_handler `callable`

Set a callback method to handle Phug exceptions.
`null` by default.

### html_error `boolean`

Display errors as HTML (by default, it's `false` when run
on CLI, `true` when run in browser).

### color_support `boolean`

Used to enable color in CLI errors output, by default
we will try to detect if the console used support colors.

### error_context_lines `integer`

We give you some context on error code dump, `7` lines
above and below the error line by default. But you can
pass to this option any number to get more or less
context.

## Events

Events are a very useful way to intercept different process
steps to get, change or manipulate objects and parameters.

Example:
```php
$renderer = new \Phug\Renderer([
    'on_render' => function (\Phug\Renderer\Event\RenderEvent $event) {
        // Get current parameters
        $parameters = $event->getParameters();
        // If you pass laurel in your parameters
        if (isset($parameters['laurel'])) {
            // Then you will need hardy
            $parameters['hardy'] = '45 Minutes from Hollywood';
        }

        // Set new parameters
        $event->setParameters($parameters);
    },
]);

$renderer->display('p=$hardy', [
    'laurel' => true,
]);
```
Will output:
```html
<p>45 Minutes from Hollywood</p>
```

The same works with **pug-php**:
```php
$renderer = new Pug([
    'on_render' => function (\Phug\Renderer\Event\RenderEvent $event) {
        // Get new parameters
        $parameters = $event->getParameters();
        // If you pass laurel in your parameters
        if (isset($parameters['laurel'])) {
            // Then you will need hardy
            $parameters['hardy'] = '45 Minutes from Hollywood';
        }

        // Set new parameters
        $event->setParameters($parameters);
    },
]);

$renderer->display('p=hardy', [
    'laurel' => true,
]);
```

Note that all **on_&#42;** options are initial options, it means
you cannot set them after renderer initialization or using the
facade (`Phug::setOption()` or `Pug\Facade::setOption()`).

However, you can attach/detach events this way (using facade or
not):
```php
function appendHardy(\Phug\Renderer\Event\RenderEvent $event) {
    // Get new parameters
    $parameters = $event->getParameters();
    // If you pass laurel in your parameters
    if (isset($parameters['laurel'])) {
        // Then you will need hardy
        $parameters['hardy'] = '45 Minutes from Hollywood';
    }

    // Set new parameters
    $event->setParameters($parameters);
}

Phug::attach(\Phug\RendererEvent::RENDER, 'appendHardy');

Phug::display('p=$hardy', [
    'laurel' => true,
]);

Phug::detach(\Phug\RendererEvent::RENDER, 'appendHardy');

Phug::display('p=$hardy', [
    'laurel' => true,
]);
```

Will output `<p>45 Minutes from Hollywood</p>` then `<p></p>`.

So for all the **on_&#42;** options below, we will give you
the initial option name, the event constant (to attach/detach)
and the event class with a link to the API documentation that
give you all methods available for this event (all values you
can get and set).

### on_render `callable`

Is triggered before a file or a string being rendered or displayed.

In some cases you may hesitate between **on_render** and
**on_compile**, you should maybe check
[on_compile option](#on-compile-callable).

Event constant: `\Phug\RendererEvent::RENDER`

Event type: [`\Phug\Renderer\Event\RenderEvent`](https://phug-lang.com/api/classes/Phug.Renderer.Event.RenderEvent.html#method___construct)

Parameters you can get/set:
- input: input string if `render`/`display` has been called
- path: input file if `renderFile`/`displayFile` has been called
- method: the method that have been called `"render"`, `"display"`,
`"renderFile"` or `"displayFile"`.
- parameters: local variables passed for the view rendering

### on_html `callable`

Is triggered after a file or a string being rendered or displayed.

Event constant: `\Phug\RendererEvent::HTML`

Event type: [`\Phug\Renderer\Event\HtmlEvent`](https://phug-lang.com/api/classes/Phug.Renderer.Event.HtmlEvent.html#method___construct)

Parameters you can get/set:
- renderEvent: link to the initial RenderEvent (see above)
- result: returned result (by `render` or `renderFile`)
- buffer: output buffer (what `display` or `displayFile` is
about to display) typically the HTML code, but can be XML
or any custom format implemented
- error: the exception caught if an error occured

### on_compile `callable`

Is triggered before a file or a string being compiled.

This option is different from **on_render** in the following
points:
- `compile()` and `compileFile()` methods will trigger a compile
event but not the render event,
- compile event is triggered after the render event,
- and render and display methods will always trigger a render
event but will trigger a compile event only except when
compiled template is served from cache (cache settings in use
and template up to date).

The compile process transform pug code into PHP code that
is always the same for a given template no matter the locals
values, when render
process execute that PHP code to get HTML, XML or any final
output with locals replaced with their values. That's why
the render event also have **parameters** with locals
variables values you can get and set.

Event constant: `\Phug\CompilerEvent::COMPILE`

Event type: [`\Phug\Compiler\Event\CompileEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.CompileEvent.html#method___construct)

Parameters you can get/set:
- input: input string/source file content
- path: input file if `compileFile`/`renderFile`/`displayFile`
has been called

### on_output `callable`

Is triggered after a file or a string being compiled.

Event constant: `\Phug\CompilerEvent::OUTPUT`

Event type: [`\Phug\Compiler\Event\OutputEvent`](https://phug-lang.com/api/classes/Phug.Compiler.Event.OutputEvent.html#method___construct)

Parameters you can get/set:
- compileEvent: link to the initial CompileEvent (see above)
- output: output PHP code that can be executed to get the
final output
