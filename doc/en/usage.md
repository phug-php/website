# Usage

Create one or more templates directories, and create pug
files in them.

For example, imagine that **myView.pug** is in the
**views/directory** directory and contains:

```phug
h1=$title
```
```vars
[
  'title' => 'Header',
]
```

You can display the matching HTML of this file like this:
```php
<?php

include_once __DIR__ . '/vendor/autoload.php';

$variables = [
   'title' => 'Header',
];

$options = [
  'paths' => [
    'views/directory',
  ],
];

Phug::displayFile('myView', $variables, $options);
```

We recommend to use `displayFile` as much as possible for
performances (`displayFile` is faster than
`echo renderFile`) and files can be cached faster than a
raw content so in production
`displayFile('myView.pug')` is faster than
`display('the content of the file')`.

In production, we also recommend to use the *Optimizer*
and the cache:

```php
<?php

include_once __DIR__ . '/vendor/autoload.php';

// Replace with your own environment calculation
$environment = getenv('ENVIRONMENT') ?: 'production';

$variables = [
   'title' => 'Header',
];

$options = [
  'debug'     => false,
  'cache_dir' => 'cache/directory', 
  'paths'     => [
    'views/directory',
  ],
];

if ($environment === 'production') {
    \Phug\Optimizer::call('displayFile', ['myView', $variables], $options);

    exit;
}

$options['debug'] = true;
$options['cache_dir'] = null;

Phug::displayFile('myView', $variables, $options);
```

The *Optimizer* is a tool that avoid to load the Phug engine
if a file is available in the cache. In counterpart, it
does not allow to change the adapter or user post-render
events.

If you use **Pug-php**, just replace in the code above
`\Phug\Optimizer` with `\Pug\Optimizer` and
`Phug::displayFile` with `\Pug\Facade::displayFile`.

The cache can be used in development too to save time.

In production, you should use the `--optimize-autoloader`
option of composer to optimize the autoloader when installing
dependencies. Then you should cache all your templates to
get benefit of the
[`up_to_date_check` option](#up-to-date-check-boolean)

```shell
composer update --optimize-autoloader
./vendor/bin/phug compile-directory views/directory cache/directory '{"debug":"false"}'
```

By doing this for each deployment on your server,
you will be able to set `up_to_date_check` option to `true`
to directly load cache file with no file check.

In development environment, you can update automatically
the cache and auto-refresh the page using the
[*watcher*](#watch).

See [CLI](#cli) for more information about the
command line.
