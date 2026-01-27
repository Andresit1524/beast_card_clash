extends Node

var start_scene: PackedScene = preload("res://ui/start_menu/start_menu.tscn")
var credits_scene: PackedScene = preload("res://ui/credits/credits.tscn")
var tutorial_scene: PackedScene = preload("res://ui/tutorial/tutorial.tscn")

# Pasa a la escena principal
func to_start_scene():
    get_tree().change_scene_to_packed(start_scene)

# Pasa a la escena de créditos
func to_credits_scene():
    get_tree().change_scene_to_packed(credits_scene)

# Pasa a la escena de tutorial
func to_tutorial_scene():
    get_tree().change_scene_to_packed(tutorial_scene)
