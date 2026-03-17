## Clase para gestionar la UI del escenario de batalla con referencias centralizadas
class_name BattleUI extends Node


## Nodo que almacena las cartas
@export var hand: Hand
## Panel del jugador
@export var player_panel: PlayerPanel
## Nodo que contiene los paneles de los bots
@export var bots_panels: Array[PlayerPanel]
## Nodo que almacena la lista de rocas
@export var rocks_list: Rocks
## Dado
@export var dice: Dice


func _ready() -> void:
	dice.thrown_dice.connect(func(_number): pass )


## Refresca la baraja de cartas
func set_hand_from_deck(deck) -> void:
	hand.set_from_deck(deck)


## Obtiene la lista de rocas
func get_abstract_rocks_list() -> Array:
	return rocks_list.get_abstract_rocks_list()


## Establece o refresca los datos de la UI del jugador o de un bot [br]
## Índice 0 es el panel del jugador humano, el resto son bots
func refresh_player_stats(players_list: Array) -> void:
	# Establece el panel del jugador
	for i in range(players_list.size()):
		var player: Player = players_list[i]
		var current_player_panel := player_panel if not player.is_bot else bots_panels[i - 1]

		current_player_panel.player_name = player.player_name
		current_player_panel.team = player.team
		current_player_panel.health = player.health
		current_player_panel.element = player.current_element
		current_player_panel.value = player.current_value
		current_player_panel.hide_card = player.hide_card

	_prune_bots_panels(players_list.size() - 1)


## Oculta los paneles de los bots que no están jugando
func _prune_bots_panels(bot_count: int) -> void:
	if bot_count == bots_panels.size(): return
	if bot_count > bots_panels.size() or bot_count < 1:
		push_error("[BattleUI] Cantidad de bots inválida: %s" % bot_count)
		return

	# Recorre los paneles que sobran
	for i in range(bot_count, bots_panels.size()):
		bots_panels[i].visible = false
