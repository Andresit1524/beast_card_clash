# `SelectableCharacter`
Este script está diseñado para ser adjuntado a nodos de tipo `CharacterBody3D` con el fin de convertirlos en elementos interactivos y seleccionables dentro del juego. Su función principal es permitir al jugador hacer clic en un personaje (representado por el `CharacterBody3D`) para indicar una selección de "skin" o apariencia. La lógica del script se basa en la convención de nombres de los nodos para identificar de forma única cada personaje seleccionable y comunicar esta selección a otros componentes del juego a través de una señal.

## Métodos

### Métodos de Godot

### `_ready()`
Este método se llama automáticamente cuando el nodo, al que está adjunto este script, entra en el árbol de la escena. Su propósito es configurar la interacción inicial del personaje.

```gdscript
func _ready():
	self.input_event.connect(_on_input_event)
```

Dentro de `_ready()`, se establece una conexión entre la señal `input_event` del propio nodo `CharacterBody3D` y el método `_on_input_event` de este script. La señal `input_event` es emitida por nodos 3D cuando se detecta un evento de entrada (como un clic del ratón) que intersecta con su área de colisión. Al conectar esta señal, el script se asegura de que cualquier clic en el personaje sea detectado y procesado por la lógica de selección definida en `_on_input_event`.

### Funciones asociadas a señales

#### `_on_input_event(_c, event: InputEvent, _p, _n, _s)`
Este método es una función de *callback* que se ejecuta cada vez que la señal `input_event` es emitida por el `CharacterBody3D` al que está adjunto el script. Se encarga de detectar si el evento de entrada corresponde a un clic izquierdo y, en caso afirmativo, emitir la señal de selección de skin.

```gdscript
func _on_input_event(_c, event: InputEvent, _p, _n, _s):
	if event.is_action_pressed("left_click"):
		skin_selected.emit(character_id)
```

La señal `input_event` proporciona varios parámetros (`_c`, `event`, `_p`, `_n`, `_s`), aunque en este script solo se utiliza el parámetro `event: InputEvent` para determinar el tipo de interacción.

1.  **Detección de clic izquierdo**: El método primero verifica si el evento de entrada es una acción de "left_click" que ha sido presionada (`event.is_action_pressed("left_click")`). La acción "left_click" se define típicamente en la configuración de *Input Map* del proyecto Godot.
2.  **Emisión de señal `skin_selected`**: Si se detecta un clic izquierdo, el script emite la señal `skin_selected`, pasando el valor de la variable `character_id` como argumento. La señal `skin_selected` está definida al inicio del script:
    ```gdscript
    signal skin_selected(index: int)
    ```
    Esta señal (`skin_selected`) tiene el propósito de notificar a otros componentes del juego (como un gestor de UI, un controlador de estado del juego o un script de selección de personajes) que se ha seleccionado un personaje específico. El `index` (que corresponde a `character_id`) permite identificar cuál de los personajes ha sido seleccionado.

    > [!Note] `character_id`
    > La variable `@onready var character_id: int` se inicializa cuando el nodo está listo para usarse. Su valor se deriva del nombre del nodo al que se adjunta el script.
    > ```gdscript
    > @onready var character_id: int = self.name.trim_prefix("Character") as int
    > ```
    > Este código asume que los nodos de los personajes tienen un nombre siguiendo el patrón `"CharacterN"`, donde `N` es un número entero (ej., "Character1", "Character2", "Character3"). El método `trim_prefix("Character")` elimina la parte "Character" del nombre, dejando solo el número, el cual se convierte a un entero (`as int`) para ser usado como identificador único. Esta es una forma eficiente de asociar un identificador con un nodo sin necesidad de asignarlo manualmente en el Inspector.