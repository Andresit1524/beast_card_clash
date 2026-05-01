class_name Card extends TextureButton


signal card_selected(card: Card)


const ROTATION_TIME := 0.15
const HOVER_TIME := 0.2
const ONDULAION_STRENGHT := 2
const ONDULAION_SPEED := 3.5


## Elemento de la carta
@export var element := Constants.Elements.NONE:
	set(value):
		element = value
		_update_sprite()
## Valor de la carta
@export_range(1, Constants.MAX_CARD_VAlUE) var value := 1:
	set(val):
		value = val
		_update_sprite()
## Oculta la carta
@export var hide_card: bool = false:
	set(value):
		if value == hide_card: return
		hide_card = value
		_flip_card()
## Invalida la carta
@export var disable_card: bool = false:
	set(value):
		disable_card = value
		_update_sprite()
## Lista de sprites para las cartas
@export var cards_list: CardsList


# Estados iniciales
@onready var _start_size := size
@onready var _start_scale := scale
@onready var _start_position := position


var elapsed_time: float = randf() * TAU


func _ready() -> void:
	# Centra el pivote
	pivot_offset = size / 2

	_update_sprite()


func _physics_process(delta: float) -> void:
	# Actualiza el tiempo y posición de la carta
	elapsed_time += delta
	position = _start_position + _get_ondulation_offset()


## Establece una lista de valores para la carta. Úsalo solo para asignaciones múltiples
func set_properties(values: Dictionary) -> void:
	for property in values:
		var new_value = values[property]

		if not property in self:
			push_error("[Card] Propiedad no encontrada: %s" % property)
			continue

		set(property, new_value)

	_update_sprite()


## Cambia la imagen de la carta
func _update_sprite() -> void:
	if not cards_list: return

	# Oscurece la carta cuando está desactivada
	modulate = Color.DIM_GRAY if disable_card else Color.WHITE

	if hide_card:
		texture_normal = cards_list.placeholder
		return

	texture_normal = cards_list.get_card(element, value)


## Resalta y restablece la carta cuando se le pasa el mouse
func _hover_card(hover: bool) -> void:
	if disable_card: return

	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE)

	# Cambia coloración, posición y tamaño de la carta
	# Se desactiva o activa physics_process para evitar que la carta salte a su sitio original
	if hover:
		tween.tween_property(self, "modulate", Color.GRAY, HOVER_TIME)
		tween.tween_property(self, "size", Vector2(_start_size.x, _start_size.y * 1.5), HOVER_TIME)

		if hide_card: return
		set_physics_process(false)
		var hover_offset := Vector2(0, -size.y / 2) * scale
		tween.tween_property(self, "position", _start_position + hover_offset, HOVER_TIME)
	else:
		tween.tween_property(self, "modulate", Color.WHITE, HOVER_TIME)
		tween.tween_property(self, "size", _start_size, HOVER_TIME)

		if hide_card: return
		tween.tween_property(self, "position", _start_position, HOVER_TIME)
		tween.tween_callback(func(): set_physics_process(true))


## Voltea la carta para ocultarla o mostrarla
func _flip_card() -> void:
	if not _start_scale: return

	# Este tween no debe ser paralelo
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var current_scale = scale

	tween.tween_property(self, "scale", Vector2(0, scale.y), ROTATION_TIME)
	tween.tween_callback(_update_sprite)
	tween.tween_property(self, "scale", current_scale, ROTATION_TIME)


## Obtiene el desplazamiento de la carta en una forma ondularoria
func _get_ondulation_offset() -> Vector2:
	return Vector2(0, sin(elapsed_time * ONDULAION_SPEED)) * ONDULAION_STRENGHT


## Avisa cuando la carta es presionada
func _on_pressed() -> void:
	if disable_card or hide_card: return

	print(
		"[Card] Carta %s-%s presionada"
		% [Utilities.get_enum_name(element, Constants.Elements), value]
	)
	card_selected.emit(self)


func _on_mouse_entered() -> void:
	_hover_card(true)


func _on_mouse_exited() -> void:
	_hover_card(false)
