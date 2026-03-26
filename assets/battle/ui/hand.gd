class_name Hand extends Path2D


const HIDE_OFFSET := Vector2(0, 300)
const MOVE_TIME := 0.2


## Escena de la carta para instanciarla
@export var card_scene: PackedScene
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
@export var current_element: GameConstants.Elements = GameConstants.Elements.NONE:
	set(value):
		current_element = value
		_refresh_cards()


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
		print_debug("[Hand] Carta actualizada: %s_%s" % [card.element, card.value])

		new_card_pos.add_child(card)

	_refresh_cards()


## Actualiza las cartas a los nuevos valores de posición y escala
func _refresh_cards() -> void:
	var cards_pos := get_children()
	if cards_pos.is_empty(): return

	var tween := create_tween()
	tween.set_parallel().set_trans(Tween.TRANS_SINE)

	# Oculta la baraja
	if hide_cards:
		tween.tween_property(self, "position", position + HIDE_OFFSET, MOVE_TIME)
		return

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
		card.scale = Vector2(card_scale, card_scale)

		# Desactiva las cartas que no son del elemento actual
		if current_element != GameConstants.Elements.NONE:
			card.disable_card = card.element != current_element
		else:
			card.disable_card = false


## Obtiene la lista de cartas
func get_cards() -> Array:
	var cards := []

	# ? La estructura de la baraja de cartas en el árbol de escenas es:
	# ? - Hand (nodo actual)
	# ?     - PathFollow2D (Posición)
	# ?         - Card (Carta)
	# ?     - ...
	for card_pos in get_children():
		cards.append(card_pos.get_child(0))

	return cards
