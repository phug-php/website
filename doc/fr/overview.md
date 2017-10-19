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

### Pourquoi pas pugjs ?

### Pourquoi migrer vers Phug ?
