## Clase que maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends StateMachine


const MAX_PLAYERS := 4


## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI
## Mundo de batalla
@export var battle_world: BattleWorld
## Escena de personaje
@export var player_scene: PackedScene


# Elementos del juego. Todos actúan como atajos
var _player: Player
var _players: Array[Player]


func _ready() -> void:
	battle_world.rock_selected.connect(_on_rock_selected)
	battle_ui.card_selected.connect(_on_card_selected)

	# Importante, para permitir que la máquina de estados arranque
	super()


#region Funciones de Start


## Establece al jugador humano
func setup_player() -> void:
	# Crea el jugador humano
	_player = player_scene.instantiate()
	_player.player_name = PlayerStats.player_name
	_player.team = PlayerStats.team
	_player.is_bot = false
	_player.create_deck()
	_players.append(_player)

	# Mano del jugador
	_player.deck_updated.connect(battle_ui.set_hand_from_deck)


## Establece los bots
func setup_bots() -> void:
	var bots_count := randi_range(1, MAX_PLAYERS - 1)
	for i in range(bots_count):
		var new_bot := player_scene.instantiate()
		new_bot.create_deck()
		new_bot.randomize()
		_players.append(new_bot)

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
	battle_ui.enable_hand(false)
	battle_ui.set_end_ui(false)


## Configura el mundo de batalla
func setup_world() -> void:
	battle_world.enable_dice(false)
	battle_world.set_players(_players)


#endregion


#region Funciones de Turn


## Reacciona a la roca seleccionada en el turno del personaje
func _on_rock_selected(selected_rock: Rock) -> void:
	battle_ui.set_hand_element(selected_rock.element)
	battle_ui.enable_hand(true)


## Reacciona a la carta seleccionada en el turno del personaje
func _on_card_selected(selected_card: Card) -> void:
	print("Carta seleccionada: %s-%s" % [selected_card.element, selected_card.value])

	# Actualiza al jugador
	_player.current_element = selected_card.element
	_player.current_value = selected_card.value

	battle_ui.enable_hand(false)
	battle_ui.refresh_player_stats(_players)

#endregion
