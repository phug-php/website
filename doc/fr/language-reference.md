# Language reference

## Attributs

Les attributs des balises s'écrivent comme en HTML (avec des
virgules optionnelles), mais leurs valeurs sont de simples
expressions.

```phug
a(href='google.com') Google
="\n"
a(class='button' href='google.com') Google
="\n"
a(class='button', href='google.com') Google
```

(`="\n"` sert uniquement à ajouter des sauts de ligne entre
les liens pour une meilleure lecture du rendu HTML).

Les expressions PHP fonctionnent par défaut dans **phug** et
**tale-pug** ; et dans **pug-php** avec l'option
`expressionLanguage` réglée sur `php`:
```phug
- $authentifié = true
body(class=$authentifié ? 'auth' : 'anon')
```

Les expressions JavaScript fonctionnent également avec **js-phpize-phug**
installé ([voir comment l'installer](#utiliser-des-expressions-javascript))
ou la dernière version de **pug-php** avec les options par défaut
(soit `expressionLanguage` réglée sur `js`) :
```pug
- var authentifié = true
body(class=authentifié ? 'auth' : 'anon')
```

### Attributs multi-lignes

Si vous avez beaucoup d'attributs, vous pouvez les séparer en plusieurs
lignes :
```phug
input(
  type='checkbox'
  name='souscription'
  checked
)
```

Les textes multi-lignes ne sont pas un problème que vous utilisez
les expressions JS ou PHP :
```pug
input(data-json='
  {
    "très-long": "du texte",
    "données": true
  }
')
```

Note : si vous migrez des templates depuis un projet JavaScript,
vous pourriez avoir à remplacer <code>&#96;</code> par des apostrophes
`'` ou des guillemets `"`.

### Noms d'attributs échappés

Si les noms de vos attributs contiennent des carachtères spéciaux
qui pourrait interférer avec la syntaxe des expressions, échappez-le
avec `""` ou `''`, ou utilisez des virgules pour séparer les
différents attributs. Les caractères concernés sont par exemple
`[]` et `()` (fréquemment utilisés avec Angular 2).

```phug
//- Ici, `[click]` est compris comme une position
//- d'array, il en résulte donc une erreur
div(class='div-class' [click]='play()')
```

```phug
div(class='div-class', [click]='play()')
div(class='div-class' '[click]'='play()')
```

### Interpolation d'attribut

Une simple note à propos d'une syntaxe que vous avez pu connaître
avec **pugjs 1**: `a(href="/#{url}") Lien`, cette syntaxe n'est plus
valide depuis **pugjs 2** et nous avons décidé de ne pas la supporter
non plus dans **Phug**. Vous pouvez utiliser une simple concaténation
à la place :
```phug
- $btnType = 'info'
- $btnTaille = 'lg'
button(type='button' class='btn btn-' . $btnType . ' btn-' . $btnTaille)
```
Pour les expressions JS, replacez `.` par `+` et vous pouvez omettre `$`.

### Attributs bruts

Par défaut, tous les attributs sont échappés pour éviter les attaques
(telles que les attaques XSS). Si vous avez besoin d'utiliser les
caractères spéciaux, utilisez `!=` au lieu `=`.
```phug
div(escaped="&lt;code>")
div(unescaped!="&lt;code>")
```

**Attention, le code non échappé peut être dangereux.** Vous devez être
sûr de toujours sécuriser les entrées du client pour éviter le
[cross-site scripting](https://fr.wikipedia.org/wiki/Cross-site_scripting).

### Attributs booléens

Les attributs booléens sont reflétés par **Phug**. Les valeurs booléennes
(`true` et `false`) sont acceptées. Quand aucune valeur n'est spécifiée,
`true` est assigné par défaut.
```phug
input(type='checkbox' checked)
="\n"
input(type='checkbox' checked=true)
="\n"
input(type='checkbox' checked=false)
="\n"
input(type='checkbox' checked='true')
```

Si le doctype est `html`, **Phug** sait qu'il ne doit pas refléter les
attributs, et il utilise le style concis (compris par tous les
navigateurs).
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

### Attributs de style

L'attribut `style` peut être une chaîne de caractères, comme n'importe
quel attribut ; mais également un objet ou un array.

Style PHP :
```phug
a(style=['color' => 'red', 'background' => 'green'])
="\n"
a(style=(object)['color' => 'red', 'background' => 'green'])
```

Style JS :
```pug
a(style={color: 'red', background: 'green'})
```

### Attributs de classe

L'attribut `class` peut être une chaîne de caractères, comme n'importe
quel attribut ; mais également un array.
```phug
- $classes = ['foo', 'bar', 'baz']
a(class=$classes)
="\n"
//- S'il y a plusieurs attributs de classe,
//- ils seront fusionnés
a.bang(class=$classes class=['bing'])
```

Vous pouvez aussi passer un array dont les clés sont les noms des
classes et les valeurs sont des conditions pour l'activer.

Style PHP :
```pug
- $urlCourrante = '/apropos'
a(ref='/' class=['actif' => $urlCourrante === '/']) Accueil
="\n"
a(href='/apropos' class=['actif' => $urlCourrante === '/apropos']) À propos
```

Style JS :
```pug
- var urlCourrante = '/apropos'
a(href='/' class={actif: urlCourrante === '/'}) Accueil
="\n"
a(href='/apropos' class={actif: urlCourrante === '/apropos'}) À propos
```

### Raccourci de classe

Les classes peuvent être définies avec la syntaxe `.classe`:
```phug
a.boutton
```

À défaut de balise spécifiée, la balise `div` sera utilisée :
```phug
.contenu
```

### Raccourci d'id

Les IDs  peuvent être définies avec la syntaxe `#identifiant` :
```phug
a#lien-principal
```

À défaut de balise spécifiée, la balise `div` sera utilisée :
```phug
#contenu
```

### &attributes

Prononcé “and attributes”, la syntaxe `&attributes` peut être
utilisée pour fragmenter un array en attribus d'un élément.

Style PHP :
```phug
div#foo(data-bar="foo")&attributes(['data-foo' => 'bar'])
```

Style JS :
```pug
div#foo(data-bar="foo")&attributes({'data-foo': 'bar'})
```

Les exemples ci-dessus utilisent des array litéraux. Mais vous
pouvez aussi utiliser des variables dans la valeur est un array.
(Voir aussi : [Mixin Attributes](#attributs-des-mixins)).
```phug
- $attributs = []
- $attributs['class'] = 'baz'
div#foo(data-bar="foo")&attributes($attributs)
```

**Attention, les attributs extraits de `&attributes` ne sont pas
automatiquement échappés.** Vous devez vous assurer que toute
entrée utilisateur qu'ils pourrait contenir soit sécurisée
pour éviter le
[cross-site scripting](https://fr.wikipedia.org/wiki/Cross-site_scripting)
(XSS). En passant `attributes` via un appel de mixin, l'échappement
est fait automatiquement.
