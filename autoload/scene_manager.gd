extends Node

## Lista de escenas disponibles
var _scenes: Scenes = preload("uid://bn7v8txng2pda")

# Revisa al inicio las escenas para que estén bien definidas
func _ready():
	_scenes.expected_type = TYPE_OBJECT
	_scenes.check_item_types()

## Pasa a la escena indicada por su nombre exacto.
## Revisa scenes.tres en el inspector para ver la lista de escenas disponibles
func change_to_scene(scene_name: String) -> void:
	get_tree().change_scene_to_packed(_scenes.get_item(scene_name))
