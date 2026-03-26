class_name Rock extends StaticBody3D


signal rock_selected(rock: Rock)


const COLOR_OPACITY := 0.2
const OUTLINE_THICKNESS := 0.15


## Elemento de la roca
@export var element: GameConstants.Elements = GameConstants.Elements.NONE:
	set(value):
		element = value
		_update_sprite()
		if is_node_ready(): _highlight()
## Estado actual de la roca
@export var hovered: bool = false:
	set(value):
		if not selectable:
			hovered = false
			return

		hovered = value
		if is_node_ready(): _highlight()
## Hace que la roca sea seleccionable
@export var selectable: bool = false:
	set(value):
		selectable = value
		if not selectable: hovered = false
		if is_node_ready(): _highlight()

@export_group("Dependencias")
## Lista de elementos para las rocas
@export var elements_list: ElementsList


@onready var mesh: MeshInstance3D = %Mesh
@onready var sprite: Sprite3D = %Sprite


var rock_index: int
var highlight_color: Color


func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

	# Inicializa los visuales
	_update_sprite()
	_highlight()


#region Aspecto visual


## Actualiza el sprite de la roca
func _update_sprite():
	if not is_node_ready(): return

	sprite.texture = elements_list.get_element(element)


## Aplica el color para resaltar la roca por medio del shader
func _highlight():
	# Color de resaltado
	highlight_color = GameConstants.ELEMENTS_COLORS[element]

	# Transparencia
	highlight_color.a = COLOR_OPACITY if hovered else 0.0

	# Actualiza el shader
	mesh.set_instance_shader_parameter("color", highlight_color)
	mesh.set_instance_shader_parameter("thickness", OUTLINE_THICKNESS if selectable else 0.0)


#endregion


#region Clics e interfaz


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


## Selecciona la roca. Usado con señales
func _on_hover(is_hovered: bool) -> void:
	if not selectable: return

	# Cambia el estado de la roca. La actualización sucede automáticamente
	hovered = is_hovered


#endregion
