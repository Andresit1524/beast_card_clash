## Clase que maneja el funcionamiento de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends Node


const MAX_PLAYERS := 4


## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI


var player: Player
var players: Array[Player]
var rocks: Array[RockScene.Rock]


func _ready() -> void:
	_set_players_data()


## Establece al jugador y los bots
func _set_players_data() -> void:
	# Crea el jugador humano
	player = Player.new()
	player.is_bot = false
	player.create_deck()
	players.append(player)

	# ! Debug
	player.randomize()

	# Establece los datos del jugador desde el singleton
	player.player_name = PlayerStats.player_name
	player.team = PlayerStats.team

	# Mano del jugador
	player.deck_updated.connect(battle_ui.set_hand_from_deck)
	battle_ui.set_hand_from_deck(player.deck)

	# Bots
	var bots_count := randi_range(1, MAX_PLAYERS - 1)
	for i in range(bots_count):
		var new_bot := Player.new()
		new_bot.create_deck()
		new_bot.randomize()
		new_bot.is_bot = true
		print_debug("[BattleManager] New bot: %s!" % new_bot.player_name)
		players.append(new_bot)

	# Establece la UI
	for i in range(players.size()):
		battle_ui.refresh_player_stats(players)


## Establece las rocas del escenario
func _set_rocks() -> void:
	rocks = battle_ui.get_abstract_rocks_list()
