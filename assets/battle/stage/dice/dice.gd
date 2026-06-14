## Representa el dado de la partida
class_name Dice extends Node3D


signal thrown_dice(number: int)


# Aspecto
const COLOR_OPACITY := 0.3
const OUTLINE_THICKNESS := 0.15

# Lanzamiento del dado
const TWIST_TIME := 0.02
const ROTATION_TIME := 1
const THROW_HEIGHT := 8


## Número que muestra el dado
@export_range(1, 6) var number: int = 1:
	set(value):
		number = value
		_rotate_dice(ROTATIONS[number])
## Hace al dado clicable
@export var clickable: bool = true:
	set(value):
		clickable = value
		if not is_node_ready(): await ready
		_enable_dice(clickable)


@onready var cube: MeshInstance3D = $Cube


## Lista de cuaterniones para rotar el dado a cada número del 1 al 6
@onready var ROTATIONS := {
	1: Basis(Vector3.DOWN, Vector3.RIGHT, Vector3.BACK).get_rotation_quaternion(),
	2: Quaternion.IDENTITY,
	3: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN).get_rotation_quaternion(),
	4: Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP).get_rotation_quaternion(),
	5: Basis(Vector3.RIGHT, Vector3.DOWN, Vector3.FORWARD).get_rotation_quaternion(),
	6: Basis(Vector3.UP, Vector3.LEFT, Vector3.BACK).get_rotation_quaternion(),
}
## Hitbox del dado para habilitar o desabilitar el clic
@onready var static_body: StaticBody3D = $StaticBody


var _start_position: Vector3


func _ready() -> void:
	quaternion = ROTATIONS[number]
	_start_position = position
	static_body.input_ray_pickable = clickable


## Habilita el dado
func _enable_dice(is_enabled: bool) -> void:
	static_body.input_ray_pickable = is_enabled
	cube.set_instance_shader_parameter("thickness", OUTLINE_THICKNESS if is_enabled else 0.0)
	cube.set_instance_shader_parameter("color", Color(Color.CYAN, COLOR_OPACITY) if is_enabled else Color.TRANSPARENT)


## Tira el dado al aire
func throw_dice() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	var new_number := randi_range(1, 6)
	_rotate_dice(ROTATIONS[new_number])

	# Lanza el dado y desactiva el clic
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector3.UP * THROW_HEIGHT, ROTATION_TIME / 2.0)
	clickable = false

	# Regresa el dado y reactiva el clic al acabar
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", _start_position, ROTATION_TIME / 2.0)
	tween.tween_callback(func():
		print("[Dice] Dado lanzado: %s" % new_number)
		thrown_dice.emit(new_number)
	)


## Rota el dado según la base dada
func _rotate_dice(target_rotation: Quaternion):
	var tween := create_tween()

	for i in (ROTATION_TIME / TWIST_TIME):
		tween.tween_property(self, "quaternion", ROTATIONS[randi() % 6 + 1], TWIST_TIME)

	tween.tween_property(self, "quaternion", target_rotation, TWIST_TIME)


# Detecta el clic para lanzar el dado
func _on_static_body_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (
		event is InputEventMouseButton
		and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	): return

	throw_dice()
