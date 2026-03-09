extends Node3D


const ROCK_Y_OFFSET := 0.1


## Rock scene
@export var rock_scene: PackedScene
## Cantidad de rocas
@export_range(1, 20, 1, "or_greater") var rocks_count: int = 10:
	set(value):
		rocks_count = value
		update_rocks()
## Distancia desde el centro hasta cada roca
@export var radius: float = 10.0:
	set(value):
		radius = value
		update_rocks()


func _ready():
	update_rocks()

## Actualiza las rocas
func update_rocks() -> void:
	for child in get_children():
		child.queue_free()

	if not is_node_ready(): return

	var director = Vector3.FORWARD * radius

	for i in range(rocks_count):
		var new_rock: Node3D = rock_scene.instantiate()
		var new_rock_rotation := (TAU * i) / rocks_count

		new_rock.position = director.rotated(Vector3.UP, new_rock_rotation)
		new_rock.position.y = ROCK_Y_OFFSET
		new_rock.rotate(Vector3.UP, new_rock_rotation)
		add_child(new_rock, true)
