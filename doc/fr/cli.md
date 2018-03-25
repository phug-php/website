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

Si un fichier s'appelle `phugBootstrap.php` dans le dossier
courant, alors il sera utilisé comme fichier de démarrage par
défaut.

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
`Pug\Facade` (qui utilise `Pug\Pug` et embarque `js-phpize`
et les réglages par défaut de **pug-php**). Pour les deux,
vous pouvez utiliser `--bootstrap` pour régler plus
d'options, ajouter des extension, partager des variables,
etc.

### render (ou display)

Appelle `::render()` et prend 1 argument requis : le code
pug d'entrée (en tant que chaîne de caractères), et 2
arguments optionnels : les variables locales (au format JSON)
et les options (au format JSON)

```shell
./vendor/bin/phug render 'p(foo="a")' '{}' '{"attributes_mapping":{"foo":"bar"}}'
```

Va afficher :
```html
<p bar="a"></p>
```

### render-file (ou display-file)

Appelle `::renderFile()`, c'est exactement la même chose que
`render` sauf qu'il prend un chemin defichier en premier
argument :

```shell
./vendor/bin/phug render-file /dossier/fichier.pug '{"maVariable":"valeur"}' '{"self":true}'
```

### render-directory (ou display-directory)

Appelle `::renderDirectory()`, effectue le rendu de chacun des
fichiers contenus dans un dossier et dans ses sous-dossiers.
Cette commande prend 1 argument requis : le dossier d'entrée,
et 3 arguments optionnels :
 - le dossier de sortie (si non spécifié, le dossier d'entrée
 est utilisé, donc les fichiers rendus sont générés à côté
 des fichiers d'entrée)
 - extension des fichiers de sortie (`.html` par défaut)
 - variables locales (au format JSON)
 
```shell
./vendor/bin/phug render-directory ./templates ./pages '.xml' '{"foo":"bar"}' 
``` 
 
En supposant que vous avez le dossier `./templates` suivant :
```
templates
  une-vue.pug
  sous-dossier
    autre-vue.pug
``` 
Vous allez obtenir le dossier `.pages` suivant :
```
pages
  une-vue.xml
  sous-dossier
    autre-vue.xml
``` 

Et dans cet exemple, tous les fichiers rendus auront
`$foo = "bar"` comme variables locales disponibles.

### compile

Appelle `::compile()`. Compile du code pug sans le rendre
(l'exécuter). Elle prend 1 argument requis : le code pug
et 1 optionnel : un nom de fichier (peut aussi être fourni
via les options), il sera utiliser pour résoudre les
imports relatifs.

```shell
./vendor/bin/phug compile 'a(href=$lien) Aller' 'fichier.pug' -o fichier.php
```

Ceci va écrire dans **file.php** un contenu semblable à :
```php
<a href="<?= htmlspecialchars($lien) ?>">Aller</a>
```

### compile-file

Appelle `::compileFile()`. Compile un fichier pug sans le
rendre.

```shell
./vendor/bin/phug compile-file vues/index.pug -o public/index.php
```

### compile-directory (ou cache-directory)

Appelle `::cacheDirectory()` (via `::textualCacheDirectory()`).
Compile chaque fichier d'un dossier et de ses sous-dossiers.

C'est le moyen parfait de mettre en cache tous vos fichiers pug
lorsque vous déployer une nouvelle version de votre application
sur un serveur de production.

Si vous appeler cette commande à chaque fois que vous mettez
quelque chose de nouveau en production, vous pouvez alors
désactiver la vérification de cache en utilisant l'option
`'up_to_date_check' => false` pour optimiser les performances.

```shell
./vendor/bin/phug compile-directory vues cache '{"option":"valeur"}'
```

Seul le premier argument est requis (le dossier d'entrée où
sont stockés vos fichiers pug).

En deuxième argument optionnel, vous pouvez spécifier le
chemin du dossier de cache, sinon le chemin spécifié via
l'option `cache_dir` sera utilisé, si non spécifié,
le dossier temporaire du système sera utilisé.

Le troisième argument (aussi optionnel) permet de passer
des options au format JSON si besoin.

### commandes personnalisées

Vous pouvez créer des commandes personnalisées grâce à
l'option *commands* :

Par exemple si vous écrivez ceci dans un fichier
**phugBootstrap.php** (dans le dossier dans lequel
vous exécutez les commandes, généralement à la racine de
votre projet) ou dans n'importe quel autre fichier de
votre projet que vous chargez avec l'option de CLI
`--bootstrap` :
```php
<?php

Phug::setOption('commands', [
  'renderDate' => function () {
    return Phug::render('p=date("d/m/Y")');
  },
]);
```

Vous pourrez alors lancer la commande suivante :
```shell
./vendor/bin/phug render-date
```

Et ceci affichera la date dans un paragraphe :
```html
<p>09/02/2018</p>
```

L'option *commands* doit être un array listant les
commandes personnalisées, chaque commande peut être
décrit de 3 manière différentes :
```php
<?php

Phug::setOption('commands', [
  'cacheFile',
    // Rend la méthode Phug::cacheFile()
    // disponible avec son nom en casse kebab :
    // ./vendor/bin/phug cache-file

  'storeFile' => 'cacheFile',
    // Rend la méthode Phug::cacheFile()
    // avec un autre nom :
    // ./vendor/bin/phug store-file

  'maFonction' => function () {
    return 'Salut';
  },
    // Exécute la fonction avec le nom donné :
    // ./vendor/bin/phug ma-fonction
]);
```

La commande peut également appeler un
[macro](#macros-array).

## <i id="watch"></i>Détecter les changements et compiler automatiquement

Pour utiliser la commande **watch**, vous aurez
besoin d'installer `phug/watcher` :
```shell
composer require phug/watcher
```

Et vous pouvez utiliser la commande `--init` pour créer
un fichier **phugBoostrap.php** utilisé par défaut comme
fichier de démarrage par le programme phug.
```shell
./vendor/bin/watcher --init
```

Dans ce fichier, vous pouvez modifier la liste des dossiers
à surveiller (*./views* et *./templates* par défaut) et
vous pouvez changer le chemin du cache (par défaut, un
dossier *phug-cache* est créé dans le dossier temporaire
du système).

Puis ce fichier active l'extension du watcher et
régler les options de Phug.

Pour fonctionner correctement, les options utilisées
doivent être les mêmes qie dans votre application.
Pour les garder synchronisées vous pouvez utiliser
un fichier de configuration commun.

Par exemple, mettons que votre app a la structure
suivante :
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

Alors vous pouvez avoir les contenus suivants :

**phug.php**
```php
<?php return [
  'cache_dir' => __DIR__.'/../cache/views',
  'paths'     => [
    __DIR__.'/../views',
  ],
  // N'importe quelle autre option utilisée dans
  // votre application
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

Et vous pouvez lancer le watcher avec :
```shell
./vendor/bin/phug watch -b bootstrap/cli.php
```

Quand vous éditerez un fichier dans le dossier *views*
et l'enregistrer, le cache sera rafraîchit
automatiquement (tant que la commande sera en cours
d'exécution).

Si votre démarrage CLI utiliser l'emplacement par
défaut (phugBoostrap.php), vous pouvez simplement
faire :
```shell
./vendor/bin/phug watch
```

## <i id="browser-reload"></i>Recharger le navigateur automatiquement en cas de changement

L'auto-rechargement du navigateur a aussi besoin du paquet
`phug/watcher` (voir plus haut pour l'installer).

Il permet de démarrer un serveur de développement et un *watcher*
en parallèle sur 2 ports différents avec la commande suivante :

```shell
./vendor/bin/phug listen 9000 index.php
```

Ceci va démarrer un serveur de développement comme l'aurait fait :

```shell
php -S localhost:9000 index.php
```

Et une balise `<script>` est aussi ajoutée au rendu pour surveiller
les changements et rafraîcher la page lorsqu'il y en a (en commiunicant
sur un second port, par défaut 8066).
