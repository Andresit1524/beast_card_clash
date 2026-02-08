extends Node

# Reproduce la música de inicio al iniciar el juego
func _ready() -> void:
    MusicManager.play_music("start_menu")

## Botón de jugar: se va al selector de personaje o a la escena de juego
func _on_play_button_pressed() -> void:
    if FlagsManager.get_flag("character_selected"):
        push_warning("No hay escena de juego")
    else:
        SceneManager.change_to_scene("character_selector")

## Botón de créditos: carga la escena de créditos
func _on_credits_button_pressed() -> void:
    SceneManager.change_to_scene("credits")

## Botón de salir: sale del juego de inmediato
func _on_quit_button_pressed() -> void:
    get_tree().quit()

## Botón de tutorial: abre el tutorial
func _on_tutorial_button_pressed() -> void:
    SceneManager.change_to_scene("tutorial")
