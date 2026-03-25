## Clase que maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends StateMachine


const MAX_PLAYERS := 4


## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI
## Mundo de batalla
@export var battle_world: BattleWorld
## Escena de personaje
@export var player_scene: PackedScene


# Elementos del juego. Son todos referencias por lo que actúan como atajos
var _player: Player
var _players: Array[Player]


#region Funciones de arranque


## Establece al jugador humano
func setup_player() -> void:
	# Crea el jugador humano
	_player = player_scene.instantiate()
	_player.player_name = PlayerStats.player_name
	_player.team = PlayerStats.team
	_player.is_bot = false
	_player.create_deck()
	_players.append(_player)

	# ! Temporal
	_player.randomize(false)

	# Mano del jugador
	_player.deck_updated.connect(battle_ui.set_hand_from_deck)


## Establece los bots
func setup_bots() -> void:
	var bots_count := randi_range(1, MAX_PLAYERS - 1)
	for i in range(bots_count):
		var new_bot := player_scene.instantiate()
		new_bot.create_deck()
		_players.append(new_bot)

		# ! Temporal
		new_bot.randomize(true)

		print("[BattleManager] Nuevo bot creado: %s!" % new_bot.player_name)

	# Establece la UI
	_players.shuffle()
	print(
		"[BattleManager] %s jugadores en juego: %s"
		% [bots_count + 1, _players.map(func(p): return p.player_name)]
	)


## Configura la UI inicialmente
func setup_ui() -> void:
	battle_ui.refresh_player_stats(_players)
	battle_ui.set_hand_from_deck(_player.deck)
	battle_ui.set_end_ui(false)


## Configura el mundo de batalla
func setup_world() -> void:
	battle_world.enable_dice(false)
	battle_world.set_players(_players)


#endregion
