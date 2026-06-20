## Representa a un personaje del selector de skins
class_name Character extends Sprite3D


## Cuando se clica el personaje, emite su propia skin para establecerla
signal skin_selected(skin: Texture2D)


## Caja de colisión
@onready var click_area = $ClickArea


func _ready() -> void:
	# Se conecta a su propia señal de clic (evento)
	click_area.input_event.connect(_on_input_event)


func _on_input_event(_camera, event: InputEvent, _pos, _normal, _shape_idx) -> void:
	# Emite su propia skin cuando recibe un clic
	if event.is_action_pressed("left_click"): skin_selected.emit(texture)
