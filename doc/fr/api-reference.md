# Référence de l'API

Ceci est un résumé des méthodes principales disponibles.
Vous pouvez également consulter la documentation auto-générée
en cliquant sur le lien ci-dessous :

[Documentation complète de l'API](/api/namespaces/Phug.html)

## displayFile

```php
$template = '/mon/fichier/template.pug';
$variablesLocales = [
  'nomDeVariable' => 'valeur',
];
$options = [
  'cache_dir' => '/chemin/vers/un/dossier/de/cache',
];


// syntaxe Facade (avec Phug)
Phug::displayFile($template, $variablesLocales, $options);


// syntaxe Instance (avec Phug)
$renderer = new Phug\Renderer($options);
$renderer->displayFile($template, $variablesLocales);


// syntaxe Facade (avec Pug-php)
Pug\Facade::displayFile($template, $variablesLocales, $options);


// syntaxe Instance (avec Pug-php)
$renderer = new Pug($options);
$renderer->displayFile($template, $variablesLocales);
```

Ceci va afficher le fichier de template rendu dans la sortie
standard. C'est la manière recommandée d'utiliser **Phug**. 

Consultez la [section utilisation](#usage) pour voir comment
optimiser le rendu en production.

Consultez la [section des options](#options) pour voir la liste
complète des options disponibles.

## display

Se comporte comme `displayFile` mais prend du code source pug
comme premier argument :
```php
$template = '
div: p.examples
  em Foo
  strong(title="Bar") Bar
';


// syntaxe Facade (avec Phug)
Phug::display($template, $variablesLocales, $options);


// syntaxe Instance (avec Phug)
$renderer = new Phug\Renderer($options);
$renderer->display($template, $variablesLocales);


// syntaxe Facade (avec Pug-php)
Pug\Facade::displayString($template, $variablesLocales, $options);


// syntaxe Instance (avec Pug-php)
$renderer = new Pug($options);
$renderer->displayString($template, $variablesLocales);
```

Note: Si vous utilisez **Pug-php**, il va essayer de détecter si
la chaîne passée est un chemin de fichier et utiliser `displayFile`
si c'est le cas. Ce comportement existe pour raison de
rétro-compatibilité mais vous êtes encouragé à le désactiver en
réglant l'option `"strict"` à `true` ou utilisez `displayString`.

## renderFile

`renderFile` est comme `displayFile` mais retourne la sortie
au lieu de l'afficher.

## render

`render` est comme `display` mais retourne la sortie
au lieu de l'afficher.

Note: Si vous utilisez **Pug-php**, il va essayer de détecter si
la chaîne passée est un chemin de fichier et utiliser `renderFile`
si c'est le cas. Ce comportement existe pour raison de
rétro-compatibilité mais vous êtes encouragé à le désactiver en
réglant l'option `"strict"` à `true` ou utilisez `renderString`.

## renderAndWriteFile

Effectue le rendu d'un fichier pug puis écrit le résultat final
(souvent du HTML) dans un fichier.

Retourne `true` en cas de succès, `false` sinon.

```php
$input = '/mon/fichier/template.pug';
$output = '/ma/page.html';
$variablesLocales = [
  'nomDeVariable' => 'valeur',
];
$options = [/* ... */];


// syntaxe Facade (avec Phug)
if (Phug::renderAndWriteFile($input, $output, $variablesLocales, $options)) {
  echo 'Fichier écrit avec succès.';
}


// syntaxe Instance (avec Phug)
$renderer = new Phug\Renderer($options);
if ($renderer->displayFile($template, $variablesLocales)) {
  echo 'Fichier écrit avec succès.';
}


// syntaxe Facade (avec Pug-php)
if (Pug\Facade::displayFile($template, $variablesLocales, $options)) {
 echo 'Fichier écrit avec succès.';
}


// syntaxe Instance (avec Pug-php)
$renderer = new Pug($options);
if ($renderer->displayFile($template, $variablesLocales)) {
  echo 'Fichier écrit avec succès.';
}
```

## renderDirectory

Effectue le rendu de tous les fichiers pug contenus (récursivement) dans un dossier d'entrée
et créer les fichiers obtenus dans un dossier de sortie.
Si aucun dossier de sortie n'est spécifié, le même dossier sera utilisé pour l'entrée et la
sortie.

Retourne un array avec le nombre de succès et le nombre d'erreurs.

```php
$renderer = new Phug\Renderer($options); // ou $renderer = new Pug($options);

$renderer->renderDirectory('./mes-vues'); // effectue le rendu de tous les fichiers pug dans ./mes-vues
                                          // et écrit les fichiers .html côte-à-côté
$renderer->renderDirectory('./mes-vues', ['foo' => 'bar']); // la même chose avec des variables locales
$renderer->renderDirectory('./mes-vues', './mes-pages'); // effectue le rendu de tous les fichiers pug dans ./mes-vues
                                                       // et écrit les fichiers .html dans ./mes-pages
$renderer->renderDirectory('./mes-vues', './mes-pages', ['machin' => 'chose']); // la même chose avec des variables locales
$renderer->renderDirectory('./mes-vues', './mes-pages', '.xml'); // utilise l'extension .xml au lieu de celle par défaut .html
$renderer->renderDirectory('./mes-vues', './mes-pages', '.xml', ['foo' => 'bar']); // la même chose avec des variables locales
```

## compileFile

Compile a file and return the rendering code. It means when
`renderFile` typically returns HTML, `compileFile` mostly returns
PHP, by executing this PHP code, you would get the final HTML.

This may allow you for example to delegate the view rendering
and caching to an other engine/framework.

```php
$template = '/mon/fichier/template.pug';
$options = [
  // options de compilation seulement puisque les
  // options de rendu ne seront pas utilisées.
];

// syntaxe Facade (avec Phug)
Phug::compileFile($template, $options);


// syntaxe Instance (avec Phug)
$renderer = new Phug\Renderer($options);
$renderer->compileFile($template);


// syntaxe Facade (avec Pug-php)
Pug\Facade::compileFile($template, $options);


// syntaxe Instance (avec Pug-php)
Phug::display($template, $variablesLocales, $options);
```

## compile

Se comporte comme `compileFile` mais prend du code source pug
comme premier argument.

## cacheFile

Compile un fichier pug et l'enregistre dans le dossier cache spécifié
via les options.

## cacheFileIfChanged

Compile un fichier pug et l'enregistre dans le dossier cache spécifié
via les options à moins qu'un fichier à jour soit déjà présent dans le
cache.

## cacheDirectory

Met en cache tous les fichiers pug contenu (récursivement) dans le
dossier passé en argument.

## Méthodes avancées

Voir la [documentation complète de l'API](/api/namespaces/Phug.html).
