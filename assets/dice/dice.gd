extends Node3D


const ROTATION_TIME := 0.02
const ROTATION_TOTAL_TIME := 1
const THROW_HEIGHT := 8


## Número que muestra el dado
@export_range(1, 6) var number: int = 1:
	set(value):
		number = value
		if is_node_ready(): set_dice_rotation(ROTATIONS[number])


## List of quaternions to rotate the dice
@onready var ROTATIONS := {
	1: Basis(Vector3.DOWN, Vector3.RIGHT, Vector3.BACK).get_rotation_quaternion(),
	2: Quaternion.IDENTITY,
	3: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN).get_rotation_quaternion(),
	4: Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP).get_rotation_quaternion(),
	5: Basis(Vector3.RIGHT, Vector3.DOWN, Vector3.FORWARD).get_rotation_quaternion(),
	6: Basis(Vector3.UP, Vector3.LEFT, Vector3.BACK).get_rotation_quaternion(),
}


var _start_position


func _ready() -> void:
	if number in ROTATIONS: quaternion = ROTATIONS[number]
	_start_position = position


## Mezcla el dado y lo lanza al aire
func shuffle_dice() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	set_dice_rotation(ROTATIONS[randi() % 6 + 1])

	# Lanza el dado
	tween.tween_property(self , "position", Vector3.UP * THROW_HEIGHT, ROTATION_TOTAL_TIME / 2.0)

	# Regresa el dado
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self , "position", _start_position, ROTATION_TOTAL_TIME / 2.0)


## Rota el dado según la base dada
func set_dice_rotation(target_rotation: Quaternion):
	var tween := create_tween()

	for i in range(ROTATION_TOTAL_TIME / ROTATION_TIME):
		tween.tween_property(self , "quaternion", ROTATIONS[randi() % 6 + 1], ROTATION_TIME)

	tween.tween_property(self , "quaternion", target_rotation, ROTATION_TIME)


func _on_static_body_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if not (
		event is InputEventMouseButton
		and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	): return

	shuffle_dice()
