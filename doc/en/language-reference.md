# Language reference

## Attributes

Tag attributes look similar to HTML (with optional commas),
but their values are just regular expressions (PHP if you use
Phug, tale-pug or pug-php with `expressionLanguage` set to `php`,
JavaScript if you use last pug-php version with default options
or if you enable **js-phpize**).

```phug
a(href='google.com') Google
="\n"
a(class='button' href='google.com') Google
="\n"
a(class='button', href='google.com') Google
```

(`="\n"` are just here to add whitespace between links in the
output HTML).