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
Phug::display($template, $variablesLocales, $options);
```

Note: Si vous utilisez **Pug-php**, il va essayer de détecter si
la chaîne passée est un chemin de fichier et utiliser `displayFile`
si c'est le cas. Ce comportement existe pour raison de
rétro-compatibilité mais vous êtes encouragé à le désactiver en
réglant l'option `"strict"` à `true`.

## Méthodes avancées

Voir la [documentation complète de l'API](/api/namespaces/Phug.html).
