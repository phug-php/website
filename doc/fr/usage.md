# Utilisation

Créez un ou plusieurs dossiers de templates, et créez vos fichiers
pug dedans.

Par exemple, imaginons que **maVue.pug** soit dans le dossier
**dossiers/des/vues** et contienne :

```phug
h1=$titre
```
```vars
[
  'titre' => 'Entête',
]
```

Vous pouvez alors afficher le rendu de ce fichier de la manière
suivante :
```php
<?php

include_once __DIR__ . '/vendor/autoload.php';

$variables = [
   'titre' => 'Entête',
];

$options = [
  'paths' => [
    'dossiers/des/vues',
  ],
];

Phug::displayFile('maVue', $variables, $options);
```

Il est recommandé d'utiliser `displayFile` autant que possible pour
des raisons de performances (`displayFile` est plus performant que
`echo renderFile`) et les fichiers pour être mis en cache plus
rapidement qu'un contenu brut, donc en production
`displayFile('maVue.pug')` est plus rapide que
`display('le contenu du fichier')`.

En production, il est également recommandé d'utiliser l'*Optimizer*
et le cache :

```php
<?php

include_once __DIR__ . '/vendor/autoload.php';

// À remplacer par votre propre calcul d'environnement.
$environnement = getenv('ENVIRONNEMENT') ?: 'production';

$variables = [
   'titre' => 'Entête',
];

$options = [
  'debug'     => false,
  'cache_dir' => 'chemin/du/dossier-de-cache', 
  'paths'     => [
    'dossiers/des/vues',
  ],
];

if ($environnement === 'production') {
    \Phug\Optimizer::call('displayFile', ['maVue', $variables], $options);

    exit;
}

$options['debug'] = true;
$options['cache_dir'] = null;

Phug::displayFile('maVue', $variables, $options);
```

L'*Optimizer* est un outil qui permet de ne pas charger le moteur
de Phug si le fichier est en cache. En contre-partie, il ne permet
pas de changer l'adapter ou d'utiliser les événements post-rendu.

Si vous utilisez **Pug-php**, remplacez juste dans le code ci-dessus
`\Phug\Optimizer` par `\Pug\Optimizer` et
`Phug::displayFile` par `\Pug\Facade::displayFile`.

Le cache peut être utilisé en développement également pour gagner
du temps.

Enfin en production, vous devriez utiliser l'option
`--optimize-autoloader` de composer pour optimier l'autoloader
lors de l'installation des dépendences. Puis vous devriez
cacher l'intégralité de vos templates pour bénéficier
de l'option [`up_to_date_check`](#up-to-date-check-boolean)

```shell
composer update --optimize-autoloader
./vendor/bin/phug compile-directory dossiers/des/vues chemin/du/dossier-de-cache '{"debug":"false"}'
```

En faisant ça à chaque déploiement, vous pouvez alors
régler l'option `up_to_date_check` à `true` pour charger
directement le cache sans vérification des fichiers.

Voyez la section [CLI](#cli) pour plus d'informations sur
la ligne de commande.
