# `NodeBaseScript`
Este script, denominado `NodeBaseScript` para propósitos de documentación, es una extensión mínima de la clase `Node` de Godot. Actualmente, su única función definida es heredar todas las propiedades y funcionalidades base que ofrece el tipo `Node` en el motor Godot.

Como una clase `Node`, este script puede ser instanciado en el árbol de escenas, tener un nombre, ser padre de otros nodos y tener un nodo padre. Sin embargo, no implementa ninguna lógica personalizada, variables, métodos específicos del motor (como `_ready`, `_process`, etc.) o funciones asociadas a señales.

En el contexto de `Beast Card Clash`, un script tan fundamental como este podría servir como:
*   **Un punto de partida o plantilla:** Una base sobre la cual se construirán scripts más complejos para personajes, habilidades o elementos del juego, añadiendo lógica y comportamiento específicos.
*   **Un nodo contenedor genérico:** Para agrupar otros nodos en el árbol de escenas sin añadirles funcionalidad propia más allá de la estructura.
*   **Un marcador de posición:** Un script temporal para un componente cuya lógica aún no ha sido definida o implementada.

```gdscript
extends Node
```
La línea `extends Node` es la declaración clave que establece esta herencia, convirtiendo este script en un tipo `Node` que puede ser utilizado en cualquier parte del árbol de escenas de Godot. Su simplicidad lo hace altamente flexible, permitiendo a los desarrolladores comenzar a implementar la lógica del juego sin la sobrecarga de código preexistente o complejos.

# Métodos
No hay métodos ni funciones definidos en este script actualmente.