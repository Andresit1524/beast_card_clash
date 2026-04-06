## Clase que representa un jugador en jugador en batalla, sea bot o humano.
class_name Player extends CharacterBody3D


signal moved()
signal deck_updated(new_deck: Array[Card])
signal game_over(player: Player)


# Datos de jugador
const MAX_HEALTH := 5
const INITIAL_CARDS := 9
const NAMES := [
	"Ana La Rana",
	"Andrew",
	"Arturo",
	"Barry",
	"Bartolome",
	"Beth",
	"Bianca",
	"Búho Sensei - Nacho",
	"Carlos Jimenez",
	"Carmen",
	"Chepe García",
	"Cristal",
	"Don Poncho",
	"Dorothy",
	"Doru",
	"Eliel Picoalto",
	"Fabio Aguilar",
	"Guacharaco",
	"Juan Orca",
	"Keneth",
	"Manchas",
	"Maria",
	"Marjane",
	"Matt Cougar",
	"Mr Bear",
	"Nairo “El Andino”",
	"Osorio P",
	"Ramón",
	"Teddy",
	"Thiago",
	"Thomas",
	"Titi",
	"Walter Mendoza",
	"Wolfy",
	"Zarah",
]

# Posición y velocidad
const Z_POSITION := 0.3
const MOVE_TIME := 1


## Mano del jugador
@export var hand: Hand
## Escena de carta
@export var card_scene: PackedScene


# Datos del jugador
var player_name: String
var team: GameConstants.Teams = GameConstants.Teams.NO_TEAM
var health: int = MAX_HEALTH
var is_bot: bool = true

# Baraja y carta actual (para humanos)
var deck: Array[Card]
var current_element: GameConstants.Elements = GameConstants.Elements.NONE
var current_value: int = 1
var hide_card: bool = false

# Posición
var current_rock_index: int


#region Datos


## Elige características al azar para un bot
## ! Función (posiblemente) temporal
func randomize() -> void:
	# Si no es bot, randomizamos todos los elementos
	player_name = NAMES.pick_random()
	team = GameConstants.Teams.values().pick_random()


## Crea la baraja de cartas
func create_deck() -> void:
	for i in range(INITIAL_CARDS):
		# Elemento de la carta
		var new_card_element := GameConstants.Elements.NONE
		while new_card_element == GameConstants.Elements.NONE:
			new_card_element = GameConstants.Elements.values().pick_random()

		var new_card: Card = card_scene.instantiate()
		new_card.element = new_card_element
		new_card.value = randi_range(1, 10)
		deck.append(new_card)

	_update_deck_if_needed()


#endregion


#region Baraja


## Añade una carta a la baraja
func add_card(card: Card) -> void:
	deck.append(card)
	_update_deck_if_needed()


## Elimina una carta de la baraja
func remove_card(card: Card) -> void:
	deck.erase(card)
	_update_deck_if_needed()


## Juega una carta y la retorna. Retorna null si no hay más cartas
func play_card(card: Card = null) -> Card:
	# Si no hay carta, elige al azar
	if not card: card = deck.pick_random()

	# Busca y elimina la carta
	if card in deck: deck.erase(card)

	# Añade una nueva carta al azar
	var new_card_element := GameConstants.Elements.NONE
	while not new_card_element:
		new_card_element = GameConstants.Elements.values().pick_random()
	var new_card_value := randi_range(1, 10)
	var new_card = card_scene.instantiate()
	new_card.element = new_card_element
	new_card.value = new_card_value
	deck.append(new_card)
	print(
		"[Player] Nueva carta añadida: %s-%s"
		% [Utilities.get_enum_name(new_card.element, GameConstants.Elements), new_card.value]
	)

	_update_deck_if_needed()

	# Muere si no hay más cartas
	if not deck: game_over.emit(self)
	return card


## Actualiza la baraja si es un jugador humano
func _update_deck_if_needed() -> void:
	if not is_bot: deck_updated.emit(deck)


#endregion


#region Batalla


## Aplica daño al jugador
func apply_damage(damage: int) -> void:
	print("[Player] Daño aplicado: %s - %s" % [health, damage])
	health -= damage

	if health < 0:
		health = 0
		game_over.emit(self)


#endregion


#region Movimiento


## Mueve el jugador a la posición indicada y actualiza su indice a la vez
func move_to(new_position: Vector3, new_index: int) -> void:
	# Actualiza la posición
	current_rock_index = new_index

	# Mueve el jugador
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var final_pos := Vector3(new_position.x, Z_POSITION, new_position.z)
	tween.tween_property(self, "position", final_pos, MOVE_TIME)
	tween.tween_callback(func(): moved.emit())


#endregion
