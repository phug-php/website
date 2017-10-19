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

### Pourquoi un moteur de templates ?

### Pourquoi pas pugjs ?

### Pourquoi migrer vers Phug ?
