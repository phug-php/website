# Alternatives

Il existes des méthodes alternatives pour avoir des templates pug
avec un back-end PHP.

## V8Js

http://php.net/manual/fr/book.v8js.php

Vous pouvez utiliser le moteur V8 depuis PHP. Vous pourriez alors
avoir besoin de `setModuleLoader` pour charger le module node de pug
et ses dépendances automatiquement.

Ensuite vous pouvez charger et exécuter pug avec `executeString`
en lui passant des données PHP. Cela peut s'avérer le moyen
le plus rapide d'obtenir le comportement exact de pugjs avec
des données PHP.

À notre connaissance, aucune solution prêt à l'emploi de ce
type n'existe. Si vous en avez fait ou en connaissez une,
n'hésitez pas à cliquer sur le bouton [Modifier] pour nous
soumettre une pull-request.

## Pug-php avec l'option pugjs

Quand vous installez **Pug-php**, on vous propose l'installation
du paquet node **pug-cli**. Si vous entrez `Y`, `npm` sera
utilisé si disponible sur la machine pour installer le paquet
officiel `pug-cli`, et **Pug-php** a une option pour l'utiliser
à la place de son moteur :

```php
<?php

include 'vendor/autoload.php';

$pug = new Pug([
  'pugjs' => true,
]);

$html = $pug->render('p=9..toString()');
```

Ici vous appelez le paquet natif de pug en utilisant
directement node.js, c'est pour ça que vous pouvez utiliser
n'importe quelle syntaxe JS.

Si vous utilisez cette option, soyez conscient que nous ne
sommes plus responsables de ce qu'il se passe à l'intérieur
des templates, ce n'est plus PHP qui est utilisé et la
documentation de référence est alors https://pugjs.org

Optionnellement, vous pouvez spécifier le chemin vers les
programmes node et pug-cli avec les outils suivants :

```php
$pug = new Pug([
  'pugjs' => true,
  'nodePath' => __DIR__ . '/../bin/node',
]);
NodejsPhpFallback::setModulePath('pug-cli', __DIR__ . '/../node_modules/pug-cli');
```
