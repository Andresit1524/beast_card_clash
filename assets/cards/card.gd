extends TextureButton


const ROTATION_TIME := 0.15
const HOVER_TIME := 0.2


## Elemento de la carta
@export var element := GameConstants.Elements.NONE:
	set(value):
		element = value
		update_sprite()
## Valor de la carta
@export_range(1, GameConstants.MAX_CARD_VAlUE) var value := 1:
	set(val):
		value = val
		update_sprite()
## Oculta la carta
@export var hide_card: bool = false:
	set(value):
		if value == hide_card: return
		hide_card = value
		rotate_card()
## Invalida la carta
@export var disable_card: bool = false:
	set(value):
		disable_card = value
		update_sprite()
## Lista de sprites para las cartas
@export var cards_list: CardsList


# Estado inicial
var _start_pos: Vector2
var _start_size: Vector2
var _start_scale: Vector2


func _ready() -> void:
	_start_pos = position
	_start_size = size
	_start_scale = scale

	# Centra el pivote
	pivot_offset = size / 2

	update_sprite()


## Establece una lista de valores para la carta. Úsalo solo para asignaciones múltiples
func set_properties(values: Dictionary) -> void:
	for property in values:
		var new_value = values[property]

		if not property in self:
			push_error("Propiedad no encontrada: %s" % property)
			continue

		set(property, new_value)

	update_sprite()


## Cambia la imagen de la carta
func update_sprite() -> void:
	if not cards_list: return

	# Oscurece la carta cuando está desactivada
	modulate = Color.DIM_GRAY if disable_card else Color.WHITE

	if hide_card:
		texture_normal = cards_list.placeholder
		return

	texture_normal = cards_list.get_card(element, value)


func _on_pressed() -> void:
	if disable_card or hide_card: return

	print_debug("Carta %s-%s presionada" % [element, value])


func _on_mouse_entered() -> void:
	hover_card(true)


func _on_mouse_exited() -> void:
	hover_card(false)


## Cambia los parámetros de la carta
func hover_card(hover: bool) -> void:
	if disable_card: return

	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)

	# Cambia coloración, posición y tamaño de la carta
	if hover:
		tween.tween_property(self , "modulate", Color.GRAY, HOVER_TIME)
		tween.tween_property(self , "size", Vector2(_start_size.x, _start_size.y * 1.7), HOVER_TIME)

		if hide_card: return
		tween.tween_property(self , "position", _start_pos + Vector2(0, -size.y / 2) * scale, HOVER_TIME)
	else:
		tween.tween_property(self , "modulate", Color.WHITE, HOVER_TIME)
		tween.tween_property(self , "size", _start_size, HOVER_TIME)

		if hide_card: return
		tween.tween_property(self , "position", _start_pos, HOVER_TIME)


## Rota la carta para ocultarla o mostrarla
func rotate_card() -> void:
	if not _start_scale: return

	# Este tween no debe ser paralelo
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var current_scale = scale

	tween.tween_property(self , "scale", Vector2(0, scale.y), ROTATION_TIME)
	tween.tween_callback(update_sprite)
	tween.tween_property(self , "scale", current_scale, ROTATION_TIME)
