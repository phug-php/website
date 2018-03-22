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

## Méthodes avancées

Voir la [documentation complète de l'API](/api/namespaces/Phug.html).
