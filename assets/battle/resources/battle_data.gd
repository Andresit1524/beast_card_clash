## Nodo que contiene la información de batalla y la propaga por toda la escena para evitar enredos.
## BattleData es la verdad absoluta sobre la información del juego.
class_name BattleData extends Node


const MAX_PLAYERS := 4
const WAIT_TIME := 2.0


## Manager de la batalla. SOLO para acceder a constantes
@export var manager: BattleManager


#region Variables


## Jugador humano
var player: Player

## Lista de jugadores
var players: Array[Player]

## Ranking del juego en formato puesto: jugadores
var ranking: Dictionary[int, Array] = {}


#endregion


#region Variables actuales (current)


## Valor actual del dado
var current_dice_value: int

## Jugador con el turno ectual
var current_turn: Player:
	set(value):
		current_turn = value
		_set_next_turn()

## Jugador con el siguiente turno
var next_turn: Player

## Ranking actual de los jugadores
var current_rank: int = MAX_PLAYERS

## Lista de jugadores que han perdido en espera de ser añadidos al ranking
var queued_ranked_players: Array[Player]


#endregion


#region Funciones


## Añade un jugador
func add_player(_player: Player) -> void:
	if not _player.is_bot: player = _player
	players.append(_player)


## Obtiene la cuenta de jugadores
func get_players_count() -> int:
	return players.size()


## Mezcla los jugadores y establece el primer turno
func shuffle_players() -> void:
	players.shuffle()
	current_turn = players[0]


## Establece el siguiente turno automáticamente cuando se establece el actual
func _set_next_turn() -> void:
	if players.is_empty(): return
	var current_idx := players.find(current_turn)
	var next_turn_pos := (current_idx + 1) % players.size()
	next_turn = players[next_turn_pos]


## Pasa al siguiente turno
func switch_next_turn() -> void:
	current_turn = next_turn


## Añade un jugador a la lista de espera para ser añadido al ranking
func queue_game_over(_player: Player) -> void:
	queued_ranked_players.append(_player)


## Marca a los jugadores en espera como perdidos, los añade al ranking y los elimina de la lista
func apply_game_over() -> void:
	if not queued_ranked_players: return

	print(
		"[BattleData] Jugadores eliminados: %s"
		% [queued_ranked_players.map(func(p: Player): return p.player_name)]
	)

	# Añade a los jugadores al ranking y los quita de la lista de espera
	ranking[current_rank] = queued_ranked_players.duplicate()
	players = players.filter(func(p): return p not in queued_ranked_players)
	# Elimina ahora si a los jugadores
	for _player in queued_ranked_players:
		_player.dissapear()
	queued_ranked_players.clear()

	# Sube el ranking
	current_rank -= 1

	print(
		"[BattleData] Jugadores eliminados: %s"
		% [queued_ranked_players.map(func(p: Player): return p.player_name)]
	)

	# Los jugadores restantes quedan en el primer si ya llegamos a él
	if current_rank != 1: return

	queued_ranked_players = players.duplicate()
	apply_game_over()

	print(
		"[BattleData] Fin de juego. Ganadores: %s"
		% [ranking[1].map(func(p: Player): return p.player_name)]
	)


## Indica si perdimos el juego
func we_lose():
	return not player in players


#endregion
