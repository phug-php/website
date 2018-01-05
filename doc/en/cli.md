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
