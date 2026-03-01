extends Node2D

const MAX_VAlUE := 10

@export var element := GameConstants.Elements.NONE
@export_range(1, MAX_VAlUE) var value := 1
@export var hide_card: bool = false
@export var cards_list: CardsList

@onready var sprite := $Sprite
@onready var area := $Area2D

func _process(_delta) -> void:
	set_sprite()
	# change_color()

## Establece el sprite de la carta según el elemento y valor
func set_sprite() -> void:
	if element == GameConstants.Elements.NONE:
		sprite.texture = cards_list.placeholder
		return

	sprite.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder

# ## Pone un color sobre las cartas según su elemento
# func change_color() -> void:
# 	var modulate_color: Color
# 	match element:
# 		GameConstants.Elements.NONE:
# 			modulate_color = Color.BLACK
# 		GameConstants.Elements.AIR:
# 			modulate_color = Color.LIGHT_CYAN
# 		GameConstants.Elements.EARTH:
# 			modulate_color = Color.GREEN
# 		GameConstants.Elements.FIRE:
# 			modulate_color = Color.RED
# 		GameConstants.Elements.WATER:
# 			modulate_color = Color.CYAN

# 	modulate_color = modulate_color.lerp(Color.WHITE, 0.5)
# 	sprite.modulate = modulate_color

## Gestiona el clic sobre una carta
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not (
		event is InputEventMouseButton
		and event.is_pressed()
		and event.button_index == MOUSE_BUTTON_LEFT
	): return

	print_debug("Card (%s) clicked!" % name)
	get_viewport().set_input_as_handled()

## Selecciona una carta
func _hover_card(hover: bool) -> void:
	sprite.modulate = Color.DIM_GRAY if hover else Color.WHITE
