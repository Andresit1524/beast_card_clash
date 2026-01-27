extends TextureRect

@export var panels_list: Array[Resource]

var panel: TextureRect = self
var current_panel: int = 0

func _ready():
    # Fuerza a mostrar el primer panel al inicio
    panel.texture = panels_list[0]

# Cambia de panel cuando se presiona el botón de siguiente panel
func _on_next_button_pressed() -> void:
    current_panel += 1

    # ! Cuando nos pasemos del último panel, volvemos (por ahora)
    if current_panel >= panels_list.size():
        return

    panel.texture = panels_list[current_panel]
