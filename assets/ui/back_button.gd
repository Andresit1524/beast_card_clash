extends Control

# Se conecta a su propia señal para detectar clics
func _ready() -> void:
    connect("pressed", _on_pressed)

## Botón de retroceso: se mueve a la escena principal
func _on_pressed() -> void:
    SceneManager.change_to_scene("start_menu")
