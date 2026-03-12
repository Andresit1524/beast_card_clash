## Clase que maneja el funcionamiento de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends Node


const MAX_PLAYERS := 4


## Nodo que almacena las cartas
@export var hand: Hand
## Panel del jugador
@export var player_panel: PanelContainer
## Nodo que contiene los paneles de los bots
@export var bots_panels: Node


var player: Player
var players: Array[Player]


func _ready() -> void:
	_set_players()


## Establece al jugador y los bots
func _set_players():
	# Humano
	player = Player.new()
	player.is_bot = false
	player.create_deck()
	hand.set_from_deck(player.deck)
	player.deck_updated.connect(hand.set_from_deck)

	# Bots
	var bots_count := randi_range(1, MAX_PLAYERS - 1)
	for i in range(bots_count):
		print_debug("New bot %s!" % i)
		var new_bot := Player.new()
		new_bot.is_bot = true
		players.append(new_bot)
