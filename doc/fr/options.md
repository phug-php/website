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
