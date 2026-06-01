extends Node


@onready var contents: Control = $Contents


var panels: Array[Control]
var current_panel: int = 0


# Fuerza a mostrar el primer panel al inicio
func _ready() -> void:
	# Configura
	for child in contents.get_children():
		if not child is Control: continue

		child.visible = false
		panels.append(child)

	panels[0].visible = true


## Hace visible el panel indicado y oculta el resto
func _next_panel() -> bool:
	current_panel += 1

	# Error de rango
	if current_panel < 0 or current_panel >= panels.size(): return false

	for i in range(panels.size()):
		panels[i].visible = (i == current_panel)

	return true


## Cambia de panel cuando se presiona el botón de siguiente, o se sale si no es el caso
func _on_next_button_pressed() -> void:
	if not _next_panel(): SceneManager.change_to_scene("start_menu")


## Botón de saltar:
## ! Por ahora no está la acción para esto. Por ahora, salir al menú principal
func _on_skip_button_pressed() -> void:
	print_debug("¡Salta el tutorial!")
	SceneManager.change_to_scene("start_menu")


## Botón atrás: vuelve al menú principal
func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("start_menu")
