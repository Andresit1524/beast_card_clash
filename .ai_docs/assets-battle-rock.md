# `RockScene`
`RockScene` es un script que extiende `StaticBody3D` y representa una roca interactiva y coleccionable en el entorno 3D del juego. Cada instancia de `RockScene` posee un tipo elemental, una representación visual tridimensional, un ícono 2D flotante para indicar su elemento, y lógica para la interacción del jugador. Su función principal es permitir a los jugadores seleccionar rocas, proporcionando retroalimentación visual (resaltado) y emitiendo una señal cuando es seleccionada.

Este componente es fundamental para la mecánica de estrategia elemental del juego, permitiendo la interacción con los "animales colombianos con personalidad académica" y su impacto en la jugabilidad. Además, incluye una clase anidada `Rock` que sirve como una representación de datos abstracta de la roca, útil para manejar la información del elemento sin la sobrecarga de un nodo de escena completo.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se llama una vez que el nodo y todos sus hijos están listos. Se encarga de conectar las señales de entrada y ratón del `StaticBody3D` a sus respectivas funciones controladoras.

```gdscript
func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
```

-   `input_event`: Conecta esta señal a `_on_input_event` para manejar clics del ratón o toques sobre la roca.
-   `mouse_entered`: Conecta esta señal a `_on_mouse_entered` para detectar cuando el cursor del ratón entra en el área de colisión de la roca.
-   `mouse_exited`: Conecta esta señal a `_on_mouse_exited` para detectar cuando el cursor del ratón sale del área de colisión de la roca.

## Otros métodos

### `_update_sprite()`
Este método privado se encarga de actualizar la textura del `Sprite3D` (`sprite`) de la roca para reflejar su `element` actual. Utiliza el recurso `elements_list` para obtener la textura correspondiente al elemento asignado.

```gdscript
func _update_sprite():
	if not is_node_ready(): return

	sprite.texture = elements_list.get_element(element)
```

> **Nota:** La verificación `if not is_node_ready(): return` asegura que el método solo intente acceder a `sprite` y `elements_list` cuando el nodo ha sido inicializado completamente. Esto es crucial ya que el setter de la variable `element` puede ser llamado antes de `_ready()`.

### `_select(value: bool)`
Este método privado controla el efecto visual de resaltado de la roca. Se invoca automáticamente cada vez que la propiedad `selected` se modifica, o cuando la propiedad `hightlight_color` se actualiza si la roca ya está seleccionada.

```gdscript
func _select(value: bool):
	mesh.set_instance_shader_parameter("highlight_color", hightlight_color)
	mesh.material_overlay = hightlight_shader if value else null
```

-   Establece el parámetro `highlight_color` en el shader de la malla (`mesh`) con el valor de la variable `hightlight_color` exportada.
-   Si `value` es `true`, asigna el `hightlight_shader` (shader de resaltado exportado) como `material_overlay` a la `mesh`, haciendo que la roca se resalte.
-   Si `value` es `false`, establece `material_overlay` a `null`, eliminando el efecto de resaltado.

### `get_abstract_rock() -> Rock`
Este método crea y devuelve una nueva instancia de la clase anidada `Rock`, que es una representación de datos abstracta de la roca actual. Esta instancia contiene únicamente el `element` de la `RockScene`.

```gdscript
func get_abstract_rock() -> Rock:
	var new_rock = Rock.new()
	new_rock.element = element
	return new_rock
```

El uso de esta clase abstracta es útil para pasar la información del tipo elemental de la roca a otros componentes del juego sin la necesidad de transferir o referenciar el nodo de escena completo `RockScene`, lo que puede ser más eficiente y desacoplado.

## Funciones asociadas a señales

### `_on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void`
Esta función se ejecuta cuando se recibe un evento de entrada mientras el cursor del ratón está sobre la roca. Está conectada a la señal `input_event` del `StaticBody3D`.

```gdscript
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed(): return

	print_debug("Roca seleccionada: %s" % element)
	rock_selected.emit(self)
```

-   Primero, verifica si el evento es un `InputEventMouseButton`. Si no lo es, ignora el evento.
-   Luego, comprueba si el evento es un `MOUSE_BUTTON_LEFT` presionado. Si es así, ignora el evento para evitar doble procesamiento (ya que solo nos interesa la acción de soltar el botón).
-   Si el evento es un clic de ratón (es decir, el botón izquierdo *no* está presionado, indicando que fue liberado), imprime un mensaje de depuración con el elemento de la roca seleccionada.
-   Finalmente, emite la señal `rock_selected`, pasando `self` (la propia instancia de `RockScene`) como argumento, notificando a otros componentes que esta roca ha sido seleccionada.

### `_on_mouse_entered() -> void`
Esta función se ejecuta cuando el cursor del ratón entra en el área de colisión del `CollisionShape3D` de la roca. Está conectada a la señal `mouse_entered` del `StaticBody3D`.

```gdscript
func _on_mouse_entered() -> void:
	selected = true
```

-   Establece la propiedad `selected` a `true`, lo que activa el efecto de resaltado visual de la roca a través del setter de `selected` que llama a `_select(true)`.

### `_on_mouse_exited() -> void`
Esta función se ejecuta cuando el cursor del ratón sale del área de colisión del `CollisionShape3D` de la roca. Está conectada a la señal `mouse_exited` del `StaticBody3D`.

```gdscript
func _on_mouse_exited() -> void:
	selected = false
```

-   Establece la propiedad `selected` a `false`, lo que desactiva el efecto de resaltado visual de la roca a través del setter de `selected` que llama a `_select(false)`.