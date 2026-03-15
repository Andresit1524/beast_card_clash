## Clase abstracta que representa un jugador en jugador en batalla. Uno de ellos representará el
## jugador humano. Está orientado a ser un contenedor de datos/lógica.
class_name Player extends Node


signal deck_updated(new_deck: Array[CardScene.Card])
signal game_over(player: Player)


const MAX_HEALTH := 5
const INITIAL_CARDS := 7
const NAMES := [
	"Osoria",
	"Zarah",
	"Wolfy",
	"Jayfer",
	"Richi",
	"Mov",
	"Osito",
]


## Datos del jugador
var player_name: String = "Jugador"
var team: GameConstants.Teams = GameConstants.Teams.NO_TEAM
var health: int = MAX_HEALTH
var is_bot: bool = true

## Baraja y carta actual (para humanos)
var deck: Array[CardScene.Card]
var current_element: GameConstants.Elements = GameConstants.Elements.NONE
var current_value: int = 1
var hide_card: bool = false


## Elige características al azar para el jugador
func randomize() -> void:
	player_name = NAMES.pick_random()
	team = GameConstants.Teams.values().pick_random()

	# ! Debug
	current_element = GameConstants.Elements.values().pick_random()
	current_value = randi_range(1, 10)


## Crea la baraja de cartas
func create_deck() -> void:
	for i in range(INITIAL_CARDS):
		var new_card = CardScene.Card.new()

		# Elemento de la carta
		while new_card.element == GameConstants.Elements.NONE:
			new_card.element = GameConstants.Elements.values().pick_random()

		new_card.value = randi_range(1, 10)
		deck.append(new_card)

	_update_if_needed()


## Añade una carta a la baraja
func add_card(card: CardScene.Card) -> void:
	deck.append(card)
	_update_if_needed()


## Elimina una carta de la baraja
func remove_card(card: CardScene.Card) -> void:
	deck.erase(card)
	_update_if_needed()


## Juega una carta
func play_card(card: CardScene.Card) -> void:
	if card in deck:
		deck.erase(card)
		_update_if_needed()

	if not deck: game_over.emit(self)


## Aplica daño al jugador
func apply_damage(damage: int) -> void:
	health -= damage

	if health < 0:
		health = 0
		game_over.emit(self)


## Actualiza la baraja si es un jugador humano
func _update_if_needed() -> void:
	if not is_bot: deck_updated.emit(deck)
