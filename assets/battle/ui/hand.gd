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
	# Elimina a todas las cartas actuales
	for card in get_children():
		card.queue_free()

	# Crea las cartas nuevas
	var size := deck.size() if deck else Player.INITIAL_CARDS
	for i in range(size):
		var new_card_pos := PathFollow2D.new()
		var new_card: Card = card_scene.instantiate()

		# Ajusta la carta
		var new_element = deck[i].element if deck else GameConstants.Elements.NONE
		var new_value = deck[i].value if deck else 1

		new_card.set_properties({
			"element": new_element,
			"value": new_value,
			"hide_card": false,
		})
		# print_debug("[Hand] Carta creada: %s_%s" % [new_card.element, new_card.value])

		new_card_pos.add_child(new_card)
		add_child(new_card_pos)

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
		var card: Control = card_pos.get_child(0)

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
