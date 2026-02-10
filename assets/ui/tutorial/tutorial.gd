extends Node

@export var panels_list: Array[Resource]
@export var panel_node: TextureRect

var current_panel: int = 0

# Fuerza a mostrar el primer panel al inicio
func _ready() -> void:
	panel_node.texture = panels_list[0]

## Cambia de panel cuando se presiona el botón de siguiente
func _on_next_button_pressed() -> void:
	current_panel += 1

	if current_panel >= panels_list.size():
		_on_skip_button_pressed()
		return

	panel_node.texture = panels_list[current_panel]

## Botón de saltar:
## ! Por ahora no está la acción para esto
func _on_skip_button_pressed() -> void:
	print_debug("¡Salta el tutorial!")

## Botón atrás: vuelve al menú principal
func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("start_menu")
