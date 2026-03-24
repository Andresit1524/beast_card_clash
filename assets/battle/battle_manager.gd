## Clase que maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends StateMachine


const MAX_PLAYERS := 4


## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI
## Mundo de batalla
@export var battle_world: BattleWorld

var player: Player
var players: Array[Player]
var rocks: Array[RockScene.Rock]


#region Funciones de arranque


## Establece al jugador humano
func setup_player() -> void:
	# Crea el jugador humano
	player = Player.new(PlayerStats.player_name, PlayerStats.team, false)
	player.create_deck()
	players.append(player)

	# ! Temporal
	player.randomize()

	# Mano del jugador
	player.deck_updated.connect(battle_ui.set_hand_from_deck)


## Establece los bots
func setup_bots() -> void:
	var bots_count := randi_range(1, MAX_PLAYERS - 1)
	for i in range(bots_count):
		var new_bot := Player.new()
		new_bot.create_deck()
		players.append(new_bot)
		print_debug("[BattleManager] Nuevo bot creado: %s!" % new_bot.player_name)

		# ! Temporal
		new_bot.randomize()

	# Establece la UI
	print_debug("[BattleManager] %s jugadores en juego" % bots_count)


## Configura la UI inicialmente
func setup_ui() -> void:
	battle_world.set_dice(false)
	battle_ui.refresh_player_stats(players)
	battle_ui.set_hand_from_deck(player.deck)
	battle_ui.set_end_ui(false)


#endregion
