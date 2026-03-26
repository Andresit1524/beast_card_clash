# `Rock`
El script `Rock.gd` define la clase `Rock`, que extiende `StaticBody3D` y representa una roca interactiva en el entorno 3D del juego. Su función principal es gestionar la apariencia visual de la roca (su elemento, estado de "hover" y si es seleccionable) y su interacción con el jugador a través del mouse.

Cada instancia de `Rock` es un objeto 3D que puede mostrar un elemento específico (fuego, agua, etc.), resaltar su contorno cuando el jugador pasa el mouse sobre ella, y ser seleccionada con un clic, emitiendo una señal para notificar a otros componentes del juego. La interactividad está controlada por propiedades exportadas que permiten configurar su comportamiento directamente desde el editor de Godot, y su aspecto visual se actualiza dinámicamente mediante shaders y texturas de sprites.

El diseño se enfoca en una experiencia de desarrollo clara, permitiendo a los programadores interactuar con el componente `Rock` de manera intuitiva y visualmente reactiva.

## Métodos

### Métodos de Godot

### `_ready()`
Este método se ejecuta una vez cuando el nodo `Rock` y todos sus hijos están listos en la escena. Se encarga de la configuración inicial del componente:

*   **Conexión de Señales:**
    *   Conecta la señal `input_event` (propia de `StaticBody3D` para detectar interacciones con el mouse) al método `_on_input_event`.
    *   Conecta las señales `mouse_entered` y `mouse_exited` (también propias de `StaticBody3D` para detectar cuando el cursor entra o sale de su área de colisión) al método `_on_hover`. La conexión de `_on_hover` usa `bind(true)` y `bind(false)` para pasar un argumento booleano indicando si el mouse ha entrado o salido.
*   **Inicialización Visual:**
    *   Llama a `_update_sprite()` para establecer la textura inicial del sprite de la roca según su elemento asignado.
    *   Llama a `_highlight()` para aplicar el resaltado visual inicial, que puede estar activo si la roca es `hovered` o `selectable` desde el inicio.

```gdscript
func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

	# Inicializa los visuales
	_update_sprite()
	_highlight()
```

### Otros métodos

### `_update_sprite()`
Este método es responsable de actualizar la textura del nodo `Sprite3D` (`sprite`) de la roca.

*   Accede a la lista de elementos (`elements_list`, que es una dependencia exportada) y utiliza su método `get_element()` para obtener la textura (`texture`) correspondiente al `element` actual de la roca.
*   Si el nodo no está listo (`is_node_ready()`), la función retorna para evitar errores, asegurando que el `sprite` esté inicializado antes de intentar modificarlo.

```gdscript
## Actualiza el sprite de la roca
func _update_sprite():
	if not is_node_ready(): return

	sprite.texture = elements_list.get_element(element)
```

### `_highlight()`
Este método aplica efectos visuales (color de resaltado y contorno) a la malla 3D (`mesh`) de la roca, utilizando un shader.

*   **Color Base:** Obtiene un color base para el resaltado del diccionario `GameConstants.ELEMENTS_COLORS` basado en el `element` actual de la roca.
*   **Transparencia:** Ajusta el componente `a` (alpha/transparencia) de `highlight_color`. Si la roca está `hovered` (el mouse está sobre ella), la opacidad se establece en `COLOR_OPACITY` (0.2); de lo contrario, se establece en 0.0, haciéndola completamente transparente.
*   **Contorno:** Determina el grosor del contorno. Si la roca es `selectable`, el grosor se establece en `OUTLINE_THICKNESS` (0.15); de lo contrario, es 0.0.
*   **Actualización del Shader:** Utiliza `mesh.set_instance_shader_parameter()` para pasar los valores `highlight_color` y `thickness` al shader de la malla, lo que provoca la actualización visual en tiempo real.

```gdscript
## Aplica el color para resaltar la roca por medio del shader
func _highlight():
	# Color de resaltado
	highlight_color = GameConstants.ELEMENTS_COLORS[element]

	# Transparencia
	highlight_color.a = COLOR_OPACITY if hovered else 0.0

	# Actualiza el shader
	mesh.set_instance_shader_parameter("color", highlight_color)
	mesh.set_instance_shader_parameter("thickness", OUTLINE_THICKNESS if selectable else 0.0)
```

### Funciones asociadas a señales

#### `_on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void`
Esta función es un *callback* para la señal `input_event` del nodo `StaticBody3D`. Se activa cada vez que ocurre un evento de entrada sobre la forma de colisión de la roca. Su propósito es detectar cuando el jugador hace clic izquierdo en la roca.

*   **Filtro de Eventos:** Contiene una serie de condiciones para asegurarse de que solo se procesen los clics izquierdos relevantes:
    *   `not selectable`: Si la roca no es seleccionable, ignora el evento.
    *   `not event is InputEventMouseButton`: Si el evento no es un evento de botón del mouse, ignora el evento.
    *   `not event.button_index == MOUSE_BUTTON_LEFT`: Si el botón presionado no es el botón izquierdo del mouse, ignora el evento.
    *   `not event.is_pressed()`: Si el evento no es una *presión* del botón (es decir, es una liberación), ignora el evento.
*   **Notificación y Emisión:** Si todas las condiciones se cumplen, significa que la roca ha sido clicada con el botón izquierdo.
    *   Imprime un mensaje de depuración colorido en la consola usando `Utilities.print_color`, indicando qué roca fue seleccionada y su elemento, lo cual es útil para el desarrollo y depuración.
    *   Emite la señal `rock_selected`, pasando `self` (la propia instancia de la roca) como argumento. Esto permite que otros nodos que escuchan esta señal reaccionen a la selección de la roca.

```gdscript
# Gestiona el clic para la roca
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (
		not selectable
		or not event is InputEventMouseButton
		or not event.button_index == MOUSE_BUTTON_LEFT
		or not event.is_pressed()
	): return

	Utilities.print_color(
		"[Rock] Roca seleccionada: %s"
		% Utilities.get_enum_name(element, GameConstants.Elements),
		GameConstants.ELEMENTS_COLORS[element]
	)
	rock_selected.emit(self)
```

#### `_on_hover(is_hovered: bool) -> void`
Esta función es un *callback* para las señales `mouse_entered` y `mouse_exited` del nodo `StaticBody3D`. Su función es manejar el estado de "hover" de la roca.

*   **Condición de Seleccionabilidad:** Verifica si la roca es `selectable`. Si no lo es, la función retorna inmediatamente, lo que significa que el estado de `hover` no se actualizará si la roca no puede ser seleccionada.
*   **Actualización de Estado:** Si la roca es `selectable`, el valor del parámetro `is_hovered` (que es `true` para `mouse_entered` y `false` para `mouse_exited`) se asigna directamente a la propiedad `hovered` de la roca.
*   **Disparo de Actualización Visual:** Es importante destacar que la propiedad `hovered` tiene un *setter* (`set(value):`) definido. Este *setter* se encarga de llamar automáticamente a `_highlight()` cada vez que la propiedad `hovered` cambia, asegurando que el efecto visual de resaltado se active o desactive de manera inmediata.

```gdscript
## Selecciona la roca. Usado con señales
func _on_hover(is_hovered: bool) -> void:
	if not selectable: return

	# Cambia el estado de la roca. La actualización sucede automáticamente
	hovered = is_hovered
```