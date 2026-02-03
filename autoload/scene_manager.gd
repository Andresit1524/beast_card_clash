extends Node

## Lista de escenas disponibles (referenciadas por UID)
var _scenes: Dictionary[String, PackedScene] = {
    "start_menu": preload("uid://dr0fenfnqsha3"),
    "credits": preload("uid://suub121nq2cd"),
    "tutorial": preload("uid://c1gyjxesm65cg")
}

## Pasa a la escena indicada por su nombre exacto.
## Consulta en el singleton por los nombres disponibles
func change_to_scene(scene_name: String) -> void:
    get_tree().change_scene_to_packed(_scenes[scene_name])
