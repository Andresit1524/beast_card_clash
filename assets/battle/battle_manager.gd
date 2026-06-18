## Maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends StateMachine


@export_group("Nodos de la escena")
## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI
## Mundo de batalla
@export var battle_stage: BattleStage
## Datos de batalla
@export var battle_data: BattleData


# Estados de batalla
@onready var turn: BattleTurn = $Turn
@onready var referee: BattleReferee = $Referee


func _ready() -> void:
	# Inyectamos la referencia del manager en los estados ANTES de arrancar
	# Esto asegura que el primer estado (BattleStart) ya tenga el manager listo
	for child in get_children():
		if child is BattleState: child.manager = self

	super() # Arranca la máquina de estados (StateMachine)


#region Funciones de Start (configuracion)


## Configura la UI inicialmente
func setup_ui() -> void:
	# Mano
	battle_data.player.deck_updated.connect(battle_ui.set_hand_from_deck)
	battle_ui.set_hand_from_deck(battle_data.player.deck)
	battle_ui.refresh_player_panels(battle_data.players)
	battle_ui.enable_hand(false)

	# Fin de juego
	battle_ui.enable_end_ui(false)


## Configura el mundo de batalla
func setup_stage() -> void:
	battle_stage.disable_rocks()
	battle_stage.enable_dice(false)
	battle_stage.set_players(battle_data.players)


#endregion


#region Funciones de Turn


## Actualiza los datos sobre el dado y envía el número al BattleTurn si es el caso
func _on_dice_thrown(number: int) -> void:
	battle_data.current_dice_value = number
	if battle_data.current_turn.is_bot: return

	turn.on_dice_thrown(number)


## Reacciona a la roca seleccionada en el turno del personaje
func _on_rock_selected(selected_rock: Rock) -> void:
	# Si no es el turno de un humano, ignoramos el clic para evitar desincronía
	if battle_data.current_turn.is_bot: return

	battle_stage.disable_rocks()
	battle_data.current_turn.move_to(selected_rock.position, selected_rock.rock_index)
	await battle_data.current_turn.moved

	# Si no hay cartas disponibles, salta turno
	var card_choices := battle_data.current_turn.deck.filter(func(c: Card):
		return c.element == selected_rock.element or not selected_rock.element
	)

	if not card_choices:
		# Nos saltamos el turno
		decide_next_or_end()
		return

	# Muestra la baraja
	battle_ui.set_hand_element(selected_rock.element)
	battle_ui.enable_hand(true)


## Reacciona a la carta seleccionada en el turno del humano
func _on_card_selected(selected_card: Card) -> void:
	# Juega y refrezca la interfaz
	battle_data.current_turn.play_card(selected_card)
	battle_ui.enable_hand(false)
	battle_ui.refresh_player_panels(battle_data.players)

	# Pasamos el turno
	decide_next_or_end()


#endregion


#region Funciones compartidas y otros


## Decide a que estado delegarle al turno y lo delega
func decide_next_or_end() -> void:
	# Fin de la ronda, si volvemos al principio
	if battle_data.next_turn == battle_data.players[0]:
		change_to_state(BattleReferee)
		print("[BattleManager] Fin de la ronda")

		# Esperamos a que el referee emita la señal y continuamos
		await referee.round_handled

	# Fin de juego
	if battle_data.players.size() <= 1:
		change_to_state(BattleEnd)
		return

	# Pasa el turno
	battle_data.switch_next_turn()
	print("[BattleManager] Turno de %s" % battle_data.current_turn.player_name)
	change_to_state(BattleTurn if not battle_data.current_turn.is_bot else BattleLoop)


## Obtiene la lista de rocas
func get_rocks() -> Array[Rock]:
	return battle_stage.rocks_list


#endregion
