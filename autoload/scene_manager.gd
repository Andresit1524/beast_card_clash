extends Node

## Lista de escenas disponibles
var scenes: Dictionary[String, PackedScene] = {
    "start": preload("res://ui/start_menu/start_menu.tscn"),
    "credits": preload("res://ui/credits/credits.tscn"),
    "tutorial": preload("res://ui/tutorial/tutorial.tscn")
}

## Pasa a la escena indicada por su nombre exacto.
## Consulta en el singleton por los nombres disponibles
func change_to_scene(scene_name: String) -> void:
    get_tree().change_scene_to_packed(scenes[scene_name])