extends BaseButton

# Se conecta a su propia señal para detectar clics
func _ready() -> void:
    connect("pressed", _on_pressed)

# Se mueve a la escena principal cuando se presiona el botón de retroceso
func _on_pressed() -> void:
    SceneManager.change_to_scene("start")
