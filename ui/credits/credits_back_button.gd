extends TextureButton

# Se mueve a la escena principal cuando se presiona el botón de retroceso
func _on_pressed() -> void:
    SceneManager.to_start_scene()