## [code]Rock[code] representa cada roca del escenario de batalla. Esta clase gestiona sus valores
## y su aspecto visual, así como sus interacciones con el usuario.
class_name Rock extends StaticBody3D


## Emitida cuando se selecciona la roca
signal selected(rock: Rock)


const COLOR_OPACITY := 0.2
const OUTLINE_THICKNESS := 0.15


## Elemento de la roca
@export var element: Constants.Elements = Constants.Elements.NONE:
	set(value):
		element = value
		_update_sprite()
		_highlight()
## Estado actual de la roca
@export var hovered: bool = false:
	set(value):
		hovered = value and selectable
		_highlight()
## Hace que la roca sea seleccionable
@export var selectable: bool = false:
	set(value):
		selectable = value
		hovered = hovered and selectable
		if is_node_ready(): _highlight()

@export_group("Dependencias")
## Lista de elementos para las rocas
@export var elements_list: ElementsList


@onready var mesh: MeshInstance3D = %Mesh
@onready var sprite: Sprite3D = %Sprite


## Posición de esta roca en la plataforma
var rock_index: int
## Color para el resaltado
var highlight_color: Color


func _ready():
	# Inicializa los visuales
	_update_sprite()
	_highlight()


#region Aspecto visual


## Actualiza el sprite de la roca
func _update_sprite():
	if not is_node_ready(): await ready

	sprite.texture = elements_list.get_element(element)


## Aplica el color para resaltar la roca por medio del shader
func _highlight():
	if not is_node_ready(): await ready

	# Color de resaltado y transparencia
	highlight_color = Constants.ELEMENTS_COLORS[element]
	highlight_color.a = COLOR_OPACITY if hovered else 0.0

	# Actualiza el shader
	mesh.set_instance_shader_parameter("color", highlight_color)
	mesh.set_instance_shader_parameter("thickness", OUTLINE_THICKNESS if selectable else 0.0)


#endregion


#region Clics e interfaz


# Gestiona el clic para la roca
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not selectable or not event.is_action_pressed(&"left_click"): return

	selected.emit(self)


## Selecciona la roca. Usado con señales
func _on_hover(is_hovered: bool) -> void:
	if not selectable: return

	# Cambia el estado de la roca. La actualización sucede automáticamente
	hovered = is_hovered


#endregion
