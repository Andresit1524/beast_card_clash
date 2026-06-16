## [code]Dice[/code] representa el dado de la batalla y gestiona su aspecto visual junto con sus
## interacciones con el jugador
class_name Dice extends Node3D


## Se emite cuando el dado es lanzado, no importa por quien
signal thrown(number: int)


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
		_rotate_dice(number)
## Hace al dado clicable
@export var clickable: bool = true:
	set(value):
		clickable = value
		_enable_dice(value)


## Lista de cuaterniones para rotar el dado a cada número del 1 al 6
@onready var ROTATIONS := {
	1: Basis(Vector3.DOWN, Vector3.RIGHT, Vector3.BACK).get_rotation_quaternion(),
	2: Quaternion.IDENTITY,
	3: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN).get_rotation_quaternion(),
	4: Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP).get_rotation_quaternion(),
	5: Basis(Vector3.RIGHT, Vector3.DOWN, Vector3.FORWARD).get_rotation_quaternion(),
	6: Basis(Vector3.UP, Vector3.LEFT, Vector3.BACK).get_rotation_quaternion(),
}

## Elemento visual (cubo con la textura)
@onready var cube: MeshInstance3D = $Cube
## Hitbox para habilitar o desabilitar el clic
@onready var static_body: StaticBody3D = $StaticBody

@onready var _start_position: Vector3 = position


## Tira el dado a un número al azar
func throw_dice() -> void:
	var new_number := randi_range(1, 6)
	_rotate_dice(new_number)

	# Lanza y desactiva el clic
	var tween := create_tween().set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, ^"position", Vector3.UP * THROW_HEIGHT, ROTATION_TIME / 2.0)

	clickable = false

	# Regresa y reactiva el clic al acabar
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, ^"position", _start_position, ROTATION_TIME / 2.0)
	tween.tween_callback(thrown.emit.bind(new_number))


## Rota el dado aleatoriamente hasta obtener el número dado
func _rotate_dice(to: int):
	var tween := create_tween()
	for i in (ROTATION_TIME / TWIST_TIME):
		tween.tween_property(self, ^"quaternion", ROTATIONS[randi() % 6 + 1], TWIST_TIME)

	tween.tween_property(self, ^"quaternion", ROTATIONS[to], TWIST_TIME)


## Activa o desactiva el dado
func _enable_dice(value: bool) -> void:
	if not is_node_ready(): await ready

	static_body.input_ray_pickable = value
	cube.set_instance_shader_parameter(&"thickness", OUTLINE_THICKNESS if value else 0.0)
	cube.set_instance_shader_parameter(
		&"color",
		Color(Color.CYAN, COLOR_OPACITY) if value else Color.TRANSPARENT
	)


# Detecta el clic para lanzar el dado
func _on_static_body_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not event.is_action_pressed(&"left_click"): return
	throw_dice()
