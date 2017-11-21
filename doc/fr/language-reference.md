# Référence du language

Comme **Phug** est aligné sur pugjs, ce chapitre est quasiment
le même que celui que vous pouvez trouver sur la documentation
de [pugjs](https://pugjs.org) à lexception des spécificités de
**Phug** et des éditeurs de code qui vous permettent de tester
le rendu du moteur **Phug**.

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
les liens pour une meilleure lecture du rfinu HTML).

Les expressions PHP fonctionnent par défaut dans **Phug** et
**Tale-pug** ; et dans **Pug-php** avec l'option
`expressionLanguage` réglée sur `php`:
```phug
- $authentifié = true
body(class=$authentifié ? 'auth' : 'anon')
```

Les expressions JavaScript fonctionnent également avec **js-phpize-phug**
installé ([voir comment l'installer](#utiliser-des-expressions-javascript))
ou la dernière version de **Pug-php** avec les options par défaut
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
non plus dans **Phug**. Vous pouvez utiliser l'interpolation PHP
à la place :
```phug
- $btnType = 'info'
- $btnTaille = 'lg'
button(type="button" class="btn btn-$btnType btn-$btnTaille")
- $btn = (object) ['taille' => 'lg']
button(type="button" class="btn btn-{$btn->taille}")
```
Pour les expressions JS, utilisez la concaténation `" + btnType + "`.

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

### Attributs non vérifiés

Ceci est un concept propre à **Phug** que vous ne trouverez pas dans
**pugjs**, il s'agit de la vérification des variables.

En PHP, quand les erreurs sont affichées et que le niveau d'erreur
inclus les notices, l'appel d'une variable non définie déclenche une
erreur.

Par défaut, nous cachons ces erreurs, mais cela peut parfois cacher
un bug, donc vous pouvez utiliser l'opérateur `?=` pour éviter
ce comportement :

```phug
- $mauvais = ''
img(src?=$mauvai)
```
Dans cet exemple, l'opérateur `?=` va révélé l'erreur orthographique
de "mauvais". Cliquez sur le bouton `[Preview]` pour voir l'erreur.

Les attributs peuvent être à la fois bruts et non vérifiés :

```phug
- $html = '&lt;strong>OK&lt;/strong>'
img(alt?!=$html)
```

Pour désactiver globalement la vérification (toujours afficher
une erreur si la variable appelée n'est pas définie) utilisez
l'option `php_token_handlers` :

```php
Phug::setOption(['php_token_handlers', T_VARIABLE], null);
```

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

[Style JS](#utiliser-des-expressions-javascript) :
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

[Style JS](#utiliser-des-expressions-javascript) :
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

[Style JS](#utiliser-des-expressions-javascript) :
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

## Case

Le mot-clé `case` est un raccourci de `switch` en PHP.
Il a la forme suivante :

```phug
- $amis = 10
case $amis
  when 0
    p vous n'avez aucun ami
  when 1
    p vous avez un ami
  default
    p vous avez #{$amis} amis
```

### Cas groupés

Vous pouvez utiliser les cas groupés juste comme vous le feriez avec
`switch` en PHP.

```phug
- $amis = 0
case $amis
  when 0
  when 1
    p vous avez very few amis
  default
    p vous avez #{$amis} amis
```

Cepfinent si, en PHP le groupage est automatique si le mot-clé `break`
n'est pas explicitement inclus ; avec **Phug**, il a lieu seulement
si le block est complètement vide.

Si vous souhaitez ne rien afficher du tout pour un cas spécifique,
appelez explicitement `break` :

```phug
- $amis = 0
case $amis
  when 0
    - break
  when 1
    p vous avez very few amis
  default
    p vous avez #{$amis} amis
```

### Expension de bloc

L'expension de block peut aussi être utilisée :

```phug
- $amis = 1
case $amis
  when 0: p vous n'avez aucun ami
  when 1: p vous avez un ami
  default: p vous avez #{$amis} amis
```

## Code

**Phug** permet d'écrire du code PHP ou JavaScript dans les
templates. Le résultat du code peut être affiché ou non.
Quand il est affiché, il peut être échappé ou non, vérifié
ou non de la même manière que les attributs.

### Code non affiché

Les codes non affichés commencent par `-`. De base, rien ne sera
affiché.

```phug
- for ($x = 0; $x &lt; 3; $x++)
  li article
```

**Phug** supporte aussi les blocs de code non affichés :

```phug
-
  $chiffres = ["Uno", "Dos", "Tres",
               "Cuatro", "Cinco", "Seis"]
each $chiffre in $chiffres
  li= $chiffre
```

### Code affiché

Les codes affichés comment par `=`. Ils évaluent l'expression PHP ou
JavaScript et affichent le résultat. Par mesure de sécurité, les entités
HTML sont échappées par défaut.

```phug
p
  = 'Ce code est &lt;échapé> !'
```

Le code peut aussi être écrit sur la même ligne et supporte
toutes sortes d'expressions.

```phug
p= 'Ce code est ' . '&lt;échapé> !'
```

Note: si vous utilisez les expressions JavaScript, la concaténations
 doivent utiliser l'opérateur `+` :

```pug
p= 'Ce code est ' + ' &lt;échapé> !'
```

### Code brut/échappé

Préfixez l'opérateur `=` avec `!` pour ne pas échapper les entitiés
HTML, avec `?` pour ne pas vérifier les variables et `?!` pour faire
les deux :

```phug
- $début = '&lt;strong>'
- $fin = '&lt;/strong>'
//- Ceci est échappé
div= $début . 'Word' . $fin
//- Ceci n'est pas échappé
div!= $début . 'Word' . $fin
//- Les deux sont vérifiés
div= 'début' . $milieu . 'fin'
div!= 'début' . $milieu . 'fin'
```

**Attention: le code non échappé peut être dangereux.** Vous devez vous
assurer que les entrées du client sont sécurisées pour éviter le
[cross-site scripting](https://fr.wikipedia.org/wiki/Cross-site_scripting)
(XSS).

### Code vérifié/non vérifié

Les codes vérifiés ne déclenchent pas d'erreur lorsque des variables
sont indéfinies.

Les codes non vérifiés déclenchent une erreur lorsque des variables
sont indéfinies. Ci-dessous les codes vérifiés avec une
variable dans le premier cas existante, dans le second
manquante :

```phug
- $milieu = ' milieu '
div?= 'début' . $milieu . 'fin'
div?!= 'début' . $milieu . 'fin'
```

```phug
div?= 'début' . $milieu . 'fin'
div?!= 'début' . $milieu . 'fin'
```

## Commentaires

Les commentaires affichés sur une seule ligne ressemblent à ceux de
nombreux langages (C, PHP, JavaScript) et produisent des commentaires
*HTML* dans la page rendue.

Comme les balises, ils doivent apparaître sur leur propre ligne.

```phug
// juste quelques paragraphes
p foo
p bar
// chaque ligne
// va produire
// un commentaire HTML
footer
```

**Phug** supporte aussi les commentaires masqués (ils ne seront pas
compilés, vous pouvez donc en mettre beaucoup sans craindre d'allourdir
vos fichiers de cache). Ajoutez simplement un tiret (`-`) au début
du commentaire.

```phug
//- rien ne s'affichera dans le HTML
p foo
p bar
```

### Blocs de Commentaire

Les blocs de commentaire fonctionne aussi :
```phug
body
  //-
    Commentaires pour les développeurs de templates.
    Utilisez autant de texte que vous voulez.
  //
    Commentaires pour les lecteurs de HTML.
    Utilisez autant de texte que vous voulez.
```

### Commentaires conditionnels

**Phug** n'a pas de syntaxe spécifique pour les commentaires
conditionnels. (Les commentaires conditionnels sont un méthode
spécifique à Internet Explorer pour ajouter des balises dédiées
à versions anciennes.)

Cependant, comme toutes les lignes commençant par `<` sont traitées
comme du [texte brut](#texte-brut), la syntaxe HTML normale des
commentaires conditionnels fonctionnera juste telle quelle.
```phug
doctype html

&lt;!--[if IE 8]>
&lt;html lang="fr" class="lt-ie9">
&lt;![endif]-->
&lt;!--[if gt IE 8]>&lt;!-->
&lt;html lang="fr">
&lt;!--&lt;![endif]-->

body
  p Supporter les anciennes versions des navigateurs, c'est pénible.

&lt;/html>
```

## Conditions

Les conditions ont la forme suivante si vous utilisez le style PHP :
```phug
- $utilisateur = [ 'description' => 'foo bar baz' ]
- $autorisé = false
#utilisateur
  if $utilisateur['description']
    h2.vert Description
    p.description= $utilisateur['description']
  else if $autorisé
    h2.bleu Description
    p.description.
      L'utilisateur n'a pas de description.
      Pourquoi ne pas en ajouter une ?
  else
    h2.rouge Description
    p.description L'utilisateur n'a pas de description.
```

Si vous [utilisez le style JS](#utiliser-des-expressions-javascript) :
```pug
- var utilisateur = { description: 'foo bar baz' }
- var authorised = false
#utilisateur
  if utilisateur.description
    h2.vert Description
    p.description= utilisateur.description
  else if authorised
    h2.bleu Description
    p.description.
      L'utilisateur n'a pas de description.
      Pourquoi ne pas en ajouter une ?
  else
    h2.rouge Description
    p.description L'utilisateur n'a pas de description.
```

**Phug** fournit aussi le mot-clé `unless`, qui fonctionne
comme un `if` négatif.

Exemple en style PHP :
```phug
unless $utilisateur['estAnonyme']
  p Vous êtes connecté en tant que #{$utilisateur['nom']}.
//- est équivalent à
if !$utilisateur['estAnonyme']
  p Vous êtes connecté en tant que #{$utilisateur['nom']}.
```
```vars
[
  'utilisateur' => [
    'estAnonyme' => false,
    'nom' => 'Jefferson Airplane',
  ],
]
```

Exemple en [style JS](#utiliser-des-expressions-javascript) :
```pug
unless utilisateur.estAnonyme
  p Vous êtes connecté en tant que #{utilisateur.nom}.
//- est équivalent à
if !utilisateur.estAnonyme
  p Vous êtes connecté en tant que #{utilisateur.nom}.
```
```vars
[
  'utilisateur' => [
    'estAnonyme' => false,
    'nom' => 'Jefferson Airplane',
  ],
]
```

## Doctype

```phug
doctype html
```

### Doctype raccourics

Raccourics vers les doctypes courants :

```phug
doctype html
doctype xml
doctype transitional
doctype strict
doctype frameset
doctype 1.1
doctype basic
doctype mobile
doctype plist
```

### Doctypes personnalisés

Vous pouvez aussi utiliser votre propre doctype :

```phug
doctype html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN"
```

### Option doctype

En plus d'ajouter le doctype HTML, le doctype influe sur la
manière dont **Phug** va formatter les balises auto-fermante
`/>` en XML, `>` en HTML 5. Il change aussi l'affichage des
[attributs booléens](#attributs-booleens).

Si, pour quelque raison que ce soit, il n'est pas possible
d'utiliser le mot-clé `doctype` (par exemple, afficher une
portion de HTML seule), mais que vous voulez appliquer les
spécificités du doctype, vous pouvez utiliser
l'[option doctype](#options-doctype).

```php
$source = 'img(src="foo.png")';

Phug::render($source);
// => '&lt;img src="foo.png"/>'

Phug::render($source, [], [
  'doctype' => 'xml',
]);
// => '&lt;img src="foo.png">&lt;/img>'

Phug::render($source, [], [
  'doctype' => 'html',
]);
// => '&lt;img src="foo.png">'
```

## Filtres

Les filtres vous permettent d'utiliser d'autres languages dans vos
templates Pug. Ils prennent un bloc de texte comme entrée.

Pour passer des options au filtre, ajouter les entre parenthèses
après le nom du filtre comme vous le fériez pour les 
[attributs de balises](#attributs)): `:less(compress=false)`.

Tous les [modules JSTransformer](https://www.npmjs.com/browse/keyword/jstransformer)
peuvent être utilisés comme des filtres. Par exemple
:babel, :uglify-js, :scss, ou :markdown-it. Consultez la documentation
du JSTransformer pour connaître les options supportées par ce
filtre spécifique.

Pour utiliser JSTransformer avec **Phug**, installez l'extension
suivante :

```shell
composer require phug/js-transformer-filter
```

Puis activez-la :

```php
use Phug\JsTransformerExtension;
use Phug\Phug;

Phug::addExtension(JsTransformerExtension::class);
```

Avec **Pug-php**, cette extension est déjà installée et activée
par défaut depuis la version 3.1.0.

Vous pouvez aussi utiliser les projets PHP suivants en tant que
filtres dans n'importe quel projet **Phug** ou **Pug-php** :
http://pug-filters.selfbuild.fr

Si vous ne trouvez pas de filtre approprié pour votre cas
d'utilisation, vous pouvez écrire vos propres filtres. Ce peut
être n'importe quel *callable* (closure,
fonction ou objet possédant une méthode __invoke).

```php
Phug::setFilter('maj-debut', function ($texte, $options) {
  return strtoupper(mb_substr($texte, 0, $options['longueur'])).
    mb_substr($texte, $options['longueur']);
});

Phug::display('
div
  :maj-debut(longueur=3)
    gggggg
');
```

Ce qui va afficher :
```html
&lt;div>GGGggg&lt;/div>
```

La même option est disponible dans **Pug-php** :

```php
$pug = new Pug();
$pug->setFilter('maj-debut', function ($texte, $options) {
  return strtoupper(mb_substr($texte, 0, $options['longueur'])).
    mb_substr($texte, $options['longueur']);
});

$pug->display('
div
  :maj-debut(longueur=3)
    gggggg
');
```

**Phug** inclut le filtre `cdata` :
```phug
data
  :cdata
    Puisque c'est une section CDATA
    Je peux utiliser toute sorte de caractères
    comme > &lt; " et &
    ou écrire des choses comme
    &lt;machin>&lt;/chose>
    mais mon document reste bien formé
```

**Pug-php** pré-installe `JsTransformerExtension` et embarque `cdata`,
`css`, `escaped`, `javascript`, `php`, `pre`, `script`
et si vous n'avez pas réglé l'option `filterAutoLoad` à `false`, toutes
les classes *invokable* du namespace `Pug\Filter` seront chargées comme
filtres automatiquement :

```pug
doctype html
html
  head
    :css
      a {
        color: red;
      }
  body
    :php
      $calcul = 9 + 8
    p=calcul
    :escaped
      &lt;truc>
    :pre
      div
        h1 Exemple de code Pug
    :javascript
      console.log('Salut')
    :script
      console.log('Alias pour javascript')
```

## Include

Le mot-clé `include` vous permet d'insérer le contenu d'un fichier Pug
dans un autre.

```phug
//- index.pug
doctype html
html
  include includes/head.pug
  body
    h1 Mon site web
    p Bienvenue sur mon super site
    include includes/foot.pug
```

```phug
//- includes/head.pug
head
  title Mon site web
  script(src='/javascripts/jquery.js')
  script(src='/javascripts/app.js')
```

```phug
//- includes/foot.pug
footer#footer
  p Tous droits réservés
    =date(' Y')
```

Si le chemin est absolu (c.f. `include /racine.pug`), it sera résolus
depuis les chemins choisis via l'[option paths](#paths). Cette option
fonctionne comme `basedir` dans
pugjs mais permet de spécifier plusieurs dossiers. L'option `basdir`
existe aussi dans **Pug-php** pour fournir une pleine compatibilité
avec les options de pugjs mais nous vous recommandons d'utiliser
`paths` de préférence.

Sinon, les chemins sont résolus relativement au fichier courrant en
court de compilation.

Si le fichier n'a pas d'extension, `.pug` sera ajouté automatiquement.

### Inclusion de texte brut

Tout autre fichier que les fichiers pug seront simplement inclus
comme du texte brut.

```phug
//- index.pug
doctype html
html
  head
    style
      include style.css
  body
    h1 Mon site web
    p Bienvenue sur mon super site
    script
      include script.js
```
```css
/* style.css */
h1 {
  color: red;
}
```
```js
// script.js
console.log('Vous êtes fantastique');
```

### Inclusion de texte filtré

Vous pouvez appliquer des filtres lors de l'inclusion, ce qui vous
permet de gérer d'autres formats de fichiers.

```phug
//- index.pug
doctype html
html
  head
    title Un article
  body
    include:markdown article.md
```
```markdown
# article.md

Ceci est un article écrit en markdown.
```

## Héritage de template

**Phug** supporte l'héritage de template via les mots-clés
`block` et `extends`.

Dans un template, un `block` est simplement un “bloc” de code Pug
qu'un template enfant peut remplacer. The processus est récursif.

Les blocs **Phug** peuvent fournir un contenu par défaut, si approprié.
Ce qui reste purement optionnel. L'exemple ci-dessous définit
`block scripts`, `block contenu`, et `block pied`.

```phug
//- disposition.pug
html
  head
    title Mon site web - #{$titre}
    block scripts
      script(src='/jquery.js')
  body
    block contenu
    block pied
      #pied-de-page
        p Contenu du pied de page
```
```vars
[
  'titre' => 'Journal',
]
```
*&#42;Pas besoin de `$` si vous
[utilisez des expressions JS](#utiliser-des-expressions-javascript)*

Pour étendre cette disposition, créez un nouveau fichier et utilisez
la directive `extends` avec un chemin vers le template parent.
(Si aucune extension de fichier n'est fournie, `.pug` sera ajouté
automatiquement au nom de fichier.) Puis définissez un ou plusieurs
blocs à remplacer.

Ci-dessous notez que le bloc `pied` *n'est pas* redéfini, donc il
va utiliser le contenu par défaut reçu du parent et afficher
“Contenu du pied de page”.

```phug
//- page-a.pug
extends disposition.pug

block scripts
  script(src='/jquery.js')
  script(src='/pets.js')

block contenu
  h1= $titre
  each $nom in $animaux
    include animal.pug
```
```vars
[
  'titre' => 'Blog',
  'animaux'  => ['chat', 'chien']
]
```
```phug
//- animal.pug
p= $nom
```
*&#42;Pas besoin de `$` si vous
[utilisez des expressions JS](#utiliser-des-expressions-javascript)*

Il est aussi possible de remplacer un bloc en fournissant des blocs
supplémentaires, comme montré dans l'exemple ci-dessous.
Ici, `contenu` expose désormais deux nouveaux blocs
`menu` et `principal` qui pourront à leur tour être remplacés.
(Alternativement, le template enfant pourrait aussi remplacer le
bloc `contenu` en entier.)

```phug
//- sous-disposition.pug
extends disposition.pug

block content
  .menu
    block menu
  .principal
    block principal
```
```phug
//- page-b.pug
extends sous-disposition.pug

block menu
  p Quelque chose

block principal
  p Autre chose
```

### Directives `append` / `prepend`

**Phug** permet de replacer un bloc avec `replace` (également par défaut),
insérer au début du bloc avec `prepend`, ou d'ajouter à la fin du bloc
avec `append`.

Par exemple si vous avez des scripts par défaut dans un bloc `head` et
que vous souhaitez les utiliser sur toutes les pages, vous pouvez faire
ceci :

```phug
//- page-disposition.pug
html
  head
    block head
      script(src='/vendor/jquery.js')
      script(src='/vendor/caustic.js')
  body
    block contenu
```

Maintenant, imaginons une page de votre jeu JavaScript. Vous voulez
certains scripts relatif au jeu en plus des scripts par défaut. Vous
pouvez simplement utiliser `append` :

```phug
//- page.pug
extends page-disposition.pug

block append head
  script(src='/vendor/three.js')
  script(src='/game.js')
```

Quand vous utilisez `block append` ou `block prepend`, le mot “`block`”
est optionnel :

```phug
//- page.pug
extends page-disposition.pug

append head
  script(src='/vendor/three.js')
  script(src='/game.js')
```

### Erreurs fréquentes

L'héritage dans **Phug** est une fonctionnalité puissante qui permet
de séparer des structures de pages complexes en fichiers plus petits
et plus simples. Cependant, si vous chaînez beaucoup, beaucoup de
templates ensemble, vous pouvez rendre les choses plus compliquées
pour vous-même.

Notez que **seuls les blocs nommés et les définitions de mixin**
peuvent apparaître au premier niveau (non indenté) d'un template enfant.
C'est important ! Les templates parents définissent une structure
globale de page et les templates enfants peuvent seulement `append`,
`prepend`, ou remplacer des blocs spécifiques de code ou de logique.
Si un template enfant essaye d'ajouter du contenu en dehors d'un
bloc, **Phug** n'aura aucun moyen de savoir où le mettre dans la page
finale.

Ceci inclut [les codes non affichés](#code-non-affiche), dont le placement
peut également avoir un impact et [les commentaires affichés](#commentaires)
puisqu'ils produisent du code HTML.

## Interpolation

**Phug** fournit différents opérateurs pour couvrir vos différents
besoin en interpolations.

### Interpolation de chaîne, échappée

Considérons le code suivant :

```phug
- $titre = "Les Misérables";
- $auteur = "Victor Hugo";
- $super = "&lt;span>echappé !&lt;/span>";

h1= $titre
p Écrit par #{$auteur}
p Ceci va être fiable : #{$super}
```

`titre` suit le schéma classique d'insertion de variable, mais
les codes entre `#{` et `}` est évalué, échappé, et le résultat
est inséré dans le texte.

Vous pouvez insérer n'importe quelle expression valide :

```phug
- $msg = "pas ma voix intérieure";
p Ce n'est #{strtoupper($msg)}
```

**Phug** est assez intelligent pour savoir où l'interpolation
finit, même si par exemple ell contient `}` :

```phug
p Pas besoin d'échappement pour #{'}'} !
```

Si vous avez besoin d'insérer `#{` en tant que texte brut,
vous pouvez également l'interpoler, ou bien le préfixer
d'un anti-slash.
```phug
p Échappement par anti-slash \#{interpolation}
p L'interpolation fonctionne aussi avec l'#{'#{interpolation}'} !
```

### Interpolation de chaîne, non échappée

```phug
- $affaireRisquée = "&lt;em>Il faut quand même faire attention.&lt;/em>";
.citation
  p Joël: !{$affaireRisquée}
```

**Attention ! Gardez à l'esprit que le code non échappé s'il vient
directement d'une entrée utilisateur, présente un risque.**
Ne faites jamais confiance aux entrées de l'utilisateur !

### Interpolation de balise

L'interpolation fonctionne aussi avec du code **Phug** en utilisant
la syntaxe suivante :

```phug
p.
  C'est un long et très ennuyeux paragraphe sur plusieurs lignes.
  Soudainement il y a #[strong quelques mots en gras] qui ne
  peuvent être #[em ignorés].
p.
  Et ici un exemple d'interpolation de balise avec un attribut:
  #[q(lang="es") ¡Hola Mundo!]
```

Encapsulez une déclaration de balise entre `#[` et `]`, et il
sera évalué et inséré dans le texte.

### Contrôle des espaces blancs

La syntaxe des interpolations de balises est particulièrement
utile pour les balises *inline*, lorsque les espaces blancs
avant et après sont important.

Par défaut, cependant, **Phug** supprime les espaces blancs
entre les balises. Voyez dans cet exemple :

```phug
p
  | Si vous écrivez ce paragraphe sans interpolations, les balises comme
  strong strong
  | et
  em em
  | pourrait produire des résultats inattendus.
p.
  Avec l'interpolation, les espaces blancs sont #[strong respectés] et #[em tout le monde] est content.
```

Consultez la section [Text brut](#texte-brut)
pour plus d'information et exemples à ce sujet.

## Itération

**Phug** supporte principalement 2 methodes d'itération :
`each` et `while`.

### each

`each` est le moyen le plus simple de parcourir des
arrays et des  objets dans un template :

Style PHP :
```phug
ul
  each $val in [1, 2, 3, 4, 5]
    li= $val
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
ul
  each val in [1, 2, 3, 4, 5]
    li= val
```

Vous pouvez aussi récupérer l'index lorsque vous itérez :

Style PHP :
```phug
ul
  each $val, $index in ['zéro', 'un', 'deux']
    li= $index . ' : ' . $val
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
ul
  each val, index in ['zéro', 'un', 'deux']
    li= index + ' : ' + val
```

**Phug** permet aussi d'iétérer les clés d'un objet :

Style PHP :
```phug
ul
  each $val, $index in (object) ['un' => 'UN', 'deux' => 'DEUX', 'trois' => 'TROIS']
    li= $index . ' : ' . $val
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
ul
  each val, index in {un: 'UN', deux: 'DEUX', trois: 'TROIS'}
    li= index + ' : ' + val
```

L'objet ou l'array que vous itérez peut être une variable,
le résultat d'une fonction, ou à peu près n'importe quoi d'autre.

Style PHP :
```phug
- $valeurs = []
ul
  each $val in count($valeurs) ? $valeurs : ["Il n'y a aucune valeur"]
    li= $val
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
- var valeurs = [];
ul
  each val in valeurs.length ? valeurs : ["Il n'y a aucune valeur"]
    li= val
```

Vous pouvez aussi ajouter un bloc `else` qui sera exécuté si l'array
ou l'objet ne contien aucun élément à itérer. Le code ci-dessous est
donc équivalent aux exemples ci-dessus :

Style PHP :
```phug
- $valeurs = []
ul
  each $val in $valeurs
    li= $val
  else
    li Il n'y a aucune valeur
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
- var valeurs = [];
ul
  each val in valeurs
    li= val
  else
    li Il n'y a aucune valeur
```

Vous pouvez aussi utiliser `for` comme un alias de `each`.

Une fonctionnalité spéciales de **Phug** (non disponible dans
pugjs) permet aussi d'utiliser `for` comme une boucle PHP :

```phug
ul
  for $n = 0; $n &lt; 4; $n++
    li= $n
```

### while

Vous pouvez aussi créer des boucles avec `while` :

```phug
- $n = 0
ul
  while $n &lt; 4
    li= $n++
```

## Mixins

Les *mixins* permettent de créer des blocs de code **Phug**
réutilisables.

```phug
//- Déclaration
mixin liste
  ul
    li truc
    li machin
    li chose
//- Utilisation
+liste
+liste
```

Les *mixins* sont compilés en fonctions et peuvent prendre
des arguments :
```phug
mixin animal($nom)
  li.animal= $nom
ul
  +animal('chat')
  +animal('chien')
  +animal('cochon')
```

Pas besoin de préfixer les paramètres/variables avec
`$` si vous
[utiliser le Style JS](#utiliser-des-expressions-javascript)

### Blocs de mixin

Les *mixins* peuvent aussi prendre un bloc de code **Phug**
qui lui tiendra lieu de contenu :

```phug
mixin article($titre)
  .article
    .article-zone
      h1= $titre
      if $block
        block
      else
        p Pas de contenu

+article('Salut tout le monde')

+article('Salut tout le monde')
  p Ceci est mon
  p Super article
```

Pas besoin de préfixer les paramètres/variables avec
`$` si vous
[utiliser le Style JS](#utiliser-des-expressions-javascript)

**Important**: Dans pugjs, la variable `block` est une
fonction représentant le bloc. Dans **Phug**, nous passons
seulement un booléen comme indicateur vous permettant de
savoir si l'appel au mixins contenant des éléments enfants.
Donc vous pouvez utiliser `$block` n'importe où à l'intérieur
de la déclaration du mixin (ou juste `block` si vous
[utiliser le Style JS](#utiliser-des-expressions-javascript))
et vous obtiendrez `true` si le bloc est rempli, `false`
s'il est vide.

### Attributs de mixin

Les *mixins* peuvent aussi recevoir un argument implicite
`attributes`, qui contient les attributs passé à l'appel
du mixin :

Style PHP :
```phug
mixin lien($href, $nom)
  //- attributes == {class: "btn"}
  a(class!=$attributes['class'], href=$href)= $nom

+lien('/foo', 'foo')(class="btn")
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
- var values = [];
mixin lien(href, nom)
  //- attributes == {class: "btn"}
  a(class!=attributes.class href=href)= nom

+lien('/foo', 'foo')(class="btn")
```

**Note: Les valeurs dans `attributes` sont déjà échappées par défaut.**
Vous devez donc utiliser `!=` pour éviter un double échappement.
(Voir aussi [attributs bruts](#attributs-bruts).)

Vous pouvez aussi appeler les mixins avec [`&attributes`](#attributes):

Style PHP :
```phug
mixin lien($href, $nom)
  a(href=$href)&attributes($attributes)= $nom

+lien('/foo', 'foo')(class="btn")
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
mixin lien(href, nom)
  a(href=href)&attributes(attributes)= nom

+lien('/foo', 'foo')(class="btn")
```

**Note:** La syntaxe `+lien(class="btn")` est aussi valide et équivalente
à `+lien()(class="btn")`, car **Phug** essaye de détecter si les contenus des
parenthèses sont des attributs ou des arguments. Néanmoins nous vous
encourageons à utiliser la seconde syntax, car vous passez explicitement
aucun argument et vous vous assurrez que la première parenthèse est
bien comprise comme la liste des arguments.

### Arguments restants

Vous pouvez écrire des mixins qui prennent un nombre inconnu d'arguments
en utilisant la syntax des arguments restants (“rest arguments”).


Style PHP :
```phug
mixin liste($id, ...$elements)
  ul(id=$id)
    each $element in $elements
      li= $element

+liste('ma-liste', 1, 2, 3, 4)
```

[Style JS](#utiliser-des-expressions-javascript) :
```pug
mixin liste(id, ...elements)
  ul(id=id)
    each element in items
      li= element

+liste('ma-liste', 1, 2, 3, 4)
```

## Texte brut

**Phug** fournit quatre manières d'obtenir du *texte brut* —
c'est-à-dire n'importe quel code ou contenu textuel qui va,
généralement sans traitement, directement dans le rendu HTML.
Ils sont utiles dans différentes situations.

Le texte brut permet toujours
l'[interpolation](#interpolation) de texte et de balises,
mais comme le texte brut n'est pas échappé, vous pouvez
aussi écrire du HTML litéral.

La gestion des espaces blancs dans le rendu HTML peut
présenter des écueils, nous vous présenterons comment
les éviter à la fin de ce chapitre.

### En ligne dans une balise

La méthode la plus simple est d'ajouter le texte à la suite
de la balise. Le premier mot de la ligne est la balise
elle-même. Tout ce qui arrive après cette balise suivie d'un
espace sera du contenu textuel de cette balise. C'est surtout
pratique lorsque le texte est court (ou si ça ne vous gêne
pas d'avoir des lignes trop longues).

```phug
p Ceci est un bon vieux contenu de &lt;em>texte&lt;/em> brut.
```

### HTML litéral

Toutes les lignes qui commencent par un chevron ouvrant (`<`)
sont également traitées comme du texte brut, ce qui peut être
utile occasionellement pour écrire des balises HTML telles
quelles. Par exemple, un cas d'utilisation est le
[commentaire conditionnel](#commentaires-conditionnels).
Puisque les balises HTML litérales ne sont pas traitées,
elle ne sont pas auto-fermantes, à l'inverse des balises
**Phug**.

```phug
&lt;html>

body
  p L'ouverture et fermeture de la balise html
  p sont chacun considérés comme une ligne de HTML litéral.

&lt;/html>
```

**Attention:** Avec **pugjs**, indenter le contenu (body dans
cet exemple) n'a pas d'incidence. Avec **pugjs**, seules les
lignes commençant par `&lt;` sont du HTML litéral peut importe
l'indentation.

Mais avec **Phug** (et donc **pug-php** aussi), nous considérons
le contenu indenté après une ligne commençant par `&lt;` comme
étant aussi du HTML litéral et non traité, donc si vous indentez
`body` dans cet exemple, il deviendra du contenu textuel (non
traité) de la balise `<html>`.  

Cette fonctionnalité permet de copier-coller du code HTML
indenté tel quel depuis n'importe où dans vos templates :

```phug
.machin
  #chose
    <p>
      Texte non traité #{'sauf pour les interpolations'}
    </p>
    <p>
      Titre
      <a href="/lien">
        Boutton
      </a>
    </p>
    p Ceci est du code #[strong Phug] à nouveau
```

### Trait vertical

Une autre façon d'ajouter du texte brut dans les templates
est de préfixer une ligne avec un trait vertical (`|`) aussi
appelé *pipe*. Cette méthode est utile pour mélanger du
texte brut avec des balise inline, nous en reparlerons
juste après dans la section **Whitespace Control**.

```phug
p
  | Le trait vertical va toujours au début de la ligne,
  | l'indentation ne compte pas.
```

### Bloc dans une balise

Souvent vous pouvez avoir besoin de grand blocs de texte
à l'intérieur d'une balise. Un bon exemple est d'écrire
du code JavaScript et CSS dans les balises `script` et
`style`. Pour faire ça, ajouter simplement un point `.`
juste après le nom de la balise, ou après la parenthèse
fermante si la balise a des [attributs](#attributs).

Il ne doit pas y avoir d'espace entre la balise et le
point. Le contenu de la balise doit être indenté d'un
niveau :

```phug
script.
  if (utilisePhug)
    console.log('vous êtes génial')
  else
    console.log('utilisez Phug')
```

Vous pouvez aussi créer un bloc de texte brut en utilisant
le point *après* d'autres balises à l'intérieur d'une
balise parente.

```phug
div
  p Ce texte appartien à la balise p.
  br
  .
    Ce texte appartien à la balise div.
```

### Whitespace Control

Managing the whitespace of the rendered HTML is one of the
trickiest parts about learning Pug. Don't worry, though,
you'll get the hang of it soon enough.

You just need to remember two main points about how whitespace
works. When compiling to HTML:

 1. **Phug** removes *indentation*, and all whitespace
 *between* elements.
    - So, the closing tag of an HTML element will touch
    the opening tag of the next. This is generally not a
    problem for block-level elements like paragraphs,
    because they will still render as separate paragraphs
    in the web browser (unless you have changed their CSS
    `display` property). See the methods described below,
    however, for when you do need to insert space between
    elements.
 2. **Phug** *preserves* whitespace *within* elements,
 including:
    - all whitespace in the middle of a line of text,
    - leading whitespace beyond the block indentation,
    - trailing whitespace,
    - line breaks within a plain text block, or between
    consecutive piped lines.

So… **Phug** drops the whitespace between tags, but keeps
the whitespace inside them. The value here is that it gives
you full control over whether tags and/or plain text should
touch. It even lets you place tags in the middle of words.

```phug
| You put the em
em pha
| sis on the wrong syl
em la
| ble.
```

The trade-off is that it *requires* you to think about and
take control over whether tags and text touch.

If you need the text and/or tags to touch — perhaps you
need a period to appear outside the hyperlink at the end
of a sentence — this is easy, as it’s basically what
happens unless you tell **Phug** otherwise.

```phug
a ...sentence ending with a link
| .
```

If you need to *add* space, you have a few options:

### Recommended Solutions

You could add one or more empty piped lines — a pipe
with either spaces or nothing after it. This will
insert whitespace in the rendered HTML.

```phug
| Don't
|
button#self-destruct touch
|
| me!
```

If your inline tags don’t require many attributes,
you may find it easiest to use tag interpolation,
or literal HTML, within a plain text *block*.

```phug
p.
  Using regular tags can help keep your lines short,
  but interpolated tags may be easier to #[em visualize]
  whether the tags and text are whitespace-separated.
```

### Not recommended

Depending on where you need the whitespace, you
could add an extra space at the beginning of the
text (after the block indentation, pipe character,
and/or tag). Or you could add a trailing space
at the *end* of the text.

**NOTE the trailing and leading spaces here:**

```phug
| Hey, check out 
a(href="http://example.biz/kitteh.png") this picture
|  of my cat!
```

The above solution works perfectly well, but is
admittedly perhaps a little dangerous: many code
editors by default will *remove* trailing whitespace
on save. You and all your contributors may have
to configure your editors to prevent automatic
trailing whitespace removal.

## Tags (balises)

By default, text at the start of a line (or after
only white space) represents an HTML tag. Indented
tags are nested, creating the tree structure of
HTML.

```pug
ul
  li Item A
  li Item B
  li Item C
```

**Phug** also knows which elements are self-closing:

```pug
img
```

### Block Expansion

To save space, **Phug** provides an inline syntax
for nested tags.

```pug
a: img
```

### Self-Closing Tags

Tags such as img, meta, and link are automatically
self-closing (unless you use the XML doctype).

You can also explicitly self close a tag by appending
the / character. Only do this if you know what
you're doing.

```phug
foo/
foo(bar='baz')/
```

### Rendered Whitespace

Whitespace is removed from the beginning and end
of tags, so that you have control over whether
the rendered HTML elements touch or not. Whitespace
control is generally handled via
[plain text](#plain-text).
