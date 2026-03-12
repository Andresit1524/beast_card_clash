class_name Rock extends StaticBody3D


signal rock_selected(rock: Rock)


## Lista de elementos para las rocas
@export var elements_list: ElementsList
## Realta la roca
@export var selected: bool = false:
	set(value):
		selected = value
		_select(value)
## Color para resaltar la roca
@export var hightlight_color: Color = Color(1, 0, 1, 0.5):
	set(value):
		hightlight_color = value
		if selected: _select(selected)
## Shader para resaltar la roca
@export var hightlight_shader: ShaderMaterial


@onready var mesh: MeshInstance3D = $Mesh
@onready var sprite: Sprite3D = $Element
@onready var collision: CollisionShape3D = $CollisionShape


var element: GameConstants.Elements:
	set(value):
		element = value
		_update_sprite()


func _ready():
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


## Actualiza el sprite de la roca
func _update_sprite():
	if not is_node_ready(): return

	sprite.texture = elements_list.get_element(element)


## Aplica un shader para resaltar la roca
func _select(value: bool):
	mesh.set_instance_shader_parameter("highlight_color", hightlight_color)
	mesh.material_overlay = hightlight_shader if value else null


# Gestiona el clic para la roca
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not event is InputEventMouseButton: return
	if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed(): return

	print_debug("Roca seleccionada: %s" % element)
	rock_selected.emit(self )


func _on_mouse_entered() -> void:
	selected = true


func _on_mouse_exited() -> void:
	selected = false
