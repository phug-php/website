# Overview

## What is Phug?

**Phug** is the [pug](https://pugjs.org/) template engine for PHP.

Phug offers you a clean way to write your templates (such as HTML pages).

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

HTML is born in 1989 in the CERN, and was sufficient for its purpose:
write pages with titles and links. Nowadays, we build user interfaces for
various devices and the final HTML to send to the browser can be very
verbose. And even if we must send HTML to the browser, we can use an
other cleaner language and compile it.
 
A lot of template engines just allow to insert dynamic elements inside
HTML, with an engine like Phug, you will no longer write HTML at all
and will benefit many features: layouts, mixins, conditions, iterations,
etc.

Note that Phug supports several versions and doctypes of HTML but
also XML, and you can easily create any format you would need; as
you can customize expressions handling, etc. Phug has much options
and extension possibilities, *very* much.

### Why a template engine?

Most PHP frameworks have a templates system. It's an efficient way to
separate the view layer. Delegate view responsibility to template
engine is a best practice since it avoids mixing logic (calculation,
retrieving and parsing data) with presentation (display, formatting)
and it will help you to respect the PSR (principal of single
responsibility, that aims to not giving an entity multiple
responsibilities), so you will be able to organize your views into
pages and visual components with no constraint from your PHP code.

Finally, if you respect this principle (by avoiding, among
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

You may use already a PHP library supporting Pug syntax.

First of all, if you do not use composer, I only can encourage
you to switch to this dependencies management system. It's
the most used in the PHP ecosystem and it will help you keeping
your dependencies up to date. So I invite you to to pick a library
among available ones in composer (see https://packagist.org/),
prefer most starred ones with regular and recent releases. 

Then know that if you use a project containing "jade" in its
name, it's probably obsolete as jade is the old name of pug,
for example packages **kylekatarnls/jade-php**,
**ronan-gloo/jadephp**, **opendena/jade.php**,
**jumplink/jade.php**, **dz0ny/jade.php** and
**everzet/jade** are all no longer maintained projects that fork
the same origin, they are not pugjs 2 compliant and miss a lot
of pug features. The most up-to-date project that replace them
all is **pug-php/pug**. In its version 2 it still use the same
original engine.
Same goes for **talesoft/tale-jade** replaced with
**talesoft/tale-pug** and its version 2 will also use Phug.

**talesoft/tale-pug** and **pug-php/pug** are the most used
Pug ports and are actively maintained. By using the last version
of these projects, you will therefore automatically migrate to
the Phug engine and as contributors of these both projects
are now gather in the Phug project and will develop Phug in
priority, you will benefit from the best possible support.

To upgrade **pug-php/pug** and benefit all the features
described in this documentation, run the following command
in your project:

```shell
composer require pug-php/pug:"^3.0"
```

To be informed about **talesoft/tale-pug** version 2 release,
you can use https://www.versioneye.com/ and add
**talesoft/tale-pug** to your watchlist.

At least, we can assure you Phug surpass others existing
implementations on many subjects:
 - Extensibility, customization, formats, options
 - Integration and easy install in different frameworks
 - Documentation
 - Live test tool
 - Expression handling (js-phpize or any custom language)
 - Assets handling and minification (pug-assets)
 - Error tracking
 - Profiling
 - Community reactivity (issues and pull-request on GitHub,
 and [pug] [php] keywords on https://stackoverflow.com/search?q=pug+php)
