class_name Hand extends Path2D


const HIDE_OFFSET := Vector2(0, 300)
const HIDE_SCALE := 1 / 1.3
const MOVE_TIME := 0.2


## Oculta la mano de cartas
@export var hide_cards: bool = false:
	set(value):
		hide_cards = value
		_refresh_cards()
## Tamaño de la carta
@export var card_scale: float = 0.25:
	set(value):
		card_scale = value
		_refresh_cards()
## Elemento del jugador
@export var current_element: Constants.Elements = Constants.Elements.NONE:
	set(value):
		current_element = value
		_refresh_cards()

@export_group("Dependencias")
## Escena de la carta para instanciarla
@export var card_scene: PackedScene
## Conjuntos de puntos para las posiciones de las cartas
@export var curves: Dictionary[StringName, Curve2D] = {
	&"normal": null,
	&"hidden": null
}


@onready var _start_position := position


## Configura la lista de cartas en pantalla usando como base las de una baraja real. [br]
## Usado en BattleManager
func set_from_deck(deck: Array[Card]) -> void:
	# Elimina a todas las cartas sobrantes
	for card_pos in get_children():
		var actual_card = card_pos.get_child(0)
		if not actual_card in deck: card_pos.queue_free()

	for card in deck:
		# Si la carta ya tiene un padre, saltamos para no duplicar wrappers
		if card.get_parent() != null: continue

		var new_card_pos := PathFollow2D.new()
		add_child(new_card_pos)

		# Ajusta la carta antes de emparentarla
		card.set_properties({
			"element": card.element,
			"value": card.value,
			"hide_card": false,
		})
		print(
			"[Hand] Carta actualizada: %s_%s"
			% [Utilities.get_enum_name(card.element, Constants.Elements), card.value]
		)

		new_card_pos.add_child(card)

	_refresh_cards()


## Actualiza las cartas a los nuevos valores de posición y escala
func _refresh_cards() -> void:
	var cards_pos := get_children()
	if cards_pos.is_empty(): return

	var tween := create_tween()
	tween.set_parallel().set_trans(Tween.TRANS_SINE)

	_set_hidden_cards(hide_cards)

	# Posiciona las cartas y las ajusta
	tween.tween_property(self, "position", _start_position, MOVE_TIME)
	var card_count := cards_pos.size()

	for i in cards_pos.size():
		var card_pos: PathFollow2D = cards_pos[i]
		if card_pos.get_child_count() == 0: continue

		var card = card_pos.get_child(0)
		if not card: continue

		# Posición y tamaño
		var final_pos = float(card_count - i - 1) / max(card_count - 1, 1) if i < card_count else 0
		tween.tween_property(card_pos, "progress_ratio", final_pos, MOVE_TIME)

		# Desactiva las cartas cuando se oculta la baraja o cuando el elemento no coincide
		card.disable_card = hide_cards or current_element and card.element != current_element


## Oculta las cartas
func _set_hidden_cards(is_hidden: bool) -> void:
	# Interpola la curva punto a punto
	var tween := create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	var final_curve := curves["hidden"] if is_hidden else curves["normal"]
	curve = final_curve

	# Establece tamaño y rotación
	for card in get_cards() as Array[Card]:
		var base_scale := Vector2(card_scale, card_scale)
		var final_scale := base_scale if not is_hidden else base_scale * HIDE_SCALE

		tween.tween_property(card, "scale", final_scale, MOVE_TIME)

		# Rotamos al padre para que los comportamientos se mantengan correctos
		tween.tween_property(card, "rotation", PI / 2 if is_hidden else 0.0, MOVE_TIME)


## Obtiene la lista de cartas
func get_cards() -> Array:
	# ? La estructura de la baraja de cartas en el árbol de escenas es:
	# ? - Hand (nodo actual)
	# ?     - PathFollow2D (Posición)
	# ?         - Card (Carta)
	# ?     - ...
	return get_children().map(func(c): return c.get_child(0))
