## Gestiona la UI del escenario de batalla, que incluye los paneles de los jugadores, la baraja, la
## interfaz de pausa y la interfaz del podium al final de la batalla.
class_name BattleUI extends Control


## Emitida cuando se selecciona una carta de la mano del jugador
signal card_selected(card: Card)


## Mano de las cartas
@onready var hand: Hand = %Hand
## Panel del jugador
@onready var player_panel: PlayerPanel = %PlayerPanel
## Paneles de los bots
@onready var bots_panels: VBoxContainer = %BotsPanels
## Panel de pausa
@onready var pause: Control = %Pause
## Interfaz de fin de juego
@onready var end_ui: EndUI = %End
## Datos de la batalla
@onready var battle_data: BattleData = %BattleData


#region Baraja de cartas


## Activa o desactiva la mano de cartas
func enable_hand(value: bool) -> void:
	hand.hide_cards = not value


## Refresca la baraja de cartas
func set_hand_from_deck(deck: Array[Card]) -> void:
	hand.set_from_deck(deck)

	# Conecta la señal de selección de carta
	for card in hand.get_cards():
		if not card.card_selected.is_connected(card_selected.emit):
			card.card_selected.connect(card_selected.emit)


## Establece el elemento de la baraja actual
func set_hand_element(new_element: Constants.Elements) -> void:
	hand.current_element = new_element


#endregion


#region Paneles de jugadores


## Redistribuye y actualiza los paneles de los jugadores. El primer jugador siempre es el humano
# TODO: automatizar esto. El BattleData ya está disponible
func refresh_player_panels(players_list: Array) -> void:
	var bot_count := 0
	for i in players_list.size():
		var player: Player = players_list[i]
		var current_panel: PlayerPanel

		if not player.is_bot:
			current_panel = player_panel
		else:
			current_panel = bots_panels.get_child(bot_count)
			current_panel.visible = true
			bot_count += 1

		current_panel.player_name = player.player_name
		current_panel.team = player.team
		current_panel.health = player.health
		current_panel.element = player.current_element
		current_panel.value = player.current_value

	_prune_bots_panels(bot_count)


## Oculta los paneles de los bots que no están jugando
func _prune_bots_panels(bot_count: int) -> void:
	if bot_count == bots_panels.get_child_count(): return
	if bot_count > bots_panels.get_child_count() or bot_count < 0:
		push_error("[BattleUI] Cantidad de bots inválida: %s" % bot_count)
		return

	# Oculta los paneles que sobran
	for i in range(bot_count, bots_panels.get_child_count()):
		bots_panels.get_child(i).visible = false


#endregion


#region Pausa y fin de juego


## Acciona o desactiva el menú de pausa
func _pause(value: bool) -> void:
	get_tree().paused = value
	pause.visible = value


## Devuelve el juego a la pantalla de inicio
func _on_back_button_pressed() -> void:
	_pause(false)
	SceneManager.change_to_scene(&"start_menu")


## Continúa la partida
func _on_continue_button_pressed() -> void:
	_pause(false)


## Activa o desactiva la pantalla de final de juego
func enable_end_ui(value: bool) -> void:
	end_ui.ui_visible = value

	# Actualiza el podium
	if value: end_ui.set_podium(battle_data.ranking)


func _unhandled_input(event: InputEvent) -> void:
	# Alterna la pausa con la tecla Esc
	if not event.is_action_pressed("back"): return
	_pause(not get_tree().paused)


#endregion
