# CLI

**Phug** and **Pug-php** can be run as CLI commands:

```shell
./vendor/bin/phug render 'p=$msg' '{"msg": "Hello"}'
./vendor/bin/pug render 'p=msg' '{"msg": "Hello"}'
```

`./vendor/bin/pug` is available only if you installed **Pug-php**,
`./vendor/bin/phug` is always available if you use any of both.

## Globals options

2 globals options are available for all commands:

`--output-file` (or `-o`) redirect success output to the specified
file, it allow for example to write rendered HTML in a file:
```shell
./vendor/bin/phug render-file my-source-file.pug --output-file my-destination-file.html
```

`--bottstrap` (or `-b`) allow you to include a PHP file to be
executed before the command. For example you can define your
variables in a dynamic way:

Let say you have the following file: **set-variables.php**
```php
Phug::share([
  'time' => date('H:i'),
]);
```

```shell
./vendor/bin/phug render 'p=$time' -b set-variables.php -o page.html
```

**page.html** will contains a paragraph with the time
inside (example `<p>17:47</p>`).

The bootstrap file can run any PHP code and have all classes
available thanks to composer autoload.

If a file is named `phugBootstrap.php` in the current directory,
then it will be used as default bootstrap file.

Both options above can be set using space delimiter or equal operator,
so all the following are equivalent:

```shell
./vendor/bin/phug render-file a.pug --output-file a.html
./vendor/bin/phug render-file a.pug --output-file=a.html
./vendor/bin/phug render-file a.pug -o a.html
./vendor/bin/phug render-file a.pug -o=a.html
```

## Commands

Commands are the same for both **phug** and **pug** and will
call the same methods. The lonely difference is **phug** call
them on the `Phug` facade (that use `Phug\Renderer` with no
particular extensions and settings) and
**pug** call them on the `Pug\Facade` facade (that use
`Pug\Pug` that comes with `js-phpize` and the **pug-php**
default settings). For both, you can use `--bootstrap`
to set more options, add extensions, share variables, etc.

### render (or display)

Call `::render()` and take 1 required argument pug code input
(as string), and 2 optional arguments: local variables (as
JSON string) and options (as JSON string)

```shell
./vendor/bin/phug render 'p(foo="a")' '{}' '{"attributes_mapping":{"foo":"bar"}}'
```

Will output:
```html
<p bar="a"></p>
```

### render-file (or display-file)

Call `::renderFile()`, it's exactly like `render` expect it
take a file path as first argument:

```shell
./vendor/bin/phug render-file /directory/file.pug '{"myVar":"value"}' '{"self":true}'
```

### render-directory (or display-directory)

Call `::renderDirectory()`, render each file in a directory and its subdirectories.
It take 1 required argument: the input directory, and 3
optional arguments:
 - the output directory (if not specified, input directory
 is used instead, so rendered file are generated side-by-side
 with input files)
 - output files extension (`.html` by default)
 - local variables (as JSON string)
 
```shell
./vendor/bin/phug render-directory ./templates ./pages '.xml' '{"foo":"bar"}' 
``` 
 
Supposing you have the following `./templates` directory:
```
templates
  some-view.pug
  some-subdirectory
    another-view.pug
``` 
You will get the following `.pages`:
```
pages
  some-view.xml
  some-subdirectory
    another-view.xml
``` 

And in this example, all rendered files will get `$foo = "bar"` as
available local.

### compile

Call `::compile()`. Compile a pug string without render it. It
take 1 required argument: the pug code and 1 optional: the
filename (can also be provided via options), it will be used
to resolve relative imports.

```shell
./vendor/bin/phug compile 'a(href=$link) Go' 'filename.pug' -o file.php
```

This will write something like this in **file.php**:
```php
<a href="<?= htmlspecialchars($link) ?>">Go</a>
```

### compile-file

Call `::compileFile()`. Compile a pug input file without
render it.

```shell
./vendor/bin/phug compile-file views/index.pug -o public/index.php
```

### compile-directory (or cache-directory)

Call `::cacheDirectory()` (via `::textualCacheDirectory()`).
Compile each file in a directory and its subdirectories.

It's the perfect way to cache all your pug files when you deploy
an new version of your application in a server in production.

If you call this command each time you put something new in
production, you can disable the up-to-date check with the
option `'up_to_date_check' => false` to optimize performance.

```shell
./vendor/bin/phug compile-directory views cache '{"option":"value"}'
```

Only the first argument is required (input directory where are
stored your pug files).

As a second optional argument, you can specify the cache directory,
else `cache_dir` specified in options will be used, if not
specified, system temporary directory will be used.

The third argument (optional too) allows you to pass options
as a JSON string if needed.

### custom commands

You can create your own commands thanks to the *commands*
option:

For example if you write this in a **phugBootstrap.php**
file (in the directory you enter your commands, typically
at the project root) or in any other file that you load
with the CLI option `--bootstrap`:
```php
<?php

Phug::setOption('commands', [
  'renderDate' => function () {
    return Phug::render('p=date("d/m/Y")');
  },
]);
```

Then you will be able to execute the following command:
```shell
./vendor/bin/phug render-date
```

And it will display the date in a paragraph:
```html
<p>09/02/2018</p>
```

The  *commands* option must be an array listing custom
commands, each command can be described with one of
the 3 ways below:
```php
<?php

Phug::setOption('commands', [
  'cacheFile',
    // Make the Phug::cacheFile() method
    // available as its kebab case name:
    // ./vendor/bin/phug cache-file

  'storeFile' => 'cacheFile',
    // Make the Phug::cacheFile() method
    // with an other name:
    // ./vendor/bin/phug store-file

  'myFunction' => function () {
    return 'Hello';
  },
    // Execute the function with the given
    // name:
    // ./vendor/bin/phug my-function
]);
```

The command can also call a [macro](#macros-array).

## <i id="watch"></i>Watch changes and autocompile

To use the **watch** command, you will need to
install `phug/watcher`:
```shell
composer require phug/watcher
```

And you can use the `--init` command to create a
**phugBoostrap.php** file used as default bootstrap
file by the phug CLI.
```shell
./vendor/bin/watcher --init
```

In this file, you can change the list of the directories
to watch (*./views* and *./templates* by default) and
you can change the cache path (by default, it creates
a *phug-cache* in your system temporary storage
directory).

Then this file enable the watcher extension and set
Phug options.

To properly work, you need to use here the same options
as in you application. To keep them synchronized
you can use a common config file.

For example, let say you have the following structure
for you app:
```
- vendor
- config
  - phug.php
- bootstrap
  - cli.php
  - web.php
- views
  - home.pug
- cache
  - views
composer.json
index.php
```

Then you can have the following contents:

**phug.php**
```php
<?php return [
  'cache_dir' => __DIR__.'/../cache/views',
  'paths'     => [
    __DIR__.'/../views',
  ],
  // Any other option you use in you app:
  'debug'     => true,
];
```

**cli.php**
```php
<?php

$options = include __DIR__.'/../config/phug.php';

if (!file_exists($options['cache_dir']) && !@mkdir($options['cache_dir'], 0777, true)) {
    throw new \RuntimeException(
        $options['cache_dir'].' cache directory could not be created.'
    );
}

Phug::addExtension(\Phug\WatcherExtension::class);

Phug::setOptions($options);
```

**web.php**
```php
<?php

include_once __DIR__.'/../vendor/autolod.php';

$options = include __DIR__.'/../config/phug.php';

Phug::setOptions($options);
```

**index.php**
```php
<?php

include_once __DIR__.'/bootstrap/web.php';

Phug::displayFile('home');
```

And you can run the watcher with:
```shell
./vendor/bin/phug watch -b bootstrap/cli.php
```

When you will edit any file in the *views* directory
and save it, it will automatically refresh the cache
(as long as the command is running).

If you CLI bootstrap has the default location
(phugBootstrap.php), you can simply do:
```shell
./vendor/bin/phug watch
```

## <i id="browser-reload"></i>Automatically reload the browser on change

Browser auto-reloading also need the `phug/watcher` package
to be installed (see above).

It allows you to start a development server and a watcher in
parallel on 2 different ports with the following command:

```shell
./vendor/bin/phug listen 9000 index.php
```

It will start a dev server as if you did:

```shell
php -S localhost:9000 index.php
```

Supposing you load the \Phug\WatcherExtension in **index.php**,
it will add a `<script>` tag in the rendering to watch changes and
refresh the page when they happen (communicating on a second
port, by default 8066).

For example if you did some basic watcher install:

```shell
composer require phug/watcher
./vendor/bin/watcher --init
```

And have the following **index.php**:

```php
<?php

include_once __DIR__ . '/vendor/autoload.php';

include_once __DIR__ . '/phugBootstrap.php';

Phug::displayFile('views/basic.pug');
```

Then by runing `./vendor/bin/phug listen 9000 index.php`, you
will be able to load http://localhost:9000 in a browser and the
page will auto-refresh if you change the `views` directory.

## Unit tests and coverage

You can try out our experimental testing CLI tool using PHPUnit and
xdebug including Pug files coverage reports and all-in-one PHP and
Pug unit tests helpers:

https://github.com/phug-php/tester
