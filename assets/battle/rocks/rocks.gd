## Representa la lsita de rocas de la partida
class_name Rocks extends Node3D


## Altura de las rocas
const ROCK_Z_OFFSET := 0.1
## Cantidad de rocas. Debe ser múltiplo de 6
const ROCK_COUNT := 18
## Radio del círculo de rocas
const RADIUS := 8.0


## Escena de la roca
@export var rock_scene: PackedScene


func _ready():
	_instance_rocks()


## Actualiza las rocas
func _instance_rocks() -> void:
	for child in get_children():
		child.free()

	var director = Vector3.FORWARD * RADIUS

	for i in range(ROCK_COUNT):
		var new_rock: Rock = rock_scene.instantiate()
		var new_rock_angle := (TAU * i) / ROCK_COUNT

		# Posición y rotación de la roca
		new_rock.position = director.rotated(Vector3.UP, new_rock_angle) + Vector3.UP * ROCK_Z_OFFSET
		new_rock.rotate(Vector3.UP, new_rock_angle)
		add_child(new_rock)

		# Elemento. Lo añade después para que se actualice el sprite adecuadamente
		new_rock.element = (i % GameConstants.Elements.size()) as GameConstants.Elements
