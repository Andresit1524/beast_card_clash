## Permite cambiar entre escenas de forma sencilla y desacoplada. Añada las escenas a scenes.tres
## antes de usar este autoload
extends Node


## Recurso con las escenas disponibles
var _scenes: Scenes = preload("res://autoload/resources/scenes.tres")


## Pasa a la escena indicada por su nombre exacto.
## Revisa scenes.tres en el inspector para ver la lista de escenas disponibles
func change_to_scene(scene_name: StringName) -> void:
	get_tree().change_scene_to_packed(_scenes.items[scene_name])
