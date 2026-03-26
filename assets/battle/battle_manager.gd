## Clase que maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends StateMachine


signal player_turn_ended()
signal round_handled()


const MAX_PLAYERS := 4
const WAIT_TIME := 2


## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI
## Mundo de batalla
@export var battle_world: BattleWorld
## Escena de personaje
@export var player_scene: PackedScene


# Elementos del juego. Todos actúan como atajos
var player: Player
var players: Array[Player]

# Datos temporales
var current_turn: Player
var current_dice_value: int


func _ready() -> void:
	# Inyectamos la referencia del manager en los estados ANTES de arrancar
	# Esto asegura que el primer estado (BattleStart) ya tenga el manager listo
	for child in get_children():
		if child is BattleState:
			child.manager = self

	super() # Arranca la máquina de estados (StateMachine)

	# Conecta las señales necesarias
	battle_world.rock_selected.connect(_on_rock_selected)
	battle_ui.card_selected.connect(_on_card_selected)
	battle_world.dice_thrown.connect(set_dice_value)
	battle_world.players_ready.connect(setup_ui)


#region Funciones de Start


## Establece al jugador humano
func setup_player() -> void:
	# Crea el jugador humano
	player = player_scene.instantiate()
	player.player_name = PlayerStats.player_name
	player.team = PlayerStats.team
	player.is_bot = false
	player.create_deck()
	players.append(player)

	# Mano del jugador
	player.deck_updated.connect(battle_ui.set_hand_from_deck)


## Establece los bots
func setup_bots() -> void:
	var bots_count := randi_range(1, MAX_PLAYERS - 1)
	for i in range(bots_count):
		var new_bot := player_scene.instantiate()
		new_bot.create_deck()
		new_bot.randomize()
		players.append(new_bot)

		print("[BattleManager] Nuevo bot creado: %s!" % new_bot.player_name)

	# Mezcla a los jugadores y pone el primer turno
	players.shuffle()
	print(
		"[BattleManager] %s jugadores en juego: %s"
		% [bots_count + 1, players.map(func(p): return p.player_name)]
	)
	current_turn = players[0]


## Configura la UI inicialmente
func setup_ui() -> void:
	battle_ui.refresh_player_stats(players)
	battle_ui.set_hand_from_deck(player.deck)
	battle_ui.enable_hand(false)
	battle_ui.set_end_ui(false)


## Configura el mundo de batalla
func setup_world() -> void:
	battle_world.disable_rocks()
	battle_world.enable_dice(false)
	battle_world.set_players(players)


#endregion


#region Funciones de Turn


## Reacciona a la roca seleccionada en el turno del personaje
func _on_rock_selected(selected_rock: Rock) -> void:
	battle_world.disable_rocks()
	player.move_to(selected_rock.position, selected_rock.rock_index)
	await player.moved

	# Si no hay cartas disponibles, salta turno
	var card_choices := player.deck.filter(func(v):
		return v.element == selected_rock.element or not selected_rock.element
	)

	if not card_choices:
		switch_next_turn_state()
		return

	# Muestra la baraja
	battle_ui.set_hand_element(selected_rock.element)
	battle_ui.enable_hand(true)


## Reacciona a la carta seleccionada en el turno del humano
func _on_card_selected(selected_card: Card) -> void:
	print(
		"[BattleManager] Carta seleccionada: %s-%s"
		% [Utilities.get_enum_name(selected_card.element, GameConstants.Elements), selected_card.value]
	)

	# Actualiza al jugador
	player.play_card(selected_card)
	player.current_element = selected_card.element
	player.current_value = selected_card.value

	battle_ui.enable_hand(false)
	battle_ui.refresh_player_stats(players)
	player_turn_ended.emit()


#endregion


#region Funciones compartidas y otros


## Almacena el valor del dado cuando se lanza
func set_dice_value(value: int) -> void:
	current_dice_value = value


## Decide a que estado delegarle al turno y lo delega
func switch_next_turn_state() -> void:
	# Calculamos la siguiente posición de forma circular
	var next_turn_pos := (players.find(current_turn) + 1) % players.size()

	# Si el siguiente turno es el primero, acabamos la ronda y nos vamos a referee
	if next_turn_pos == 0:
		change_to_state(BattleReferee)
		print("[BattleManager] Fin de la ronda")

		# Esperamos a que el referee emita la señal y continuamos
		await round_handled

	# Jugador humano: pasa al turno del humano
	if not players[next_turn_pos].is_bot:
		current_turn = players[next_turn_pos]
		print("[BattleManager] Turno de %s" % current_turn.player_name)
		change_to_state(BattleTurn)
		return

	# Caso contrario, pasa al siguiente bot
	current_turn = players[next_turn_pos]
	print("[BattleManager] Turno de %s" % current_turn.player_name)
	change_to_state(BattleLoop)


## Obtiene la lista de rocas
func get_rocks():
	return battle_world.rocks_list


#endregion
