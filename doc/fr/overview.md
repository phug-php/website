# Vue d'ensemble

**Phug** est le moteur de templates de [pug](https://pugjs.org/) pour PHP.

Phug offre un moyen simple d'écrire des templates (telles que des pages
HTML).

Exemple :

```phug
body
  h1 Phug
```

Au lieu d'écrire de verbeuses balises, Phug est structuré par indentation
(comme le Python, CoffeeScript ou Stylus).
Ici `<h1>` est à l'intérieur de `<body>` car `h1` a un niveau
d'indentation de plus. Essayez de supprimer les espaces, vous verez
que `<h1>` et `<body>` sont alors au même niveau. Vous pouvez indenter
avec autant de tabulations ou espaces que vous voulez, Phug va toujours
essayer de deviner la structure en détectant les niveaux d'indentation.
Toutefois il est recommandé d'avoir un indentation constante dans vos
fichiers.

En tant que moteur de templates, Phug fournit aussi un moyen optimisé
de gérer les valeurs dynamiques.

Exemple :

```phug
- $var = true
if $var
  p S'affiche si $var vaut true
else
  p S'affiche sinon
```

Essayez de passer `$var` à `false` pour voir comment réagit le template.

Les variables peuvent être définies à l'extérieur des templates (par exemple
dans les contrôleurs):

```phug
label Nom
input(value=$nom)
```
```vars
[
  'nom' => 'Bob',
]
```

Phug est écrit en PHP, donc par défaut, les expressions sont en PHP,
mais vous pouvez activer des modules tels que :
[js-phpize](https://github.com/pug-php/js-phpize-phug) ou utiliser un
wrapper comme
[pug-php](https://github.com/pug-php/pug) qui active par défaut
js-phpize. Voyez la comparaison ci-dessous :

**Phug**:
```phug
p=$arr['obj']->a . $arr['obj']->b
```
```vars
[
  'arr' => [
    'obj' => (object) [
      'a' => 'A',
      'b' => 'B',
    ],
  ],
]
```
**Pug-php**:
```pug
p=arr.obj.a + arr.obj.b
```
```vars
[
  'arr' => [
    'obj' => (object) [
      'a' => 'A',
      'b' => 'B',
    ],
  ],
]
```

Maintenant que vous savez ce qu'est Phug, vous pouvez :
 - [voir comment l'installer dans le chapitre suivant](#installation)
 - [consulter le projet original pugjs](https://pugjs.org)
 - [voir toutes les fonctionnalités de ce language](#language-reference)
 
Si vous n'êtes pas sûr que Phug est adapté à vos besoin, consultez
la section **Pourquoi** ci-dessous :

## Pourquoi Phug ?

Le HTML est né en 1989 au CERN, et il paraît tout à fait adapté ou tout
du moins suffisant pour remplir son office alors : écrire des pages de
texte avec des titres et des liens. C'est une merveilleuse invention
mais de nos jours, nous construisons des interfaces utilisateurs
pour des supports très variés et ce n'est pas parce que le HTML est
ce que nous devons envoyer aux navigateurs que c'est nécessairement
ce language que nous, développeurs humains, devons utiliser pour coder
nos pages. Beaucoup de moteur de template se contentent de permettre
l'insertion d'éléments dynamiques dans du HTML, avec un moteur comme
Phug, vous n'écrivez plus du tout de HTML. Vous avez le choix, alors
autant choisir un language propre et adapté qui embarque également
une floppée d'outils dédiés aux templates (layouts, mixins, conditions,
itérations, etc.)

Notez que Phug supporte plusieurs versions et doctypes différents de
HTML mais également XML, et que vous pouvez aisément créer n'importe
quel autre format qui puisse vous être utile, tout comme vous pouvez
personnaliser le traitement des expressions, etc. Phug a beaucoup
d'options et de possibilités d'extension, *vraiment* beaucoup.

### Pourquoi un moteur de templates ?

La majorité des frameworks PHP ont un système de templates. C'est un
moyen efficace de séparer la couche de présentation. Déléguer la
responsabilité de la vue à un moteur de template est une bonne pratique
car cela évite de mélanger de la logique (calcul, récupération et
traitement de données) avec de la présentation (affichage, formattage)
et vous aidera à respecter le PSR (principe de responsabilité unique
qui vise en programmation à ne pas donner à une entité de multiples
responsabilités), vous pourrez alors organiser vos vues en pages
et composants visuels sans aucune contrainte vis-à-vis de votre
code PHP.

Enfin, si vous respecter ce principe (en évitant entre autre d'insérer
des traitements dans vos templates), alors vos templates ne
contiendront pas de code complexe mais simplement des insertions
de variable, ce qui rend ce code aisément modifiable même pour
quelqu'un qui connaît pas le back-end de votre application, le
développeur qui a la responsabilité de modifier les fichiers `.pug`
n'a apriori même pas besoin de connaître le PHP.

### Pourquoi pas pugjs ?

N'est-il pas possible d'utiliser le package JavaScript de pug
dans une application PHP ? Si. Il y a même de nombreuses façons
d'y arriver. Voyez la section [alternatives](#alternatives)
pour plus de détails. Mais sachez que cette approche a des
limites. La plus importante est l'aplatissement des données.
N'importe quelle instance de classe deviendra un objet plat
pour être passé à pugjs, c'est à dire qu'il perdra ces méthodes.

Voici un exemple de ce que Phug permet mais que pugjs ne pourra
pas faire s'il est appelé à travers un proxy ou une commande :

```pug
p=aujourdhui.format('d/m/Y H:i')
```
```vars
[
  'aujourdhui' => new DateTime('now'),
]
```

### Pourquoi migrer vers Phug ?

Vous utilisez peut-être déjà une autre librairie PHP proposant
la syntaxe Pug.

Tout d'abord si vous n'utilisez pas composer, je ne peux que vous
encouragez à adopter ce système de gestion des dépendences.
Il est sans équivalent dans l'écosystème PHP en terme de paquets
disponibles et il vous permettra de garder vos dépendences à
jour très facilement. Je vous invite donc à choisir votre
librairie parmi celle disponible via composer (voir https://packagist.org/) 

Ensuite sachez que si vous utilisez un projet dont le nom
contient "jade", il y a de grandes chances qu'il soit obsolète
car jade est l'ancien nom de pug, par exemple les packages
**kylekatarnls/jade-php**, **ronan-gloo/jadephp**,
**opendena/jade.php**, **jumplink/jade.php**, **dz0ny/jade.php**
et **everzet/jade** sont tous basés sur le projet de base et aucun
n'est plus maintenu, ils ne sont pas compatibles avec pugjs 2
et beaucoup de fonctionnalités de pug leur font défaut. Le projet
le plus à jour qui les remplace tous est **pug-php/pug**. Dans sa
version 2, il utilise toujours le même moteur. Sa version 3 quant
à elle utilise désormais Phug.
De même **talesoft/tale-jade** a été remplacé par
**talesoft/tale-pug** et la version 2 de **talesoft/tale-pug**
utilisera elle aussi Phug.

**talesoft/tale-pug** et **pug-php/pug** sont les ports PHP de
Pug les plus utilisés et sont activement maintenus. En utilisant
la dernière version de ces projets, vous allez donc
automatiquement migrer sur le moteur Phug et étant donné que les
contributeurs de ces deux projets sont maintenant tous regroupés
dans le projet Phug et déveloperont en priorité Phug, vous
bénéficierez du meilleur support possible.

Pour mettre à jour **pug-php/pug** et bénéficier de toutes les
fonctionnalités décrites dans cette documentation, exécutez la
commande suivante dans votre projet :

```shell
composer require pug-php/pug:"^3.0"
```

Pour être prévenu de la sortie de la version 2 de **talesoft/tale-pug**
vous pouvez utiliser https://www.versioneye.com/ et ajouter
**talesoft/tale-pug** à votre liste des paquets à surveiller.

Enfin, nous pouvons vous assurer que Phug surpasse les autres
implémentations existantes sur de nombreux sujets :
 - Extensibilité, personalisation, formats, options
 - Intégration et installation très simple dans les
 différents frameworks
 - Documentation
 - Outil de test en live
 - Gestion des expressions (js-phpize ou n'importe tel language personnalisé)
 - Gestion des assets et de la minification (pug-assets)
 - Traçace des erreurs
 - Profiling
 - Réactivité de la communauté (issues et pull-request sur GitHub,
 et les tags [pug] [php] sur https://stackoverflow.com/search?q=pug+php)
