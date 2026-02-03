extends VBoxContainer

@export var panels_list: Array[Resource]
@export var panel_node: TextureRect

var current_panel: int = 0

# Fuerza a mostrar el primer panel al inicio
func _ready() -> void:
    panel_node.texture = panels_list[0]

## Cambia de panel_node cuando se presiona el botón de siguiente panel
func _on_next_button_pressed() -> void:
    current_panel += 1

    if current_panel >= panels_list.size():
        _on_skip_button_pressed()
        return

    panel_node.texture = panels_list[current_panel]

## Se salta el tutorial.
## ! Por ahora no está la lógica para esto
func _on_skip_button_pressed() -> void:
    print("[Info] Salta el tutorial!")
    return
