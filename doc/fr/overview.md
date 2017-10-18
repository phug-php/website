# Vue d'ensemble

**Phug** est le moteur de templates de [pug](https://pugjs.org/) pour PHP.

Phug offre un moyen simple d'écrire des templates (telles que des pages
HTML).

Exemple:

```phug
body
  h1 Phug
```

Au lieu d'écrire de verbeuses balises, Phug est structuré par indentation
(comme le Python, CoffeeScript ou Stylus).
Ici `<h1>` est à l'intérieur de `<body>` car `h1` a un niveau
d'indentation de plus. Essayez de supprimer les espaces, vous verez
que `<h1>` devient `<body>`
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

Phug is an agnostic pug template engine written in PHP, so by default, expressions
are written in PHP, but you can plug modules such as
[js-phpize](https://github.com/pug-php/js-phpize-phug) or wrapper like
[pug-php](https://github.com/pug-php/pug) that enable this module by default to get
js expressions working in your templates. See the example below:

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

Now you know what Phug is you can learn:
 - [to install it in the next chapter](#installation)
 - [check the original JS project](https://pugjs.org)
 - [see all the language features](#language-reference)
 