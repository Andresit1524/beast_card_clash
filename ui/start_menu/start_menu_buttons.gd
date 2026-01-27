extends VBoxContainer

@export var credits_scene: PackedScene
@export var tutorial_scene: PackedScene

# Botón de jugar: carga la escena de tutorial
func _on_play_button_pressed() -> void:
    SceneManager.to_tutorial_scene()

# Botón de créditos: carga la escena de créditos
func _on_credits_button_pressed() -> void:
    SceneManager.to_credits_scene()

# Botón de salir: sale del juego de inmediato
func _on_quit_button_pressed() -> void:
    get_tree().quit()
