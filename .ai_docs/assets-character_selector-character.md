# `CharacterSelector`
Este script, adjunto a un nodo `CharacterBody3D`, gestiona la lógica para la selección de una "skin" de personaje al ser interactuado mediante un clic. Define una señal `skin_selected` que se emite con un identificador único cuando el personaje es clicado.

El `character_id` es una variable `@onready` cuyo valor se inicializa automáticamente al cargar la escena. Se obtiene del nombre del nodo al que está adjunto el script, esperando que los nodos de personaje sigan una convención de nombrado como "CharacterN" (donde N es el índice numérico que lo identifica). Esta señal puede ser capturada por otros componentes del juego (como un manager de UI o un controlador de selección) para actualizar la apariencia o el estado del jugador, fusionando así la interacción del usuario con la lógica de selección de elementos del juego.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez cuando el nodo y todos sus hijos están listos. Su propósito es establecer la conexión entre el evento de entrada (`input_event`) del propio nodo y el método `_on_input_event`. Esto asegura que cada vez que se produce un evento de entrada sobre el `CharacterBody3D`, el método `_on_input_event` sea llamado para procesarlo.

```gdscript
func _ready():
	self.input_event.connect(_on_input_event)
```

## Funciones asociadas a señales

#### `_on_input_event(_c, event: InputEvent, _p, _n, _s)`
Esta función es la encargada de procesar los eventos de entrada (`InputEvent`) que ocurren sobre el nodo `CharacterBody3D`. Está conectada a la señal `input_event` del nodo, lo que significa que se activa cada vez que el usuario interactúa con el personaje.

El método filtra los eventos, buscando específicamente la acción "left_click" cuando esta es presionada. Si se detecta un "left_click" presionado, la función emite la señal `skin_selected`, pasando como argumento el `character_id` del personaje actual. Esto comunica a cualquier otro script o nodo que esté escuchando esta señal que este personaje ha sido seleccionado, permitiendo la actualización de la "skin" o la lógica de juego correspondiente. Los parámetros `_c`, `_p`, `_n`, `_s` se ignoran en esta implementación.

```gdscript
func _on_input_event(_c, event: InputEvent, _p, _n, _s):
	if event.is_action_pressed("left_click"):
		skin_selected.emit(character_id)
```