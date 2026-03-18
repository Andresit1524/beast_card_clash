## Representa la lsita de rocas de la partida
class_name Rocks extends Node3D


const ROCK_Y_OFFSET := 0.1


## Rock scene
@export var rock_scene: PackedScene
## Cantidad de rocas
@export_range(1, 20, 1, "or_greater") var rocks_count: int = 18:
	set(value):
		rocks_count = value
		update_rocks()
## Distancia desde el centro hasta cada roca
@export var radius: float = 8.0:
	set(value):
		radius = value
		update_rocks()


var rocks_list := []


func _ready():
	update_rocks()


## Actualiza las rocas
func update_rocks() -> void:
	for child in get_children():
		child.queue_free()

	if not is_node_ready(): return

	var director = Vector3.FORWARD * radius

	for i in range(rocks_count):
		var new_rock: RockScene = rock_scene.instantiate()
		var new_rock_rotation := (TAU * i) / rocks_count

		# Posición y rotación de la roca
		new_rock.position = director.rotated(Vector3.UP, new_rock_rotation)
		new_rock.position.y = ROCK_Y_OFFSET
		new_rock.rotate(Vector3.UP, new_rock_rotation)
		add_child(new_rock)

		# Elemento
		new_rock.element = (i % GameConstants.Elements.size()) as GameConstants.Elements
		new_rock.state = RockScene.States.DISABLED
		rocks_list.append(new_rock)


## Obtiene la lista de rocas abstractas
func get_abstract_rocks_list() -> Array:
	for rock_pos in get_children():
		var rock: RockScene = rock_pos.get_child(0)
		rocks_list.append(rock._get_abstract_rock())

	return rocks_list
