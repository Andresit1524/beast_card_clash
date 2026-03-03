extends Path2D


## Escena de la carta para instanciarla
@export var card_scene: PackedScene
## Tamaño de la carta
@export var card_scale: float = 0.25:
	set(value):
		card_scale = value
		refresh_cards()
## Cantidad de cartas en la mano
@export var card_count: int = 7:
	set(value):
		card_count = value
		refresh_cards()
## Roca del jugador actual. Luego será variable interna
@export var current_rock: GameConstants.Elements = GameConstants.Elements.NONE:
	set(value):
		current_rock = value
		refresh_cards()


var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()

	# Crea las cartas
	for i in range(card_count):
		var new_card_pos := PathFollow2D.new()
		var new_card = card_scene.instantiate()

		# Establece los elementos y valores de las cartas
		var new_element: GameConstants.Elements

		# NONE significa 0 y el elemento empieza en null
		# Entonces este bucle evita que se eliga el elemento NONE
		@warning_ignore("unassigned_variable")
		while not new_element:
			new_element = GameConstants.Elements.values()[randi() % GameConstants.Elements.size()]

		new_card.set_properties({
			"element": new_element,
			"value": randi_range(1, 10),
			"hide_card": false,
		})

		print_debug("Carta creada: %s_%s" % [new_card.element, new_card.value])

		new_card_pos.add_child(new_card)
		add_child(new_card_pos)

	refresh_cards()


## Actualiza las cartas a los nuevos valores
func refresh_cards() -> void:
	var cards_pos := get_children()
	if cards_pos.is_empty(): return

	var tween := create_tween().set_parallel()

	for i in cards_pos.size():
		var card_pos: PathFollow2D = cards_pos[i]
		var card: Control = card_pos.get_child(0)

		# Posición y tamaño
		var final_pos = float(card_count - i - 1) / max(card_count - 1, 1) if i < card_count else 0
		tween.tween_property(card_pos, "progress_ratio", final_pos, 0.2)
		card.scale = Vector2(card_scale, card_scale)

		# Desactiva las cartas que no son del elemento actual
		card.disable_card = card.element != current_rock
