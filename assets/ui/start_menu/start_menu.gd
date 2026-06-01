extends Node


## Etiqueta de la versión actual
@onready var version: Label = %Version


func _ready() -> void:
	MusicManager.play_music("menu_loop")

	# Actualiza la versión automáticamnte
	version.text = "v%s" % ProjectSettings.get_setting("application/config/version", "[desconocida]")


## Botón de jugar: se va al selector de personaje o a la escena de juego
func _on_play_button_pressed() -> void:
	if FlagsManager.get_flag("character_selected"):
		push_warning("No hay escena de mapa. Pasando a partida rápida")
		SceneManager.change_to_scene("battle")
	else:
		SceneManager.change_to_scene("skin_selector")


## Botón de partida rápida: se va a la escena de batalla de inmediato
func _on_quick_play_button_pressed() -> void:
	SceneManager.change_to_scene("battle")


## Botón de créditos: carga la escena de créditos
func _on_credits_button_pressed() -> void:
	SceneManager.change_to_scene("credits")


## Botón de tutorial: abre el tutorial
func _on_tutorial_button_pressed() -> void:
	SceneManager.change_to_scene("tutorial")


## Botón de salir: sale del juego de inmediato
func _on_quit_button_pressed() -> void:
	get_tree().quit()
