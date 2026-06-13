## Clase que maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends StateMachine


signal round_handled()


@export_group("Nodos de la escena")
## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI
## Mundo de batalla
@export var battle_world: BattleWorld
## Datos de batalla
@export var battle_data: BattleData


# Estados de batalla
@onready var start: BattleStart = $Start
@onready var turn: BattleTurn = $Turn
@onready var loop: BattleLoop = $Loop
@onready var referee: BattleReferee = $Referee
@onready var end: BattleEnd = $End


func _ready() -> void:
	# Inyectamos la referencia del manager en los estados ANTES de arrancar
	# Esto asegura que el primer estado (BattleStart) ya tenga el manager listo
	for child in get_children():
		if child is BattleState: child.manager = self

	super() # Arranca la máquina de estados (StateMachine)

	# Conecta las señales necesarias
	battle_world.rock_selected.connect(_on_rock_selected)
	battle_ui.card_selected.connect(_on_card_selected)
	battle_world.dice_thrown.connect(set_dice_value)
	battle_world.players_ready.connect(setup_ui)

	# Lanzamiento del dado para el jugador humano
	battle_world.dice_thrown.connect(_decide_dice_thrown)
	turn.enable_dice.connect(battle_world.enable_dice.bind(true))


#region Funciones de Start (configuracion)


## Configura la UI inicialmente
func setup_ui() -> void:
	# Mano
	battle_data.player.deck_updated.connect(battle_ui.set_hand_from_deck)
	battle_ui.set_hand_from_deck(battle_data.player.deck)
	battle_ui.refresh_player_stats(battle_data.players)
	battle_ui.enable_hand(false)

	# Fin de juego
	battle_ui.enable_end_ui(false)


## Configura el mundo de batalla
func setup_world() -> void:
	battle_world.disable_rocks()
	battle_world.enable_dice(false)
	battle_world.set_players(battle_data.players)


#endregion


#region Funciones de Turn


## Decide si resaltar las rocas o no cuando se lanza el dado
func _decide_dice_thrown(number: int) -> void:
	if battle_data.current_turn.is_bot: return

	turn._on_dice_thrown(number)


## Reacciona a la roca seleccionada en el turno del personaje
func _on_rock_selected(selected_rock: Rock) -> void:
	# Si no es el turno de un humano, ignoramos el clic para evitar desincronía
	if battle_data.current_turn.is_bot: return

	battle_world.disable_rocks()
	battle_data.current_turn.move_to(selected_rock.position, selected_rock.rock_index)
	await battle_data.current_turn.moved

	# Si no hay cartas disponibles, salta turno
	var card_choices := battle_data.current_turn.deck.filter(func(v):
		return v.element == selected_rock.element or not selected_rock.element
	)

	if not card_choices:
		# Nos saltamos el turno
		_decide_next_turn()
		return

	# Muestra la baraja
	battle_ui.set_hand_element(selected_rock.element)
	battle_ui.enable_hand(true)


## Reacciona a la carta seleccionada en el turno del humano
func _on_card_selected(selected_card: Card) -> void:
	print(
		"[BattleManager] Carta seleccionada: %s-%s"
		% [Utilities.get_enum_name(selected_card.element, Constants.Elements), selected_card.value]
	)

	# Actualiza al jugador
	battle_data.current_turn.play_card(selected_card)
	battle_data.current_turn.current_element = selected_card.element
	battle_data.current_turn.current_value = selected_card.value

	battle_ui.enable_hand(false)
	battle_ui.refresh_player_stats(battle_data.players)

	# Pasamos el turno
	_decide_next_turn()


#endregion


#region Funciones compartidas y otros


## Almacena el valor del dado cuando se lanza
func set_dice_value(value: int) -> void:
	battle_data.current_dice_value = value


## Decide a que estado delegarle al turno y lo delega
func _decide_next_turn() -> void:
	# Si el siguiente turno es el primero, acabamos la ronda y nos vamos a referee
	if battle_data.next_turn == battle_data.players[0]:
		change_to_state(BattleReferee)
		print("[BattleManager] Fin de la ronda")

		# Esperamos a que el referee emita la señal y continuamos
		await round_handled

	# Seguridad: Si después del referee no quedan jugadores suficientes, abortamos el cambio de turno
	if battle_data.players.size() <= 1: return

	# Pasa el turno
	battle_data.switch_next_turn()

	# Verificamos al jugador que TIENE el turno ahora (current_turn)
	if not battle_data.current_turn.is_bot:
		print("[BattleManager] Turno de %s" % battle_data.current_turn.player_name)
		change_to_state(BattleTurn)
		return

	# Caso contrario, pasa al BattleLoop
	print("[BattleManager] Turno de %s" % battle_data.current_turn.player_name)
	change_to_state(BattleLoop)


## Obtiene la lista de rocas
func get_rocks():
	return battle_world.rocks_list


#endregion
