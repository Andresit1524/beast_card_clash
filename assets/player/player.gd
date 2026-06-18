## Representa un jugador en jugador en batalla, sea bot o humano.
class_name Player extends Node3D


## Se emite cuando el jugador termina de moverse hacia una roca
signal moved
## Se emite para actualizar la baraja
signal deck_updated(new_deck: Array[Card])
## Se emite cuando el jugador muere enviando su referencia al manager
signal game_over(player: Player)


# Posición y velocidad
const Z_POSITION := 0.3
const MOVE_TIME := 1.0


## Escena de carta
@export var card_scene: PackedScene


@onready var sprite: AnimatedSprite3D = $AnimatedSprite


# Datos del jugador
var player_name: String = Constants.NAMES.pick_random()
var team: Constants.Teams = Constants.Teams.values().pick_random()
var health: int = Constants.MAX_HEALTH
var is_bot: bool = true

# Baraja y carta actual (para humanos)
var deck: Array[Card]
var current_element: Constants.Elements = Constants.Elements.NONE
var current_value: int = 1
var hide_card: bool = false

# Posición
var current_rock_index: int


func _ready() -> void:
	# Si somos humanos, ponemos un color diferente
	# ! Temporal
	if not is_bot: sprite.modulate = Color.SKY_BLUE


#region Baraja


## Crea la baraja de cartas
func create_deck() -> void:
	for i in Constants.INITIAL_CARDS:
		var new_card_element := Constants.get_random_valid_element()
		var new_card: Card = card_scene.instantiate()

		new_card.element = new_card_element
		new_card.value = randi_range(1, 10)
		deck.append(new_card)

	if not is_bot: deck_updated.emit(deck)


## Juega una carta y la retorna
func play_card(card: Card) -> Card:
	if not card in deck: push_error("Carta no encontrada")

	# Procesa la carta
	current_element = card.element
	current_value = card.value
	deck.erase(card)

	# Añade una nueva carta al azar para reponer
	var new_card_element := Constants.get_random_valid_element()
	var new_card = card_scene.instantiate()

	new_card.element = new_card_element
	new_card.value = randi_range(1, Constants.MAX_CARD_VALUE)
	deck.append(new_card)

	if not is_bot: deck_updated.emit(deck)
	return card


## Resetea la elección del jugador
func reset_choice() -> void:
	current_element = Constants.Elements.NONE
	current_value = 0


#endregion


#region Batalla


## Aplica daño al jugador
func apply_damage(damage: int = 1) -> void:
	print("[Player] Daño aplicado: %s - %s = %s" % [health, damage, health - damage])
	health -= damage

	if health <= 0:
		health = 0
		game_over.emit(self)


## Desvanece y elimina al jugador
func dissapear() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, ^"modulate", Color.TRANSPARENT, 1.0)
	tween.tween_callback(queue_free)


#endregion


#region Movimiento


## Mueve el jugador a la posición indicada y actualiza su indice a la vez
# TODO: ¿Se puede unificar para que solo pida el índice? A1
func move_to(new_position: Vector3, new_index: int) -> void:
	current_rock_index = new_index

	var final_pos := Vector3(new_position.x, Z_POSITION, new_position.z)
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, ^"position", final_pos, MOVE_TIME)
	tween.tween_callback(moved.emit)


#endregion
