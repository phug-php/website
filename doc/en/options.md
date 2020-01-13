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
over `globals`.

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

### detailed_dump `boolean`

The lexer, the parser and the compiler all have a `->dump()`
method that allow you to see the state of each process.

By setting detailed_dump to `true` you can dump more
details (right now this option is only available for
the parser).

## Errors

### error_reporting `callable | int`

Allow to handle PHP errors display that comes up during the
template execution. By default, errors raised by current
PHP setting (see
[error_reporting](php.net/manual/en/function.error-reporting))
are turned into exception Phug is able to trace the origine
in the template pug code. Other errors are hidden.

You can pass an custom error level that will override
the PHP setting.
```php
$renderer = new Renderer([
    'error_reporting' => E_ALL ^ E_NOTICE,
]);

$renderer->render('p=$foo["bar"]', ['foo' => []]);
// Outputs <p></p> since E_NOTICE are ignored

$renderer = new Renderer([
    'error_reporting' => E_ALL,
]);

$renderer->render('p=$foo["bar"]', ['foo' => []]);
// Throws an E_NOTICE error wrapped in Phug exception
```

You also can pass a callback for a finest handling:
```php
$renderer = new Renderer([
    'error_reporting' => function ($number, $message, $file, $line) {
        if (strpos($message, 'hidden') !== false) {
            return null; // No errors displayed
        }

        if ($number === E_NOTICE) {
            return false; // Display the error in the template
        }

        // Stop the execution and throws an exception for any other error
        throw new \ErrorException($message, 0, $number, $file, $line);
    },
]);
```

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

### exit_on_error

When `debug` option is `true`, errors not handled will
quit the process using `exit(1)`, to disable this behavior,
your can set the option `exit_on_error` to `false`.

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

Before listing all the events, here is a overview of the
processes timeline:

![Phug processes timeline](/img/pug-processes.png)

Plain lines are active process, dotted line are waiting for
an other process.

So you can see the rendering start event will be triggered
before other events even if the real active rendering
process only start after all other processes end.

The same goes for compilation that first wait for the parser
to give him the complete nodes tree before starting the
active compilation, then it will wait for the formatting
process before calling the output event.

Parsing, lexing and reading are parallel processes, the
reader identify string chunk such as 2 spaces at the beginning
of the line, the lexer convert this string into a indent
token, then so parser know it have to enter one level and
append next nodes as children of the upper node. Then
this process is repeated token by token until all the
input string is consumed.

### on_render `callable`

Is triggered before a file or a string being rendered or displayed.

In some cases you may hesitate between **on_render** and
**on_compile**, you should maybe check
[on_compile option](#on-compile-callable).

Event constant: `\Phug\RendererEvent::RENDER`

Event type: [`\Phug\Renderer\Event\RenderEvent`](/api/classes/Phug.Renderer.Event.RenderEvent.html#method___construct)

Parameters you can get/set:
- input: input string if `render`/`display` has been called
- path: input file if `renderFile`/`displayFile` has been called
- method: the method that have been called `"render"`, `"display"`,
`"renderFile"` or `"displayFile"`.
- parameters: local variables passed for the view rendering

### on_html `callable`

Is triggered after a file or a string being rendered or displayed.

Event constant: `\Phug\RendererEvent::HTML`

Event type: [`\Phug\Renderer\Event\HtmlEvent`](/api/classes/Phug.Renderer.Event.HtmlEvent.html#method___construct)

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

Event type: [`\Phug\Compiler\Event\CompileEvent`](/api/classes/Phug.Compiler.Event.CompileEvent.html#method___construct)

Parameters you can get/set:
- input: input string/source file content
- path: input file if `compileFile`/`renderFile`/`displayFile`
has been called

### on_output `callable`

Is triggered after a file or a string being compiled.

Event constant: `\Phug\CompilerEvent::OUTPUT`

Event type: [`\Phug\Compiler\Event\OutputEvent`](/api/classes/Phug.Compiler.Event.OutputEvent.html#method___construct)

Parameters you can get/set:
- compileEvent: link to the initial CompileEvent (see above)
- output: output PHP code that can be executed to get the
final output

### on_node `callable`

Is triggered for each node before its compilation.

To well understand what is a node, you can use the **parse**
mode of the live editor, here is an example:
```phug
doctype
html
  head
    title=$var
  body
    h1 Text
    footer
      | Text
      =date('Y')
```
<i data-options='{"mode":"parse"}'></i>

You can see the **Phug** parser transform the pug code into
a tree of nodes. Then the compiler will compile each of these
nodes into elements recursively. And the formatter will turn
the tree of elements into the compiled PHP code.

Event constant: `\Phug\CompilerEvent::NODE`

Event type: [`\Phug\Compiler\Event\NodeEvent`](/api/classes/Phug.Compiler.Event.NodeEvent.html#method___construct)

Parameters you can get/set:
- node: the node instance created by the parser that is
about to be compiled

### on_element `callable`

Is triggered for each node after its compilation.

Event constant: `\Phug\CompilerEvent::ELEMENT`

Event type: [`\Phug\Compiler\Event\ElementEvent`](/api/classes/Phug.Compiler.Event.ElementEvent.html#method___construct)

Parameters you can get/set:
- nodeEvent: link to the initial NodeEvent (see above)
- element: the compiled element

### on_format `callable`

Is triggered for each element before being formatted.

The formatting step is a process that take elements tree
(output object representation as stored after the compilation,
not to be confused with the nodes tree that represent the
input and is given by the parsing before the compilation)
and convert these elements into a compiled PHP capable
to render them.

The formatting is recursive, when passing an element, it
also format its children inside.

#### Before formatting process
```phug
p=$var
```
<i data-options='{"mode":"compile"}'></i>
#### After formatting process
```phug
p=$var
```
<i data-options='{"mode":"format"}'></i>

Event constant: `\Phug\FormatterEvent::FORMAT`

Event type: [`\Phug\Formatter\Event\FormatEvent`](/api/classes/Phug.Formatter.Event.FormatEvent.html#method___construct)

Parameters you can get/set:
- element: the compiled element (implements ElementInterface)
- format: the format in use (implements FormatInterface)
will be by default BasicFormat or the format set for your
doctype (for example, if you have set `doctype html`) the
format here is HtmlFormat (see [format](#format-string)
and [default_format](#default-format-string) options)

### on_stringify `callable`

Is triggered for each element after being formatted.

Event constant: `\Phug\FormatterEvent::STRINGIFY`

Event type: [`\Phug\Formatter\Event\StringifyEvent`](/api/classes/Phug.Formatter.Event.StringifyEvent.html#method___construct)

Parameter you can get/set:
- output: output string (HTML and PHP code)
Parameter you can get:
- formatEvent: reference to the source format event
(`FormatEvent`), modifying properties on this event
will have no effect has it has already been triggered.

### on_new_format `callable`

Is triggered when the format change (for example when you
set the doctype).

Event constant: `\Phug\FormatterEvent::NEW_FORMAT`

Event type: [`\Phug\Formatter\Event\NewFormatEvent`](/api/classes/Phug.Formatter.Event.NewFormatEvent.html#method___construct)

Parameters you can get/set:
- formatter: the current formatter in use (implements Formatter)
- format: the new format instance (implements FormatInterface)

### on_dependency_storage `callable`

Is triggered when a dependency is retrieved from the dependency
storage.

Dependency storage is used to store functions needed at rendering
time and dump them in the compiled PHP code, it's used for example
in assignments:

```phug
p&attributes(['foo' => 'bar'])
```
<i data-options='{"mode":"format"}'></i>

Those methods are stored by default in `$pugModule` (see
[dependencies_storage](#dependencies-storage-string) option
to change it).

Event constant: `\Phug\FormatterEvent::DEPENDENCY_STORAGE`

Event type: [`\Phug\Formatter\Event\DependencyStorageEvent`](/api/classes/Phug.Formatter.Event.DependencyStorageEvent.html#method___construct)

Parameters you can get/set:
- dependencyStorage: storage variable as string (for example:
`$pugModule['Phug\\Formatter\\Format\\BasicFormat::attributes_assignment']`)

### on_parse `callable`

Is triggered before the parsing process.

Event constant: `\Phug\ParserEvent::PARSE`

Event type: [`\Phug\Parser\Event\ParseEvent`](/api/classes/Phug.Parser.Event.ParseEvent.html#method___construct)

Parameters you can get/set:
- input: input string/source file content
- path: input file if `compileFile`/`renderFile`/`displayFile`
has been called
- stateClassName: class name of the state object that is about
be created for parsing
- stateOptions: options array that will be passed to the sate
at its creation

### on_document `callable`

Is triggered when the parser finished to parse a whole document.

Event constant: `\Phug\ParserEvent::DOCUMENT`

Event type: [`\Phug\Parser\Event\NodeEvent`](/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Parameters you can get/set:
- node: the document as parser node instance

### on_state_enter `callable`

Is triggered when the parser enter a node.

Event constant: `\Phug\ParserEvent::STATE_ENTER`

Event type: [`\Phug\Parser\Event\NodeEvent`](/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Parameters you can get/set:
- node: the node the parser entered in

### on_state_leave `callable`

Is triggered when the parser leave a node.

Event constant: `\Phug\ParserEvent::STATE_LEAVE`

Event type: [`\Phug\Parser\Event\NodeEvent`](/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Parameters you can get/set:
- node: the node the parser left out

### on_state_store `callable`

Is triggered when the parser store and append a
node to the document tree.

Event constant: `\Phug\ParserEvent::STATE_STORE`

Event type: [`\Phug\Parser\Event\NodeEvent`](/api/classes/Phug.Parser.Event.NodeEvent.html#method___construct)

Parameters you can get/set:
- node: the node the parser stored

### on_lex `callable`

Is triggered when the lexer starts to tokenize
an input string.

Event constant: `\Phug\LexerEvent::LEX`

Event type: [`\Phug\Lexer\Event\LexEvent`](/api/classes/Phug.Lexer.Event.LexEvent.html#method___construct)

Parameters you can get/set:
- input: input string/source file content
- path: input file if `compileFile`/`renderFile`/`displayFile`
has been called
- stateClassName: class name of the state object that is about
be created for lexing
- stateOptions: options array that will be passed to the sate
at its creation

### on_lex_end `callable`

Is triggered when the lexer finished to tokenize
an input string.

Event constant: `\Phug\LexerEvent::LEX_END`

Event type: [`\Phug\Lexer\Event\EndLexEvent`](/api/classes/Phug.Lexer.Event.EndLexEvent.html#method___construct)

Parameters you can get/set:
- lexEvent: link to the initial LexEvent

### on_token `callable`

Is triggered each time the lexer is about to yield a token
and send it to the parser.

Event constant: `\Phug\LexerEvent::TOKEN`

Event type: [`\Phug\Lexer\Event\TokenEvent`](/api/classes/Phug.Lexer.Event.TokenEvent.html#method___construct)

Parameters you can get/set:
- token: the token created by the lexer
- tokenGenerator: is null by default, but if you set
an iterator for this property, it will replace the token

Some examples:
```php
$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    $token = $event->getToken();
    if ($token instanceof \Phug\Lexer\Token\TagToken) {
      $token->setName('a');
    }
  },
]);
$renderer->display('div'); // <a></a>

$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    if ($event->getToken() instanceof \Phug\Lexer\Token\TagToken) {
      $text = new \Phug\Lexer\Token\TextToken();
      $text->setValue('Hello');
      $event->setToken($text);
    }
  },
]);
$renderer->display('div'); // Hello

$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    if ($event->getToken() instanceof \Phug\Lexer\Token\TextToken) {
      $event->setTokenGenerator(new \ArrayIterator([
        (new \Phug\Lexer\Token\TagToken())->setName('div'),
        (new \Phug\Lexer\Token\ClassToken())->setName('foo'),
        (new \Phug\Lexer\Token\IdToken())->setName('bar'),
      ]));
    }
  },
]);
$renderer->display('| Hello'); // <div id="bar" class="foo"></div>

function replaceTextToken(\Phug\Lexer\Token\TextToken $token) {
  if (preg_match('/^(\D+)(\d+)$/', $token->getValue(), $match) {
    list(, $chars, $digit) = $match;
    for ($i = 0; $i < $digit; $i++) {
      yield (new \Phug\Lexer\Token\TagToken())->setName($chars);
    }
  }
}

$renderer = new \Phug\Renderer([
  'on_token' => function (\Phug\Lexer\Event\TokenEvent $event) {
    $token = $event->getToken();
    if ($token instanceof \Phug\Lexer\Token\TextToken) {
      $event->setTokenGenerator(replaceTextToken($token));
    }
  },
]);
$renderer->display("|i2\n|bk3"); // <i></i><i></i><bk></bk><bk></bk><bk></bk>
```

## Add-ons

Here are a list of entry points to add contents and custom
behaviors:

### macros `array`

*macros* option or the `macro` method allow you to add methods
on both `Phug` facade and `Phug\Renderer` instances (and if
you use **Pug-php**, it also add them to the `Pug\Facade`
facade and `Pug` instances).
```php
Phug::macro('displayMessage', function ($message) {
  static::display('p=$message', [
    'message' => $message,
  ]);
});

Phug::displayMessage('Hello');
```

This will display:
```html
<p>Hello</p>
```

Or an example with the option syntax:
```php
Phug::setOption('macros', [
  'getOne' => function () {
    return 1;
  },
  'getTwo' => function () {
    return 2;
  },
]);

echo Phug::getOne() + Phug::getTwo();
```

Outputs: `3`.

### modules `array`

Modules can add anything else by manipulating options and
events. For example if you use **Pug-php** with default
options, you already have the
[js-phpize module for Phug](https://github.com/pug-php/js-phpize-phug)
enabled. This would be equivalent to require it with
composer and add it this way to **Phug**:

```php
$renderer = new \Phug\Renderer([
    'modules' => [
        \JsPhpize\JsPhpizePhug::class,
    ],
]);

$renderer->display('p=userName.substr(0, 3)', [
    'userName' => 'Bobby',
]);
```

This code output `<p>Bob</p>` but it would failed without
the module added because JS expressions are not
natively handled.

You also can create your own module by extending one of
the following class:
- [`\Phug\AbstractRendererModule`](/api/classes/Phug.AbstractRendererModule.html)
- [`\Phug\AbstractCompilerModule`](/api/classes/Phug.AbstractCompilerModule.html)
- [`\Phug\AbstractFormatterModule`](/api/classes/Phug.AbstractFormatterModule.html)
- [`\Phug\AbstractParserModule`](/api/classes/Phug.AbstractParserModule.html)
- [`\Phug\AbstractLexerModule`](/api/classes/Phug.AbstractLexerModule.html)

They all extend the
[`\Phug\Util\AbstractModule` class](/api/classes/Phug.Util.AbstractModule.html)

Here is an example:

```php
class MyModule extends \Phug\AbstractCompilerModule
{
    public function __construct(\Phug\Util\ModuleContainerInterface $container)
    {
        // Here you can change some options
        $container->setOption('default_tag', 'p');

        parent::__construct($container);
    }

    public function getEventListeners()
    {
        // Here you can attach some events
        return [
            \Phug\CompilerEvent::NODE => function (\Phug\Compiler\Event\NodeEvent $event) {
                // Do something before compiling a node
                $node = $event->getNode();
                if ($node instanceof \Phug\Parser\Node\MixinNode) {
                    $tag = new \Phug\Parser\Node\ElementNode(
                        $event->getNode()->getToken()
                    );
                    $attribute = new \Phug\Parser\Node\AttributeNode();
                    $attribute->setName('mixin');
                    $attribute->setValue('"'.$node->getName().'"');
                    $tag->getAttributes()->attach($attribute);
                    $event->setNode($tag);
                }
            },
        ];
    }
}

$renderer = new \Phug\Renderer([
    'modules' => [
        MyModule::class,
    ],
]);

$renderer->display('mixin foo()');
```

This will output:
```html
<p mixin="foo"></p>
```

Modules are dispatched to the
renderer/compiler/formatter/parser/lexer
according to the interface implemented (or the abstract
module class extended).

But you can specify explicitly a target with following
options:

### compiler_modules `array` 

Modules reserved to the compiler (see [modules](#modules-array)).

### formatter_modules `array` 

Modules reserved to the formatter (see [modules](#modules-array)).

### parser_modules `array` 

Modules reserved to the parser (see [modules](#modules-array)).

### lexer_modules `array` 

Modules reserved to the lexer (see [modules](#modules-array)).

### includes `array`

It simply includes pug files before each compilation:

```php
// Add to previous includes to avoid erase existing includes if any
Phug::setOption('includes', Phug::getOption('includes') + [
    'mixins.pug',
]);

Phug::display('+foo()');
```

If the file `mixins.pug` contains a **foo** mixin declaration,
this code will properly call it.

It's a good way to make a mixins library available in
any template.

### filter_resolvers `array`

Set a dynamic way to resolve a filter by name when not found.

```php
Phug::setOption('filter_resolvers', Phug::getOption('filter_resolvers') + [
    function ($name) {
        if (mb_substr($name, 0, 3) === 'go-') {
            return function ($content) use ($name) {
                return '<a href="'.mb_substr($name, 3).'">'.$content.'</a>';
            };
        }
    },
]);

Phug::display(':go-page');
// <a href="page"></a>
Phug::display(':go-action Action');
// <a href="action">Action</a>
```

The resolver is used only if the given filter name does
not exists and if previous resolver did return nothing.
If no resolver return anything, then an *Unknown filter*
error is thrown.

### keywords `array`

Allow you to create your own custom language keywords:

```php
Phug::setOption('keywords', Phug::getOption('keywords') + [
    'myKeyword' => function ($value, \Phug\Formatter\Element\KeywordElement $element, $name) {
        $nodes = isset($element->nodes) ? count($element->nodes) : 0;

        return "This is a $name keyword with $value value and $nodes children.";
    },
]);


Phug::display('
div
  myKeyword myValue
    span 1
    span 2
');
```

Display:
```html
<div>This is a myKeyword keyword with myValue value and 2 children.</div>
```

When the keyword callback returns a string, it replaces the whole keyword
with its children.

But you can also return an array with *begin* and *end* that will
preserves the children nodes:

```php
Phug::setOption('keywords', Phug::getOption('keywords') + [
    'foo' => function ($value) {
        return [
            'begin' => '<div class="'.$value.'">',
            'end'   => '</div>',
        ];
    },
]);


Phug::display('
myKeyword myValue
  span 1
  span 2
');
```

Display:
```html
<div class="myValue">
  <span>1</span>
  <span>2</span>
</div>
```

Or you can specify an array with *beginPhp* and *endPhp* to
wrap children with a begin string and an end string both
wrapped themselves in `<?php ?>`.

```php
Phug::setOption('keywords', Phug::getOption('keywords') + [
    'repeat' => function ($value) {
        return [
            'beginPhp' => 'for ($i = 0; $i < '.$value.'; $i++) {',
            'endPhp'   => '}',
        ];
    },
]);


Phug::display('
repeat 3
  section
');
```

Display:
```html
<section></section>
<section></section>
<section></section>
```

### php_token_handlers `array`

This setting allow you to intercept
[any PHP token](http://php.net/manual/en/tokens.php)
and replace it with an other string of PHP code.
It also works with expressions inside `each` loop,
`if` statements, etc. and even if the expression come from
a translation. For example, if you
[use **js-phpize**](#use-javascript-expressions)
](#utiliser-des-expressions-javascript)
and write `a(href=route('profile', {id: 3}))`, then
`{id: 3}` is converted to `array('id' => 3)` and
the `array(` token can be intercepted with its
PHP identifier `T_ARRAY`.

```php
Phug::setOption('php_token_handlers', [
    T_DNUMBER => 'round(%s)',
]);

Phug::display('
- $floatingNumber = 9.54
- $text = "9.45"
strong=$floatingNumber
| !=
strong=$text
');

```

Output:
```html
<strong>10</strong>!=<strong>9.45</strong>
```

If you pass a string,
[`sprintf`](http://php.net/manual/en/function.sprintf.php)
is used to handle it, so if it contains `%s`, it will be
replaced with the input token string.

You can also use a callback function:
```php
Phug::setOption('php_token_handlers', [
    '(' => function ($tokenString, $index, $tokens, $checked, $formatInstance) {
        return '__call_something('.mt_rand(0, 4).', ';
    },
]);

echo Phug::compile('b=($variable)');
```

This will call the callback function for each `(` token found in
an expression and replace it with the result returned by the
function (for example `__call_something(2, `).

This callback function receives 5 arguments:
- `$tokenString` is the input token as string;
- `$index` is the position of the token in the expression;
- `&$tokens` is an array with all tokens of the expression, it
is passed by reference, it means you can modify/add/remove
tokens from it (will works only for tokens come after the
current token handled);
- `$checked` is the check flag of the expression (`=exp()` is
checked, `?=exp()` is not checked);
- `$formatInstance` the format instance that format
the current expression (implements FormatInterface).

Be careful, we use `php_token_handlers` to handle checked
expressions. It means you can replace the `T_VARIABLE` PHP
token handler with your own like in the example below:

```php
Phug::setOption('php_token_handlers', [
    T_VARIABLE => function ($variable) {
        if (mb_substr($variable, 0, 5) === '$env_') {
            return '$_'.strtoupper(mb_substr($variable, 5));
        }

        return $variable;
    },
]);

Phug::display('
b=$normalVariable
i=$env_super["METHOD"]
', [
    'normalVariable' => 'foo',
    '_SUPER' => [
        'METHOD' => 'bar',
    ],
]);
```

Output:

```html
<b>foo</b><i>bar</i>
```

But if you do, it erase the initial checked expressions
handling:

```php
Phug::display('p=$missing'); // output <p></p>

Phug::setOption('php_token_handlers', [
    T_VARIABLE => function ($variable) {
        return $variable;
    },
]);

Phug::display('p=$missing'); // Throw: Undefined variable: missing
```

But you still can recall the native variable handler before
or after your own treatments:

```php
Phug::setOption('php_token_handlers', [
    T_VARIABLE => function ($tokenString, $index, $tokens, $checked, $formatInstance) {
        // Do something before the check process
        $tokenString .= 'Suffix';
        // Do the check process:
        $tokenString = $formatInstance->handleVariable($tokenString, $index, $tokens, $checked);
        // Do something after the check process
        $tokenString = 'strtoupper('.$tokenString.')';

        return $tokenString;
    },
]);

Phug::display('p=$foo', [
    'fooSuffix' => 'bar',
]);
```

Output:
```html
<p>BAR</p>
```

## Mixins

### mixin_keyword

Determine the start keyword of mixin declaration.

Value by default: `"mixin"`

It can be changed for an other string or an array to allow multiple keywords such as: `["mixin", "component"]`

String can contain regular expression, it means you can use `[a-z]` to identify lower letter, `\d` for digit etc.
but it also means you need to escape special characters such as `[]?!.{}()^$/` if you want to use them as text.

### mixin_call_keyword

Determine the start keyword of mixin call.

Value by default: `"\\+"`

It can be changed for an other string or an array to allow multiple keywords such as: `["\\+", "@"]`

String can contain regular expression, it means you can use `[a-z]` to identify lower letter, `\d` for digit etc.
but it also means you need to escape special characters such as `[]?!.{}()^$/` if you want to use them as text.

### mixin_merge_mode `string`

Alias of `allowMixinOverride` in **Pug-php**.

It determines if a new mixin declaration with an existing
name will replace the previous one or be ignored:

```php
Phug::setOption('mixin_merge_mode', 'replace');

Phug::display('
mixin foo
  p A

mixin foo
  p B

+foo
');

// Output <p>B</p>

Phug::setOption('mixin_merge_mode', 'ignore');

Phug::display('
mixin foo
  p A

mixin foo
  p B

+foo
');

// Output <p>A</p>
```

This option is set to `"replace"` by default.

## Formatting

### patterns `array`

Defines how to dump specific parts of elements in PHP.

Default value:
```php
[
  'class_attribute'        => '(is_array($_pug_temp = %s) ? implode(" ", $_pug_temp) : strval($_pug_temp))',
  'string_attribute'       => '
        (is_array($_pug_temp = %s) || is_object($_pug_temp) && !method_exists($_pug_temp, "__toString")
            ? json_encode($_pug_temp)
            : strval($_pug_temp))',
  'expression_in_text'     => '(is_bool($_pug_temp = %s) ? var_export($_pug_temp, true) : $_pug_temp)',
  'html_expression_escape' => 'htmlspecialchars(%s)',
  'html_text_escape'       => 'htmlspecialchars',
  'pair_tag'               => '%s%s%s',
  'transform_expression'   => '%s',
  'transform_code'         => '%s',
  'transform_raw_code'     => '%s',
  'php_handle_code'        => '<?php %s ?>',
  'php_display_code'       => '<?= %s ?>',
  'php_block_code'         => ' {%s}',
  'php_nested_html'        => ' ?>%s<?php ',
  'display_comment'        => '<!-- %s -->',
  'doctype'                => '<!DOCTYPE %s PUBLIC "%s" "%s">',
  'custom_doctype'         => '<!DOCTYPE %s>',
  'debug_comment'          => "\n// PUG_DEBUG:%s\n",
  'debug'                  => function ($nodeId) {
    return $this->handleCode($this->getDebugComment($nodeId));
  },
]
```

Formats can add patterns (like
[XmlFormat](/api/classes/Phug.Formatter.Format.XmlFormat.html)):
```php
class XmlFormat extends AbstractFormat
{
    //...

    const DOCTYPE = '<?xml version="1.0" encoding="utf-8" ?>';
    const OPEN_PAIR_TAG = '<%s>';
    const CLOSE_PAIR_TAG = '</%s>';
    const SELF_CLOSING_TAG = '<%s />';
    const ATTRIBUTE_PATTERN = ' %s="%s"';
    const BOOLEAN_ATTRIBUTE_PATTERN = ' %s="%s"';
    const BUFFER_VARIABLE = '$__value';

    public function __construct(Formatter $formatter = null)
    {
        //...

        $this->addPatterns([
            'open_pair_tag'             => static::OPEN_PAIR_TAG,
            'close_pair_tag'            => static::CLOSE_PAIR_TAG,
            'self_closing_tag'          => static::SELF_CLOSING_TAG,
            'attribute_pattern'         => static::ATTRIBUTE_PATTERN,
            'boolean_attribute_pattern' => static::BOOLEAN_ATTRIBUTE_PATTERN,
            'save_value'                => static::SAVE_VALUE,
            'buffer_variable'           => static::BUFFER_VARIABLE,
        ])
```

For example, you can see `BOOLEAN_ATTRIBUTE_PATTERN = ' %s="%s"'`
which mean `input(checked)` become `<input checked="checked">`.

And
[HtmlFormat](/api/classes/Phug.Formatter.Format.HtmlFormat.html)
override it:

```php
class HtmlFormat extends XhtmlFormat
{
    const DOCTYPE = '<!DOCTYPE html>';
    const SELF_CLOSING_TAG = '<%s>';
    const EXPLICIT_CLOSING_TAG = '<%s/>';
    const BOOLEAN_ATTRIBUTE_PATTERN = ' %s';

    public function __construct(Formatter $formatter = null)
    {
        parent::__construct($formatter);

        $this->addPattern('explicit_closing_tag', static::EXPLICIT_CLOSING_TAG);
    }
}
```
`BOOLEAN_ATTRIBUTE_PATTERN = ' %s'` so `input(checked)`
become `<input checked>`.

The same way you can extend a format to create your own
custom format and override it with [formats](#formats-array)
and [default_format](#default-format-string) options.

Patterns can be strings where `%s` is replaced with the input
or callback functions receiving the input as argument.

Some patterns have multiple input (like `pair_tag` which takes
`$open`, `$content` and `$close`).

Usage example: you can intercept and modify expressions:
```php

Phug::setOption('patterns', [
  'transform_expression' => 'strtoupper(%s)',
]);

Phug::display('p="AbcD"'); // Output <p>ABCD</p>
```

Or you can use a custom escape function:
```php
Phug::setOption('patterns', [
  'html_expression_escape' => 'htmlentities(%s)',
  'html_text_escape'       => 'htmlentities',
]);
```

### pattern `callable`

The `pattern` option is the way patterns are handled.

Default value :
```php
function ($pattern) {
  $args = func_get_args();
  $function = 'sprintf';
  if (is_callable($pattern)) {
    $function = $pattern;
    $args = array_slice($args, 1);
  }

  return call_user_func_array($function, $args);
}
```

This function will take at least one argument (the pattern)
and as many values as needed for this pattern will come
as rest arguments.

You can see in the default behavior that if the pattern
is callable, we simply call it with input values:
`$pattern($value1, $value2, ...)`, else
we call `sprintf($pattern, $value1, $value2, ...)`

By changing the `pattern` option, you can handle patterns
in the way you want and support any other pattern types.

### formats `array`

Array of format classes by doctype, default value is:
```php
[
  'basic'        => \Phug\Formatter\Format\BasicFormat::class,
  'frameset'     => \Phug\Formatter\Format\FramesetFormat::class,
  'html'         => \Phug\Formatter\Format\HtmlFormat::class,
  'mobile'       => \Phug\Formatter\Format\MobileFormat::class,
  '1.1'          => \Phug\Formatter\Format\OneDotOneFormat::class,
  'plist'        => \Phug\Formatter\Format\PlistFormat::class,
  'strict'       => \Phug\Formatter\Format\StrictFormat::class,
  'transitional' => \Phug\Formatter\Format\TransitionalFormat::class,
  'xml'          => \Phug\Formatter\Format\XmlFormat::class,
]
```

You can add/modify/remove any format by doctype:
```php
class FooFormat extends \Phug\Formatter\Format\HtmlFormat
{
    const DOCTYPE = '#FOO';
    // Here you can change options/methods/patterns
}

Phug::setOption('formats', [
    'foo' => FooFormat::class,
] + Phug::getOption('formats'));
// Add foo but keep Phug::getOption('formats')
// So both array will be merged

Phug::display('
doctype foo
test
');

// Output #FOO<test></test>
```

You can also remove a format this way:
```php
$formats = Phug::getOption('formats');
unset($formats['xml']); // remove custom XML format

Phug::setOption('formats', $formats);

Phug::display('
doctype xml
test
');

// Output <!DOCTYPE xml><test></test>
// Instead of <?xml version="1.0" encoding="utf-8" ?><test></test>
```

### default_format `string`

It's the format used when there is no doctype;
`\Phug\Formatter\Format\BasicFormat::class` by default.

```php
$renderer = new \Phug\Renderer([
  'default_format' => \Phug\Formatter\Format\XmlFormat::class,
]);
$renderer->display('input'); // <input></input>

$renderer = new \Phug\Renderer([
  'default_format' => \Phug\Formatter\Format\HtmlFormat::class,
]);
$renderer->display('input'); // <input>
```

### dependencies_storage `string`

Variable name that will contain dependencies in the
compiled PHP code; `"pugModule"` by default.

### formatter_class_name `string`

Allow you to extend the
[Formatter class](/api/classes/Phug.Formatter.html)
```php
class CustomFormatter extends \Phug\Formatter
{
    public function format(\Phug\Formatter\ElementInterface $element, $format = null)
    {
        // Add a space everywhere
        return parent::format($element, $format).' ';
    }
}

Phug::display('
span foo
span bar
');

// <span>foo</span><span>bar</span>

$renderer = new Phug\Renderer([
    'formatter_class_name' => CustomFormatter::class,
]);

$renderer->display('
span foo
span bar
');

// <span>foo </span> <span>bar </span>
```

## Rendering

### scope_each_variables `boolean | string`

By default (`false` value), key and value variables created by `each ... in` or `for ... in`
loops are scoped (since **phug/compiler** 0.5.26).

```phug
- $val = 'a'
- $key = 'b'
each $val, $key in ['X', 'Y', 'Z']
  p= $key . $val
div= $key . $val
```

With `scope_each_variables` set to `false`, the used key and value variables used in each/for
will simply erase the global one:
```phug
- $val = 'a'
- $key = 'b'
each $val, $key in ['X', 'Y', 'Z']
  p= $key . $val
div= $key . $val
```
<i data-options='{"scopeEachVariables":false}'></i>

`scope_each_variables` option use internally a `$__eachScopeVariables` variable to store
the iteration variables (value and optionally key) name and values they had before the loop
to restore them after the loop.
 
You can also pass a string to `scope_each_variables` to choose the variable name,
for example with `'scope_each_variables' => 'beforeEach'`:

```phug
- $val = 'a'
- $key = 'b'
each $val, $key in ['X', 'Y', 'Z']
  p= $beforeEach['key'] . $beforeEach['val']
div= $key . $val
```
<i data-options='{"scopeEachVariables":"beforeEach"}'></i>

### adapter_class_name `string`

This option need the adapter to be reinitialized to be
taken into account. So you can use it as an initial option
(passed as options array when you construct a new
Renderer instance or a new Pug instance if you use **Pug-php**)
else you can simply use the
[`->setAdapterClassName()` method](/api/classes/Phug.Renderer.Partial.AdapterTrait.html#method_setAdapterClassName)
to change this option and reinitialize the adapter.

```php
Phug::getRenderer()->setAdapterClassName(\Phug\Renderer\Adapter\StreamAdapter::class);
// Phug::getRenderer()->getAdapter() instanceof \Phug\Renderer\Adapter\StreamAdapter
```

There are 3 adapters available and you can create your own
by extending one of them or the
[AbstractAdapter class](/api/classes/Phug.Renderer.AbstractAdapter.html).

The adapter role is to take formatted compiled code and
turn it into the final rendered code. So most often it
means execute PHP code to get HTML code.

#### FileAdapter

[FileAdapter](/api/classes/Phug.Renderer.Adapter.FileAdapter.html)
is the only adapter to implement
[CacheInterface](/api/classes/Phug.Renderer.CacheInterface.html)
so when you enable or use any cache feature, this adapter
is automatically selected if the current adapter does not
implement `CacheInterface`. `->display()` with the
FileAdapter is equivalent to:
```php
file_put_contents('file.php', $phpCode);
include 'file.php';
```

#### EvalAdapter

[EvalAdapter](/api/classes/Phug.Renderer.Adapter.EvalAdapter.html)
is the default adapter and uses
[eval](http://php.net/manual/en/function.eval.php).
You may have heard that `eval` is dangerous. And yes,
if you don't filter user/external input the string you
pass to `eval` may contain, this is unsafe. But this
does not happen when you render a template.
Your local/global variables are never executed, only
the Pug code converted in PHP code is, so if you
do not write dangerous code in your Pug code, there
is nothing dangerous in the final PHP code.
This is perfectly as safe as the 2 other adapters,
you will always get the exact same executions and
results no matter which adapter is used.

Take a look at the following:
```pug
p?!=$dangerousContent
```
```vars
[
  'dangerousContent' => 'file_get_contents("index.php")',
]
```
As you see, variables can contain anything and be display
in any way, it will not be evaluated by PHP, only displayed.
Danger only appears if you write it down directly in
your Pug template, so it's the same danger than in
any template engine or if you would have written it
directly in your PHP files.

EvalAdapter is the faster and easier to setup way
as well. In this mode `->display()` is
equivalent to:
```php
eval('?>'.$phpCode);
```

#### StreamAdapter

[StreamAdapter](/api/classes/Phug.Renderer.Adapter.StreamAdapter.html)
Stream is an alternative between both. In this
mode `->display()` is equivalent to:
```php
include 'pug.stream://data;'.$phpCode;
```
Stream have some constraints. The stream size
is limited by the RAM memory. And server config
(like php.ini) can disallow stream inclusion.

### stream_name `string`

Default to `"pug"`. It determines the stream name
when you use the stream adapter (see above).

### stream_suffix `string`

Default to `".stream"`. It determines the stream suffix
when you use the stream adapter (see above).

## File system

### tmp_dir `string`

The directory to use to store temporary files.
`sys_get_temp_dir()` by default.

### tempnam `callable`

The function to use to create a temporary file.
`"tempnam"` by default.

### get_file_contents `callable`

The function to use to get file contents.
`"file_get_contents"` by default.

```php
$storage = new Memcached();
$storage->addServer('localhost', 11211);
Phug::setOption('get_file_contents', function ($path) use ($storage) {
  return $storage->get($path);
});
```

In this example, instead of searching templates
(rendered, included or extended) in the file
matching the path, we search it in a Memcached
storage.

### up_to_date_check `boolean`

`true` by default, when set to `false`, cache files
never expire until a manual cache clear.

### keep_base_name `boolean`

If `true`, it will prepend template name to cache
file name. It can be useful to debug if you need
to see quickly which template a cache file come
from.

### locator_class_name `string`

The locator is used by the compiler to locate
files to compile/include/extend.

By default we use
[FileLocator](/api/classes/Phug.Compiler.Locator.FileLocator.html).

But you can change it for any class that implement
[LocatorInterface](/api/classes/Phug.Compiler.LocatorInterface.html).

## Lexing

Lexing options are handled and altered by the lexer
at very low process level. There are no particular
interest to change (except encoding) them but getting
them at some events can be interesting:

```php
$lexer = Phug::getRenderer()->getCompiler()->getParser()->getLexer();
$lexer->attach(\Phug\LexerEvent::TOKEN, function (\Phug\Lexer\Event\TokenEvent $event) use ($lexer, &$output) {
    $state = $lexer->getState();
    $state->getLevel(); // level
    $state->getIndentStyle(); // indent_style
    $state->getIndentWidth(); // indent_width
    $state->getReader()->getEncoding(); // encoding
});
```

**Warning**: do not confuse options below with
formatting options, the options below have no
effect on the output, they are how the lexer
get the input.

### level `integer`

Count of indentation spaces/tabs.

### indent_style `string`

Indentation string (spaces, tabs or any custom string).

### indent_width `indent_width`

Number strings occurrences to step an indentation.

### allow_mixed_indent `integer`

`true` by default. If set to `false`, mixin tabs
and spaces throw an exception.

### encoding `string`

Encoding of the input (`"UTF-8"` by default).

## Extending core classes

Core classes can be replaced thanks to options.
This allow you to extend **Phug** classes and
methods. These options are initial, so you
have to reset/recreate the renderer if you
want to change them after a render.

### compiler_class_name `string`

Allow to replace [Compiler](/api/classes/Phug.Compiler.html)

### parser_class_name `string`

Allow to replace [Parser](/api/classes/Phug.Parser.html)

### lexer_class_name `string`

Allow to replace [Lexer](/api/classes/Phug.Lexer.html)

### lexer_class_name `string`

Allow to replace [Lexer](/api/classes/Phug.Lexer.html)

### lexer_state_class_name `string`

Allow to replace the [lexer state class](/api/classes/Phug.Lexer.State.html)

### parser_state_class_name `string`

Allow to replace the [parser state class](/api/classes/Phug.Parser.State.html)

### node_compilers `array`

Allow to change compilers for each kind of node,
the default map is:

```php
[
    \Phug\Parser\Node\AssignmentListNode::class => \Phug\Compiler\NodeCompiler\AssignmentListNodeCompiler::class,
    \Phug\Parser\Node\AssignmentNode::class     => \Phug\Compiler\NodeCompiler\AssignmentNodeCompiler::class,
    \Phug\Parser\Node\AttributeListNode::class  => \Phug\Compiler\NodeCompiler\AttributeListNodeCompiler::class,
    \Phug\Parser\Node\AttributeListNode::class  => \Phug\Compiler\NodeCompiler\AttributeNodeCompiler::class,
    \Phug\Parser\Node\BlockNode::class          => \Phug\Compiler\NodeCompiler\BlockNodeCompiler::class,
    \Phug\Parser\Node\YieldNode::class          => \Phug\Compiler\NodeCompiler\YieldNodeCompiler::class,
    \Phug\Parser\Node\CaseNode::class           => \Phug\Compiler\NodeCompiler\CaseNodeCompiler::class,
    \Phug\Parser\Node\CodeNode::class           => \Phug\Compiler\NodeCompiler\CodeNodeCompiler::class,
    \Phug\Parser\Node\CommentNode::class        => \Phug\Compiler\NodeCompiler\CommentNodeCompiler::class,
    \Phug\Parser\Node\ConditionalNode::class    => \Phug\Compiler\NodeCompiler\ConditionalNodeCompiler::class,
    \Phug\Parser\Node\DoctypeNode::class        => \Phug\Compiler\NodeCompiler\DoctypeNodeCompiler::class,
    \Phug\Parser\Node\DocumentNode::class       => \Phug\Compiler\NodeCompiler\DocumentNodeCompiler::class,
    \Phug\Parser\Node\DoNode::class             => \Phug\Compiler\NodeCompiler\DoNodeCompiler::class,
    \Phug\Parser\Node\EachNode::class           => \Phug\Compiler\NodeCompiler\EachNodeCompiler::class,
    \Phug\Parser\Node\KeywordNode::class        => \Phug\Compiler\NodeCompiler\KeywordNodeCompiler::class,
    \Phug\Parser\Node\ElementNode::class        => \Phug\Compiler\NodeCompiler\ElementNodeCompiler::class,
    \Phug\Parser\Node\ExpressionNode::class     => \Phug\Compiler\NodeCompiler\ExpressionNodeCompiler::class,
    \Phug\Parser\Node\FilterNode::class         => \Phug\Compiler\NodeCompiler\FilterNodeCompiler::class,
    \Phug\Parser\Node\ForNode::class            => \Phug\Compiler\NodeCompiler\ForNodeCompiler::class,
    \Phug\Parser\Node\ImportNode::class         => \Phug\Compiler\NodeCompiler\ImportNodeCompiler::class,
    \Phug\Parser\Node\MixinCallNode::class      => \Phug\Compiler\NodeCompiler\MixinCallNodeCompiler::class,
    \Phug\Parser\Node\MixinNode::class          => \Phug\Compiler\NodeCompiler\MixinNodeCompiler::class,
    \Phug\Parser\Node\TextNode::class           => \Phug\Compiler\NodeCompiler\TextNodeCompiler::class,
    \Phug\Parser\Node\VariableNode::class       => \Phug\Compiler\NodeCompiler\VariableNodeCompiler::class,
    \Phug\Parser\Node\WhenNode::class           => \Phug\Compiler\NodeCompiler\WhenNodeCompiler::class,
    \Phug\Parser\Node\WhileNode::class          => \Phug\Compiler\NodeCompiler\WhileNodeCompiler::class,
]
```

### element_handlers `array`

Allow to change how to format each kind of element,
the default map is:
```php
[
    \Phug\Formatter\Element\AssignmentElement::class => [$this, 'formatAssignmentElement'],
    \Phug\Formatter\Element\AttributeElement::class  => [$this, 'formatAttributeElement'],
    \Phug\Formatter\Element\CodeElement::class       => [$this, 'formatCodeElement'],
    \Phug\Formatter\Element\CommentElement::class    => [$this, 'formatCommentElement'],
    \Phug\Formatter\Element\ExpressionElement::class => [$this, 'formatExpressionElement'],
    \Phug\Formatter\Element\DoctypeElement::class    => [$this, 'formatDoctypeElement'],
    \Phug\Formatter\Element\DocumentElement::class   => [$this, 'formatDocumentElement'],
    \Phug\Formatter\Element\KeywordElement::class    => [$this, 'formatKeywordElement'],
    \Phug\Formatter\Element\MarkupElement::class     => [$this, 'formatMarkupElement'],
    \Phug\Formatter\Element\MixinCallElement::class  => [$this, 'formatMixinCallElement'],
    \Phug\Formatter\Element\MixinElement::class      => [$this, 'formatMixinElement'],
    \Phug\Formatter\Element\TextElement::class       => [$this, 'formatTextElement'],
    \Phug\Formatter\Element\VariableElement::class   => [$this, 'formatVariableElement'],
]
```

Where `$this` is the current format instance.

### token_handlers `array`

Allow to change how lexer token are parsed,
the default map is:
```php
[
    \Phug\Lexer\Token\AssignmentToken::class             => \Phug\Parser\TokenHandler\AssignmentTokenHandler::class,
    \Phug\Lexer\Token\AttributeEndToken::class           => \Phug\Parser\TokenHandler\AttributeEndTokenHandler::class,
    \Phug\Lexer\Token\AttributeStartToken::class         => \Phug\Parser\TokenHandler\AttributeStartTokenHandler::class,
    \Phug\Lexer\Token\AttributeToken::class              => \Phug\Parser\TokenHandler\AttributeTokenHandler::class,
    \Phug\Lexer\Token\AutoCloseToken::class              => \Phug\Parser\TokenHandler\AutoCloseTokenHandler::class,
    \Phug\Lexer\Token\BlockToken::class                  => \Phug\Parser\TokenHandler\BlockTokenHandler::class,
    \Phug\Lexer\Token\YieldToken::class                  => \Phug\Parser\TokenHandler\YieldTokenHandler::class,
    \Phug\Lexer\Token\CaseToken::class                   => \Phug\Parser\TokenHandler\CaseTokenHandler::class,
    \Phug\Lexer\Token\ClassToken::class                  => \Phug\Parser\TokenHandler\ClassTokenHandler::class,
    \Phug\Lexer\Token\CodeToken::class                   => \Phug\Parser\TokenHandler\CodeTokenHandler::class,
    \Phug\Lexer\Token\CommentToken::class                => \Phug\Parser\TokenHandler\CommentTokenHandler::class,
    \Phug\Lexer\Token\ConditionalToken::class            => \Phug\Parser\TokenHandler\ConditionalTokenHandler::class,
    \Phug\Lexer\Token\DoToken::class                     => \Phug\Parser\TokenHandler\DoTokenHandler::class,
    \Phug\Lexer\Token\DoctypeToken::class                => \Phug\Parser\TokenHandler\DoctypeTokenHandler::class,
    \Phug\Lexer\Token\EachToken::class                   => \Phug\Parser\TokenHandler\EachTokenHandler::class,
    \Phug\Lexer\Token\ExpansionToken::class              => \Phug\Parser\TokenHandler\ExpansionTokenHandler::class,
    \Phug\Lexer\Token\ExpressionToken::class             => \Phug\Parser\TokenHandler\ExpressionTokenHandler::class,
    \Phug\Lexer\Token\FilterToken::class                 => \Phug\Parser\TokenHandler\FilterTokenHandler::class,
    \Phug\Lexer\Token\ForToken::class                    => \Phug\Parser\TokenHandler\ForTokenHandler::class,
    \Phug\Lexer\Token\IdToken::class                     => \Phug\Parser\TokenHandler\IdTokenHandler::class,
    \Phug\Lexer\Token\InterpolationStartToken::class     => \Phug\Parser\TokenHandler\InterpolationStartTokenHandler::class,
    \Phug\Lexer\Token\InterpolationEndToken::class       => \Phug\Parser\TokenHandler\InterpolationEndTokenHandler::class,
    \Phug\Lexer\Token\ImportToken::class                 => \Phug\Parser\TokenHandler\ImportTokenHandler::class,
    \Phug\Lexer\Token\IndentToken::class                 => \Phug\Parser\TokenHandler\IndentTokenHandler::class,
    \Phug\Lexer\Token\MixinCallToken::class              => \Phug\Parser\TokenHandler\MixinCallTokenHandler::class,
    \Phug\Lexer\Token\MixinToken::class                  => \Phug\Parser\TokenHandler\MixinTokenHandler::class,
    \Phug\Lexer\Token\NewLineToken::class                => \Phug\Parser\TokenHandler\NewLineTokenHandler::class,
    \Phug\Lexer\Token\OutdentToken::class                => \Phug\Parser\TokenHandler\OutdentTokenHandler::class,
    \Phug\Lexer\Token\TagInterpolationStartToken::class  => \Phug\Parser\TokenHandler\TagInterpolationStartTokenHandler::class,
    \Phug\Lexer\Token\TagInterpolationEndToken::class    => \Phug\Parser\TokenHandler\TagInterpolationEndTokenHandler::class,
    \Phug\Lexer\Token\KeywordToken::class                => \Phug\Parser\TokenHandler\KeywordTokenHandler::class,
    \Phug\Lexer\Token\TagToken::class                    => \Phug\Parser\TokenHandler\TagTokenHandler::class,
    \Phug\Lexer\Token\TextToken::class                   => \Phug\Parser\TokenHandler\TextTokenHandler::class,
    \Phug\Lexer\Token\VariableToken::class               => \Phug\Parser\TokenHandler\VariableTokenHandler::class,
    \Phug\Lexer\Token\WhenToken::class                   => \Phug\Parser\TokenHandler\WhenTokenHandler::class,
    \Phug\Lexer\Token\WhileToken::class                  => \Phug\Parser\TokenHandler\WhileTokenHandler::class,
]
```

### scanners `array`

Allow to change how to scan and detect each string
sequence to get the given token,
the default map is:
```php
[
    'new_line'    => \Phug\Lexer\Scanner\NewLineScanner::class,
    'indent'      => \Phug\Lexer\Scanner\IndentationScanner::class,
    'import'      => \Phug\Lexer\Scanner\ImportScanner::class,
    'block'       => \Phug\Lexer\Scanner\BlockScanner::class,
    'yield'       => \Phug\Lexer\Scanner\YieldScanner::class,
    'conditional' => \Phug\Lexer\Scanner\ConditionalScanner::class,
    'each'        => \Phug\Lexer\Scanner\EachScanner::class,
    'case'        => \Phug\Lexer\Scanner\CaseScanner::class,
    'when'        => \Phug\Lexer\Scanner\WhenScanner::class,
    'do'          => \Phug\Lexer\Scanner\DoScanner::class,
    'while'       => \Phug\Lexer\Scanner\WhileScanner::class,
    'for'         => \Phug\Lexer\Scanner\ForScanner::class,
    'mixin'       => \Phug\Lexer\Scanner\MixinScanner::class,
    'mixin_call'  => \Phug\Lexer\Scanner\MixinCallScanner::class,
    'doctype'     => \Phug\Lexer\Scanner\DoctypeScanner::class,
    'keyword'     => \Phug\Lexer\Scanner\KeywordScanner::class,
    'tag'         => \Phug\Lexer\Scanner\TagScanner::class,
    'class'       => \Phug\Lexer\Scanner\ClassScanner::class,
    'id'          => \Phug\Lexer\Scanner\IdScanner::class,
    'attribute'   => \Phug\Lexer\Scanner\AttributeScanner::class,
    'assignment'  => \Phug\Lexer\Scanner\AssignmentScanner::class,
    'variable'    => \Phug\Lexer\Scanner\VariableScanner::class,
    'comment'     => \Phug\Lexer\Scanner\CommentScanner::class,
    'filter'      => \Phug\Lexer\Scanner\FilterScanner::class,
    'expression'  => \Phug\Lexer\Scanner\ExpressionScanner::class,
    'code'        => \Phug\Lexer\Scanner\CodeScanner::class,
    'markup'      => \Phug\Lexer\Scanner\MarkupScanner::class,
    'expansion'   => \Phug\Lexer\Scanner\ExpansionScanner::class,
    'dynamic_tag' => \Phug\Lexer\Scanner\DynamicTagScanner::class,
    'text_block'  => \Phug\Lexer\Scanner\TextBlockScanner::class,
    'text_line'   => \Phug\Lexer\Scanner\TextLineScanner::class,
]
```

### assignment_handlers `array`

Allow to change how to handle assignments and allow
to create your owns, example:

```php
Phug::display('img&foo()', [], [
    'assignment_handlers' => [
        function (AssignmentElement $assignment) {
            if ($assignment->getName() === 'foo') {
                $assignment->detach();

                yield new AttributeElement('data-foo', '123');
            }
        },
    ],
]);
```

Output:
```html
<img data-foo="123" />
```

### attribute_assignments `array`

Allow to change how to handle attributes, example:

```php

Phug::display('img&attributes(["foo" => "bar", "biz" => true])', [], [
    'attribute_assignments' => [
        'foo' => function () {
            return 'not-bar';
        },
    ],
]);

```

Output:
```html
<img foo="not-bar" biz="biz" />
```
