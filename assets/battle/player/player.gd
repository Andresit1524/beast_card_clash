## Clase abstracta que representa un jugador en jugador en batalla. Uno de ellos representará el
## jugador humano. Está orientado a ser un contenedor de datos/lógica.
class_name Player extends CharacterBody3D


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
var player_name: String
var team: GameConstants.Teams = GameConstants.Teams.NO_TEAM
var health: int = MAX_HEALTH
var is_bot: bool = true

## Baraja y carta actual (para humanos)
var deck: Array[CardScene.Card]
var current_element: GameConstants.Elements = GameConstants.Elements.NONE
var current_value: int = 1
var hide_card: bool = false


#region Datos


# Inicializa al jugador. Usa un string vacío en el nombre para hacerlo aleatorio
func _init(new_name: String = "", new_team := GameConstants.Teams.NO_TEAM, bot: bool = true) -> void:
	player_name = new_name if new_name else NAMES.pick_random()
	team = new_team if new_team else GameConstants.Teams.values().pick_random()
	is_bot = bot


## Elige características al azar para el jugador
## ! Función temporal
func randomize() -> void:
	while current_element == GameConstants.Elements.NONE:
		current_element = GameConstants.Elements.values().pick_random()
	current_value = randi_range(1, 10)


## Crea la baraja de cartas
func create_deck() -> void:
	for i in range(INITIAL_CARDS):
		# Elemento de la carta
		var new_card_element := GameConstants.Elements.NONE
		while new_card_element == GameConstants.Elements.NONE:
			new_card_element = GameConstants.Elements.values().pick_random()

		var new_card = CardScene.Card.new(new_card_element, randi_range(1, 10))
		deck.append(new_card)

	_update_deck_if_needed()


#endregion


#region Baraja


## Añade una carta a la baraja
func add_card(card: CardScene.Card) -> void:
	deck.append(card)
	_update_deck_if_needed()


## Elimina una carta de la baraja
func remove_card(card: CardScene.Card) -> void:
	deck.erase(card)
	_update_deck_if_needed()


## Juega una carta
func play_card(card: CardScene.Card) -> void:
	if card in deck:
		deck.erase(card)
		_update_deck_if_needed()

	if not deck: game_over.emit(self)


## Actualiza la baraja si es un jugador humano
func _update_deck_if_needed() -> void:
	if not is_bot: deck_updated.emit(deck)


#endregion


#region Batalla


## Aplica daño al jugador
func apply_damage(damage: int) -> void:
	health -= damage

	if health < 0:
		health = 0
		game_over.emit(self)


#endregion
