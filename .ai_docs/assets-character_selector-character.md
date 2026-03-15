# `CharacterSelector`
Este script, que extiende `CharacterBody3D`, está diseñado para ser adjunto a nodos 3D que representan personajes seleccionables o "skins" dentro del juego. Su propósito principal es detectar la interacción del usuario (específicamente clics) sobre el objeto 3D al que está adjunto. Al detectar un clic izquierdo, el script emite una señal (`skin_selected`) que lleva consigo un identificador único (`character_id`). Este identificador se deriva automáticamente del nombre del nodo, lo que permite que el sistema de selección de personajes del juego determine qué personaje o skin ha sido elegido por el jugador. La implementación sugiere un enfoque directo para la interactividad de elementos 3D en pantallas de selección o personalización, fusionando la representación visual de los animales de la biodiversidad colombiana con la lógica de juego.

# Métodos

## Métodos de Godot

### `_ready()`
Este método es parte del ciclo de vida de los nodos en Godot y se ejecuta una vez, justo después de que el nodo y todos sus hijos han entrado en el árbol de la escena. Su función aquí es establecer una conexión. Específicamente, conecta la señal `input_event` del propio nodo (`self.input_event`) con el método `_on_input_event`. Esto es crucial porque permite que el `CharacterBody3D` (el nodo al que está adjunto este script) reaccione a eventos de entrada como clics de ratón que ocurran directamente sobre él.

```gdscript
func _ready():
	self.input_event.connect(_on_input_event)
```

## Funciones asociadas a señales

#### `_on_input_event(_c, event: InputEvent, _p, _n, _s)`
Este método es la función de *callback* que se ejecuta cada vez que el nodo `CharacterBody3D` recibe un `input_event`. Su propósito es filtrar los distintos tipos de eventos de entrada y actuar solo cuando se detecta una acción específica: un clic izquierdo del ratón (`"left_click"`).

```gdscript
func _on_input_event(_c, event: InputEvent, _p, _n, _s):
	if event.is_action_pressed("left_click"):
		skin_selected.emit(character_id)
```

Cuando un clic izquierdo es detectado, el método emite la señal `skin_selected`, pasando como argumento el valor de la variable `character_id`. Los parámetros `_c`, `_p`, `_n`, `_s` son argumentos de la señal `input_event` que no son utilizados en este método específico, por lo que se les antepone un guion bajo para indicar su intencional omisión. La interacción de este método con el resto del proyecto se basa en que otros scripts (como un gestor de UI o un controlador de juego) estén conectados a la señal `skin_selected` para reaccionar a la elección del jugador.

### Variables

#### `character_id: int`
Esta variable `@onready` se inicializa cuando el nodo está listo en el árbol de la escena. Su valor es un entero que se obtiene procesando el nombre del nodo (`self.name`). Específicamente, elimina el prefijo `"Character"` del nombre del nodo y convierte el resto a un entero.

```gdscript
@onready var character_id: int = self.name.trim_prefix("Character") as int
```

**Funcionamiento:** Esta implementación asume que los nodos que utilizan este script siguen un esquema de nombres como `Character1`, `Character2`, `Character3`, etc. Por ejemplo, si el nodo se llama `Character5`, `character_id` tomará el valor `5`. Este ID es crucial para identificar de manera única al personaje o skin seleccionado cuando se emite la señal `skin_selected`.

### Señales

#### `skin_selected(index: int)`
Esta señal se declara al inicio del script y es fundamental para la comunicación con otros componentes del juego. Se emite cuando el nodo `CharacterBody3D` es clicado por el jugador (específicamente con un clic izquierdo).

```gdscript
signal skin_selected(index: int)
```

**Funcionamiento:** La señal lleva consigo un único argumento, `index`, que corresponde al `character_id` del personaje clicado. Otros scripts pueden conectarse a esta señal para recibir el `index` y realizar acciones apropiadas, como actualizar la skin del jugador en el menú, seleccionar un personaje para una partida o añadirlo a un mazo, alineándose con la naturaleza de juego de cartas coleccionables de "Beast Card Clash".