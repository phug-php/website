# Overview

## What is Phug?

**Phug** is the [pug](https://pugjs.org/) template engine for PHP.

Phug offer you a clean way to write your templates (such as HTML pages).

Example:

```phug
body
  h1 Phug
```

Instead of writing verbose tags syntax, Phug is based on the indentation
(like Python, CoffeeScript or Stylus).
Here `<h1>` is inside `<body>` because `h1` has one more indent level. Try
to remove the spaces, you will see `<h1>` becoming a sibling of `<body>`
instead of a child. You can indent with any tabs or spaces you want, Phug
will always try to guess the structure by detecting indent level. However
we recommend you to have consistent indentation in you files.

As a template engine, Phug also provide an optimized way to handle dynamic
values.

Example:

```phug
- $var = true
if $var
  p Displayed only if $var is true
else
  p Fallback
```

Try to set `$var` to `false` to see how the template react to it.

Variables can be set outside of your template (for example in a controller):

```phug
label Username
input(value=$userName)
```
```vars
[
  'userName' => 'Bob',
]
```

Phug is written in PHP, so by default, expressions are written in PHP,
but you can plug modules such as
[js-phpize](https://github.com/pug-php/js-phpize-phug) or wrapper like
[pug-php](https://github.com/pug-php/pug) that enable this module by
default to get js expressions working in your templates. See the
comparison below:

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

Now you know what Phug is you can:
 - [see how to install it in the next chapter](#installation)
 - [check the original JS project](https://pugjs.org)
 - [see all the language features](#language-reference)

If you are not sure you should use Phug or not, please check our **Why** section
below:

## Why Phug?

HTML is born in 1989 in the CERN, and it seem to suit, or at least to
be sufficient for its purpose: write pages with titles and links.
It's a wonderful invention but nowadays, we build user interfaces for
various devices and it's not because HTML is what we must send to
the browsers that we, human developers, must use to code our pages. 
A lot a template engines just allow to insert dynamic elements inside
HTML, with an engine like Phug, you will no longer write HTML at all. 
You have choices, so why not choosing a clean and suitable language
that also embed many tools dedicated to templates (layouts, mixins,
conditions, iterations, etc.)

Note that Phug support several versions and doctypes  of HTML but
also XML, and you van easily create any format you would need ; as
you can customize expressions handling, etc. Phug has much options
and extension possibilities, *very* much.

### Why a template engine?

Most PHP frameworks have a templates system. It's a efficient way to
separate the view layer. Delegate view responsability to template
engine is a best practice since it avoids mixing logic (calcul, retrieving
and parsing data) with presentation (display, formatting) and it will
help you to respect the PSR (principal of single responsability, that
aims to not giving an entity multiple responsibilities), so you will
be able to organize your views into pages and visual components with
no constraint from your PHP code.

Finally, if you respect this principle (by avoiding inserting, among
others, inserting treatments in your templates), then your templates
will not contain complex code but only variable inserts. This make this
code easy to modify for someone who don't know your application back-end
and even neither the PHP language.

### Why not to use pugjs?

Isn't it possible to use the JavaScript pug package in a PHP
application? Yes it is. There are even many ways to achieve this
goal. See the [alternatives](#alternatives) section for more
details. But know this approach has limits. Most important is
the data flattening. Any class instance become a flat object
when passed through pugjs, it means the object will lost
its methods.

Here is a example of what's working well with Phug but would not
be possible with pugjs if called via a proxy or a command:

```pug
p=today.format('d/m/Y H:i')
```
```vars
[
  'today' => new DateTime('now'),
]
```

### Why upgrade/migrate to Phug?

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
**opendena/jade.php**, **jumplink/jade.php**, **dz0ny/jade.php**,
**everzet/jade** are all no longer maintained projects that fork
the same origin, they are not pugjs 2 compliant and miss a lot
of pug features. The most up-to-date project that replace them
all is **pug-php/pug**. In its version 2 it still use the same
original engine.
Same goes for **talesoft/tale-jade** replaced with
**talesoft/tale-pug** and its version 2 will also use Phug.

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
composer require pug-php/pug:"^3.0@beta"
```

Pour être prévenu de la sortie de la version 2 de **talesoft/tale-pug**
vous pouvez utiliser https://www.versioneye.com/ et ajouter
**talesoft/tale-pug** à votre liste des paquets à surveiller.

Enfin, nous pouvons vous assurer que Phug surpasse toutes les
implémentations existantes sur de nombreux sujets :
 - Extensibilité, personalisation, formats, options
 - Intégration et installation très simple dans les
 différents frameworks
 - Documentation
 - Outil de test en live
 - Gestion des expressions (js-phpize)
 - Gestion des assets et de la minification (pug-assets)
 - Traçace des erreurs
 - Profiling
 - Réactivité de la communauté (issues et pull-request sur GitHub,
 and [pug] [php] keywords on stackoverflow)