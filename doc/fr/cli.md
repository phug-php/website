# CLI

**Phug** et **Pug-php** peuvent être exécutés en ligne de
commande :

```shell
./vendor/bin/phug render 'p=$msg' '{"msg": "Salut"}'
./vendor/bin/pug render 'p=msg' '{"msg": "Salut"}'
```

`./vendor/bin/pug` n'est disponible que si vous installez
**Pug-php**,
`./vendor/bin/phug` est toujours disponible que vous utilisiez
l'un ou l'autre.

## Options globales

2 options globales sont disponibles pour toutes les commandes :

`--output-file` (ou `-o`) redirige la sortie vers le fichier
spécifié, cela permet par exemple d'enregister le rendu HTML
dans un fichier :
```shell
./vendor/bin/phug render-file mon-fichier-source.pug --output-file mon-fichier-de-destination.html
```

`--bottstrap` (ou `-b`) permet d'inclure un fichier PHP à
exécuter avant la commande. Par exemple, vous pouvez y définir
vos variables de manière dynamique.

Mettons que vous avez le fichier suivant : **definition-variables.php**
```php
Phug::share([
  'heure' => date('H:i'),
]);
```

```shell
./vendor/bin/phug render 'p=$heure' -b definition-variables.php -o page.html
```

**page.html** va contenir un paragraphe avec l'heure
à l'intérieur (exemple `<p>17:47</p>`).

Le fichier de démarrage peut exécuter n'importe quel code PHP
et a accès à toutes les classes grâce à l'autoload de Composer.

Ces deux options peuvent être définies avec un espace ou le
symbole égal, donc toutes les commandes ci-dessous sont
équivalentes :

```shell
./vendor/bin/phug render-file a.pug --output-file a.html
./vendor/bin/phug render-file a.pug --output-file=a.html
./vendor/bin/phug render-file a.pug -o a.html
./vendor/bin/phug render-file a.pug -o=a.html
```

## Commandes

Les commandes sont les mêmes pour **phug** et **pug** et
elles vont appeler les mêmes méthodes. La seule différence
est que **phug** va les appeler sur la façade `Phug`
(qui utilise `Phug\Renderer` sans extension ni réglages
particuliers) et **pug** va les appeler sur la façade
`Pug\Facade` (qui utilise `Pug\Pug` that comes with `js-phpize` and the **pug-php**
default settings). For both, you can use `--bottstrap`
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

If you call such command each time you put something new in
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
