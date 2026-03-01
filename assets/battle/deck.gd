extends Path2D

@export var card_scene: PackedScene
@export var card_scale: float = 0.5
@export var card_count := 7

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

	# Crea 7 cartas
	for i in range(card_count):
		print("Card %s!" % i)
		var new_card_position = PathFollow2D.new()
		var new_card = card_scene.instantiate()

		# Elemento y valor de la carta al azar
		while new_card.element == GameConstants.Elements.NONE:
			new_card.element = GameConstants.Elements.values()[rng.randi_range(0, GameConstants.Elements.size() - 1)]

		new_card.value = rng.randi_range(1, 10)

		# Adición al árbol de escena
		new_card_position.name = "CardPosition%s" % i
		new_card_position.add_child(new_card)
		add_child(new_card_position, true)

func _process(_delta) -> void:
	_refresh_cards()

## Actualiza las características de las cartas
func _refresh_cards() -> void:
	var cards_position_list = get_children()
	for i in range(card_count):
		var current_card_position: PathFollow2D = cards_position_list[i]
		var current_card: Node2D = current_card_position.get_children()[0]

		# Actualiza la escala y posición de la carta
		current_card.scale = Vector2(card_scale, card_scale)
		current_card_position.progress_ratio = float(card_count - i - 1) / max(card_count - 1, 1)
