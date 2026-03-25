## Clase que representa un jugador en jugador en batalla, sea bot o humano.
class_name Player extends CharacterBody3D


signal moved()
signal deck_updated(new_deck: Array[CardScene.Card])
signal game_over(player: Player)


# Datos de jugador
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

# Posición y velocidad
const Z_POSITION := 0.3
const MOVE_TIME := 1


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


## Elige características al azar para el jugador
## ! Función temporal
func randomize(for_bot: bool = false) -> void:
	while current_element == GameConstants.Elements.NONE:
		current_element = GameConstants.Elements.values().pick_random()
	current_value = randi_range(1, 10)

	if not for_bot: return

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


#region Movimiento


## Mueve el jugador a la posición indicada
func move_to(new_position: Vector3) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var final_pos := Vector3(new_position.x, Z_POSITION, new_position.z)
	tween.tween_property(self, "position", final_pos, MOVE_TIME)
	tween.tween_callback(func(): moved.emit())


#endregion
