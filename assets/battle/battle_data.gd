## Nodo que contiene la información de batalla y la propaga por toda la escena para evitar enredos.
## BattleData es la verdad absoluta sobre la información del juego.
class_name BattleData extends Node


const MAX_PLAYERS := 4
const WAIT_TIME := 2.0


## Jugador humano
var player: Player
## Lista de jugadores
var players: Array[Player]
## Ranking del juego en formato puesto: jugadores
var ranking: Array[Array]


#region Variables de estado actual


## Valor actual del dado
var current_dice_value: int

## Jugador con el turno ectual
var current_turn: Player:
	set(value):
		current_turn = value
		_set_next_turn()

## Jugador con el siguiente turno
var next_turn: Player

## Lista de jugadores que han perdido en espera de ser añadidos al ranking
var queued_ranked_players: Array[Player]


#endregion


#region Funciones de la lista de jugadores


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


#endregion


#region Funciones para decidir el siguiente turno


## Establece el siguiente turno automáticamente cuando se establece el actual
func _set_next_turn() -> void:
	if players.is_empty(): return

	# Verificamos si el turno actual sigue siendo válido y está en la lista de jugadores activos
	var current_idx: int
	if is_instance_valid(current_turn): current_idx = players.find(current_turn)

	# Si el jugador no está en la lista (murió o fue eliminado), el siguiente turno
	# por defecto es el primero disponible para iniciar la nueva ronda.
	if current_idx == -1:
		next_turn = players[0]
		return

	var next_turn_pos := (current_idx + 1) % players.size()
	next_turn = players[next_turn_pos]


## Pasa al siguiente turno.
## El siguiente turno del siguiente se pone automáticamente al establecer el actual
func switch_next_turn() -> void:
	current_turn = next_turn


#endregion


#region Funciones de fin de juego


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
	var snapshot: Array[Snapshot] = []
	for _player in queued_ranked_players:
		snapshot.append(Snapshot.new(_player.player_name, _player.team))

	ranking.push_front(snapshot)
	players = players.filter(func(p): return p not in queued_ranked_players)
	# Elimina ahora si a los jugadores
	for _player in queued_ranked_players:
		_player.dissapear()
	queued_ranked_players.clear()

	# Actualizamos el puntero al siguiente turno porque la lista de jugadores cambió
	_set_next_turn()

	# Si solo queda un jugador (el ganador), lo añadimos al ranking automáticamente
	if players.size() == 1:
		queued_ranked_players = players.duplicate()
		apply_game_over()
		return

	if players.is_empty():
		print(
			"[BattleData] Fin de juego. Ganadores: %s"
			% [ranking[0].map(func(p): return p.name)]
		)


## Indica si perdimos el juego
func we_lose():
	return not player in players


## Crea un podio artificial para los jugadores restantes
func lose_remaining() -> void:
	while not players.is_empty():
		print(
			"[BattleData] Daño sobre: %s. Perdedores: %s"
			% [
				players.map(func(p: Player): return "%s: %s, " % [p.player_name, p.health]),
				queued_ranked_players.map(func(p: Player): return "%s: %s, " % [p.player_name, p.health])
			]
		)
		for _player in players:
			_player.apply_damage()

		apply_game_over()


## Clase que almacena los datos de un jugador de manera ligera y segura
class Snapshot:
	var name: String
	var team: Constants.Teams

	func _init(new_name: String, new_team: Constants.Teams) -> void:
		name = new_name
		team = new_team

	func _to_string() -> String:
		return (
			"[Nombre: %s, Equipo: %s]"
			% [name, Utilities.get_enum_name(team, Constants.Teams)]
		)


#endregion
