# Language reference

## Attributes

Tag attributes look similar to HTML (with optional commas),
but their values are just regular expressions.

```phug
a(href='google.com') Google
="\n"
a(class='button' href='google.com') Google
="\n"
a(class='button', href='google.com') Google
```

(`="\n"` are just here to add whitespace between links in the
output HTML).

Normal PHP expressions work fine by default on **phug** and
**tale-pug**; and on **pug-php** with `expressionLanguage`
option set to `php`:
```phug
- $authenticated = true
body(class=$authenticated ? 'authed' : 'anon')
```

Normal JavaScript expressions work fine too with **js-phpize-phug**
extension installed ([see how to install](#use-javascript-expressions))
or **pug-php** last version with default options (or `expressionLanguage`
set to `js`):
```pug
- var authenticated = true
body(class=authenticated ? 'authed' : 'anon')
```

### Multiline Attributes

If you have many attributes, you can also spread them across many
lines:
```phug
input(
  type='checkbox'
  name='agreement'
  checked
)
```

Multiline texts are not at all a problem either you use JS or PHP
expressions:
```pug
input(data-json='
  {
    "very-long": "piece of ",
    "data": true
  }
')
```

Note: if you migrate templates from a JavaScript project you might
have to replace <code>&#96;</code> by simple quotes `'` or double
quotes `"`.

### Quoted Attributes

If your attribute name contains odd characters that might interfere
with JavaScript syntax, either quote it using `""` or `''`, or use
commas to separate different attributes. Examples of such characters
include `[]` and `()` (frequently used in Angular 2).

```phug
//- In this case, `[click]` is treated
//- as an offset getter, resulting
//- in the unusual error.
div(class='div-class' [click]='play()')
```

```phug
div(class='div-class', [click]='play()')
div(class='div-class' '[click]'='play()')
```

### Attribute Interpolation

A small note about a syntax you may hav known in **pugjs 1**:
`a(href="/#{url}") Link`, this syntax is no longer valid in **pugjs 2**
and so we decided to not support it in **Phug**. So you can simply
use concatenation:
```phug
- $btnType = 'info'
- $btnSize = 'lg'
button(type='button' class='btn btn-' . $btnType . ' btn-' . $btnSize)
```
For JS expressions, just replace `.` with `+` and you can omit `$`.

### Unescaped Attributes

By default, all attributes are escaped to prevent attacks (such as
cross site scripting). If you need to use special characters,
use `!=` instead of `=`.
```phug
div(escaped="&lt;code>")
div(unescaped!="&lt;code>")
```

**Caution, unescaped buffered code can be dangerous.** You must be
sure to sanitize any user inputs to avoid
[cross-site scripting](https://en.wikipedia.org/wiki/Cross-site_scripting).

### Boolean Attributes

Boolean attributes are mirrored by Pug. Boolean values (`true` and
`false`) are accepted. When no value is specified `true` is assumed.
```phug
input(type='checkbox' checked)
="\n"
input(type='checkbox' checked=true)
="\n"
input(type='checkbox' checked=false)
="\n"
input(type='checkbox' checked='true')
```

If the doctype is `html`, Phug knows not to mirror the attribute,
and instead uses the terse style (understood by all browsers).
```phug
doctype html
="\n"
input(type='checkbox' checked)
="\n"
input(type='checkbox' checked=true)
="\n"
input(type='checkbox' checked=false)
="\n"
input(type='checkbox' checked='checked')
```

### Style Attributes

The `style` attribute can be a string, like any normal attribute; but
it can also be an object or an array, which is handy when styles are
generated.

PHP-style:
```phug
a(style=array('color' => 'red', 'background' => 'green'))
```

JS-style:
```pug
a(style={color: 'red', background: 'green'})
```

### Class Attributes

The `class` attribute can be a string, like any normal attribute;
but it can also be an array of class names, which is handy when
generated.
```phug
- $classes = ['foo', 'bar', 'baz']
a(class=$classes)
="\n"
//- the class attribute may also be repeated to merge arrays
a.bang(class=$classes class=['bing'])
```

It can also be an object or array which maps class names
to `true` or `false` values. This is useful for applying
conditional classes.

PHP-style:
```pug
- $currentUrl = '/about'
a(ref='/' class=array('active' => $currentUrl === '/')) Home
="\n"
a(href='/about' class=array('active' => $currentUrl === '/about')) About
```

JS-style:
```pug
- var currentUrl = '/about'
a(href='/' class={active: currentUrl === '/'}) Home
="\n"
a(href='/about' class={active: currentUrl === '/about'}) About
```

### Class Literal

Classes may be defined using a `.classname` syntax:
```phug
a.button
```

Since `div`'s are such a common choice of tag, it is the
default if you omit the tag name:
```phug
.content
```

### ID Literal

IDs may be defined using a `#idname` syntax:
```phug
a#main-link
```

Since `div`'s are such a common choice of tag,
it is the default if you omit the tag name:
```phug
#content
```

### &attributes

Pronounced as “and attributes”, the `&attributes` syntax can
be used to explode an array into attributes of an element.

PHP-style:
```phug
div#foo(data-bar="foo")&attributes(['data-foo' => 'bar'])
```

JS-style:
```pug
div#foo(data-bar="foo")&attributes({'data-foo': 'bar'})
```

The above example uses an array literal. But you can also use
a variable whose value is an object, too. (See also:
[Mixin Attributes](#mixin-attributes)).
```phug
- $attributes = []
- $attributes['class'] = 'baz'
div#foo(data-bar="foo")&attributes($attributes)
```

**Caution, attributes applied using `&attributes` are not
automatically escaped.** You must be sure to sanitize any user
inputs to avoid
[cross-site scripting](https://en.wikipedia.org/wiki/Cross-site_scripting)
(XSS). If passing in `attributes` from a mixin call, this is
done automatically.
