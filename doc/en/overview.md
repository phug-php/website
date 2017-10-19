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

### Why a template engine?

### Why not to use pugjs?

### Why upgrade/migrate to Phug?
