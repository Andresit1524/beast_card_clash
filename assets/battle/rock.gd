class_name RockScene extends StaticBody3D


## Estados de la roca
enum States {
	DISABLED,
	HOVER,
	UNHOVER,
}


signal rock_selected(rock: Rock)


@export_group("Parámetros")
## Elemento de la roca
@export var element: GameConstants.Elements = GameConstants.Elements.NONE:
	set(value):
		element = value
		_update_sprite()
## Estado actual de la roca
@export var current_state: States = States.UNHOVER:
	set(value):
		if current_state == value: return
		current_state = value
		if is_node_ready(): _apply_highlight()

@export_group("Visuales")
## Color para resaltar la roca
@export_color_no_alpha var hightlight_color: Color = Color.TEAL:
	set(value):
		hightlight_color = value
		if is_node_ready(): _apply_highlight()
## Color al desactivas la roca
@export_color_no_alpha var disabled_color: Color = Color.BLACK:
	set(value):
		disabled_color = value
		if is_node_ready(): _apply_highlight()
## Opacidad de los colores
@export_range(0, 1, 0.05) var opacity: float = 0.5:
	set(value):
		opacity = value
		if is_node_ready(): _apply_highlight()

@export_group("Dependencias")
## Lista de elementos para las rocas
@export var elements_list: ElementsList


@onready var mesh: MeshInstance3D = %Mesh
@onready var sprite: Sprite3D = %Element


func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))

	# Inicializa los visuales
	_update_sprite()
	_apply_highlight()


#region Aspecto visual


## Actualiza el sprite de la roca
func _update_sprite():
	if not is_node_ready(): return

	sprite.texture = elements_list.get_element(element)


## Aplica el color para resaltar la roca por medio del shader
func _apply_highlight():
	print(
		"Roca %s coloreada según modo %s"
		% [name, Utilities.get_enum_name(current_state, States)]
	)

	var final_color: Color
	match current_state:
		States.DISABLED: final_color = disabled_color
		States.HOVER: final_color = hightlight_color
		# Blanco transparente conserva el color original
		States.UNHOVER: final_color = Color(1, 1, 1, 0)

	if current_state != States.UNHOVER: final_color.a = opacity
	mesh.set_instance_shader_parameter("color", final_color)


#endregion


#region Clics e interfaz


# Gestiona el clic para la roca
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if (
		current_state == States.DISABLED
		or not event is InputEventMouseButton
		or not event.button_index == MOUSE_BUTTON_LEFT
		or not event.is_pressed()
	): return


	print_debug(
		"[Rock] Roca seleccionada: %s"
		% Utilities.get_enum_name(element, GameConstants.Elements)
	)
	rock_selected.emit(_get_abstract_rock())


## Selecciona la roca. Usado con señales
func _on_hover(hover: bool) -> void:
	if current_state == States.DISABLED: return

	# Cambia el estado de la roca. La actualización sucede automáticamente
	current_state = States.HOVER if hover else States.UNHOVER


#endregion


#region Roca abstracta


func _get_abstract_rock() -> Rock:
	return Rock.new(element)


## Clase para representar los datos de una roca
class Rock:
	var element: GameConstants.Elements = GameConstants.Elements.NONE

	func _init(new_element: GameConstants.Elements) -> void:
		element = new_element


#endregion
