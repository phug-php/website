# Options

## Équivalents pour les options pugjs

### filename `string`

Le nom du fichier en cours de compilation. Cette option est utilisée pour
la résolution des chemins et le fichier mentionné en détail des erreurs :

```php
Phug::compile("\n  indentation\ncassée");
```

Par défaut, quand vous faites `compile`, `render` ou `display` (en passant
donc du code en argument),
**Phug** ne donne aucune information sur le nom du fichier dans les
exceptions et ne peut pas résoudre les chemins relatifs pour include/extend.

```yaml
Failed to parse: Failed to outdent: No parent to outdent to. Seems the parser moved out too many levels.
Near: indent

Line: 3
Offset: 1 
```

Avec l'option **filename**, un chemin est fournit :

```php
Phug::setOption('filename', 'machin-chose.pug');
Phug::compile("\n  indentation\ncassée");
```
```yaml
...
Line: 3
Offset: 1
Path: machin-chose.pug
```

Mais, cette option est ignorée si vous spécifiez localement
le *filename* :

```php
Phug::setOption('filename', 'machin-chose.pug');
Phug::compile("\n  indentation\ncassée", 'quelque-chose.pug');
```
```yaml
...
Line: 3
Offset: 1
Path: quelque-chose.pug 
```

Il en va de même pour `compileFile`, `renderFile` et `displayFile`:

```php
Phug::displayFile('quelque-chose.pug');
```
```yaml
...
Line: 3
Offset: 1
Path: quelque-chose.pug 
```

### basedir `string`

Le dossier racine pour les imports par chemin absolu. Cette option
est supportée pour raison de compatibilité avec pugjs, mais nous
vous recommandons d'utiliser l'option [paths](#paths) à la place.
Elle a le même objectif mais vous permet de passer un array de
dossiers qui vont tous être essayés (dans l'ordre dans lesquels
vous les passez) pour résoudre les chemins absolus lors des
`include`/`extend` et le premier trouvé est utilisé.

### doctype `string`

Si le `doctype` n'est pas spécifié dans le template, vous pouvez
le spécifier via cette option. C'est parfois utile pour avoir
les balises auto-fermantes et supprimer les valeurs en miroir
des attributs booléens. Voir
[la documentation de doctype](#doctype-option)
pour plus d'informations.

### pretty `boolean | string`

[Déprécié.] Ajoute des espaces blancs  dans le HTML pour le
rendre plus facile à lire pour un humain en utilisant `'  '`
comme indentation. Si une chapine de caractères est passée
à cette option, elle sera utilisée à la place comme indentation
(par exemple `'\t'`). Nous vous mettons en garde contre cette
option. Trop souvent, elle crée de subtiles problèmes dans
les rendus à cause de la manière dont elle altère le
rendu, et donc cette fonctionnalité sera prochainement
supprimée. Elle est réglée par défaut sur `false`.


