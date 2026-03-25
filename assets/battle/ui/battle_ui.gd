## Clase para gestionar la UI del escenario de batalla con referencias centralizadas
class_name BattleUI extends Node


signal card_selected(card: Card)


## Nodo que almacena las cartas
@onready var hand: Hand = %Hand
## Panel del jugador
@onready var player_panel: PlayerPanel = %PlayerPanel
## Nodo que contiene los paneles de los bots
@onready var bots_panels: VBoxContainer = %BotsPanels
## Nodo de la interfaz de fin de juego
@onready var end_ui: EndUI = %EndUI


#region Baraja de cartas


## Activa o desactiva la mano de cartas
func enable_hand(enabled: bool) -> void:
	hand.hide_cards = not enabled


## Refresca la baraja de cartas
func set_hand_from_deck(deck: Array[Card]) -> void:
	hand.set_from_deck(deck)
	for card in hand.get_cards():
		card.card_selected.connect(func(c): card_selected.emit(c))


## Establece el elemento de la baraja actual
func set_hand_element(new_element: GameConstants.Elements) -> void:
	hand.current_element = new_element


#endregion


#region Paneles de jugadores


## Establece o refresca los datos de la UI del jugador o de un bot [br]
## Índice 0 es el panel del jugador humano, el resto son bots
func refresh_player_stats(players_list: Array) -> void:
	var bot_ui_index := 0

	for i in range(players_list.size()):
		var player: Player = players_list[i]
		var current_player_panel: PlayerPanel

		if not player.is_bot:
			current_player_panel = player_panel
		else:
			current_player_panel = bots_panels.get_child(bot_ui_index)
			bot_ui_index += 1
			current_player_panel.visible = true

		current_player_panel.player_name = player.player_name
		current_player_panel.team = player.team
		current_player_panel.health = player.health
		current_player_panel.element = player.current_element
		current_player_panel.value = player.current_value
		current_player_panel.hide_card = player.hide_card

	_prune_bots_panels(bot_ui_index)


## Oculta los paneles de los bots que no están jugando
func _prune_bots_panels(bot_count: int) -> void:
	if bot_count == bots_panels.get_child_count(): return
	if bot_count > bots_panels.get_child_count() or bot_count < 0:
		push_error("[BattleUI] Cantidad de bots inválida: %s" % bot_count)
		return

	# Recorre los paneles que sobran
	for i in range(bot_count, bots_panels.get_child_count()):
		bots_panels.get_child(i).visible = false


#endregion


#region Interfaz de fin de juego


## Activa o desactiva la pantalla de final de juego
func set_end_ui(set_visible: bool) -> void:
	end_ui.ui_visible = set_visible


#endregion
