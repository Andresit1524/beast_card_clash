## Clase abstracta que representa un jugador en jugador en batalla. Uno de ellos representará el jugador[br]
## Está orientado a ser un contenedor de datos/lógica.
class_name Player extends Node


signal deck_updated(new_deck: Array[Card])
signal game_over(player: Player)


const MAX_HEALTH := 5
const INITIAL_CARDS := 7


var health := MAX_HEALTH
var is_bot: bool
var deck: Array[Card]


## Crea la baraja de cartas
func create_deck() -> void:
	for i in range(INITIAL_CARDS):
		var new_card = Card.new()

		# Elemento de la carta
		while new_card.element == GameConstants.Elements.NONE:
			new_card.element = GameConstants.Elements.values().pick_random()

		new_card.value = randi_range(1, 10)
		deck.append(new_card)

	_update_if_needed()


## Añade una carta a la baraja
func add_card(card: Card) -> void:
	deck.append(card)
	_update_if_needed()


## Elimina una carta de la baraja
func remove_card(card: Card) -> void:
	deck.erase(card)
	_update_if_needed()


## Juega una carta
func play_card(card: Card) -> void:
	if card in deck:
		deck.erase(card)
		_update_if_needed()

	if not deck: game_over.emit(self )


## Aplica daño al jugador
func apply_damage(damage: int) -> void:
	health -= damage

	if health < 0:
		health = 0
		game_over.emit(self )


## Actualiza la baraja si es un jugador humano
func _update_if_needed() -> void:
	if not is_bot: deck_updated.emit(deck)


## Representacion de una carta
class Card:
	var element: GameConstants.Elements = GameConstants.Elements.NONE
	var value: int:
		set(v):
			if v < 0 or v > 10:
				value = 0
				return

			value = v
