extends Node

# Reproduce la música de inicio al iniciar el juego
func _ready() -> void:
    MusicManager.play_music("start_menu")

# Botón de jugar: carga la escena de tutorial
func _on_play_button_pressed() -> void:
    SceneManager.change_to_scene("tutorial")

# Botón de créditos: carga la escena de créditos
func _on_credits_button_pressed() -> void:
    SceneManager.change_to_scene("credits")

# Botón de salir: sale del juego de inmediato
func _on_quit_button_pressed() -> void:
    get_tree().quit()
