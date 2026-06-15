## Clase que almacena los elementos del mundo 3D, de forma diferida al mundo de la interfaz 2D
class_name BattleStage extends Node3D


## Indica que las rocas están listas para que los jugadores se ubiquen en ellas
signal _rocks_ready()
## Se emite cuando una roca es seleccionada, y envía la referencia de la misma
signal rock_selected(rock: Rock)


## Nodo del dado
@export var dice: Dice
## Nodo que contiene a las rocas
@export var rocks: Rocks
## Nodo que contiene a los jugadores
@export var players: Players
## Datos de batalla
@export var battle_data: BattleData


## Lista de referencias a las rocas
var rocks_list: Array[Rock]


func _ready() -> void:
	_set_rocks()


#region Funciones del dado


## Lanza el dado. Destinado a lanzamientos automáticos (como los de los bots)
func throw_dice() -> void:
	dice.throw_dice()


## Activa o desactiva el dado
func enable_dice(enabled: bool) -> void:
	dice.clickable = enabled


#endregion


#region Funciones de las rocas


## Accede a las rocas y las agrega a la lista
func _set_rocks() -> void:
	# Filtra las rocas y se conecta a cada una
	rocks_list.assign(rocks.get_children().filter(func(c): return c is Rock))
	for rock in rocks_list:
		rock.rock_selected.connect(rock_selected.emit)

	if rocks.get_child_count() == rocks.ROCK_COUNT:
		_rocks_ready.emit()
		return


## Activa las rocas dada la lista de índices
func enable_rocks(index_list: Array) -> void:
	for i in index_list:
		rocks_list[i].selectable = true


## Desactiva todas las rocas
func disable_rocks() -> void:
	if not is_node_ready(): await ready
	for rock in rocks_list:
		rock.selectable = false


#endregion


#region Funciones de los jugadores


## Establece a los jugadores, definidos desde afuera
func set_players(new_players: Array[Player]) -> void:
	battle_data.players = new_players
	players.add_players(new_players)
	await _rocks_ready

	# Posiciona a los jugadores en rocas igualmente espaciadas
	for i in battle_data.get_players_count():
		var current_player := battle_data.players[i]

		# Usamos una referencia aparte para el jugador humano
		if not current_player.is_bot: battle_data.player = current_player

		# Calculamos la posición y ubicamos
		var position_idx := int((float(i) / battle_data.players.size()) * rocks_list.size())
		current_player.move_to(rocks_list[position_idx].position, position_idx)

		print("[Stage] %s en índice %s" % [current_player.player_name, position_idx])


#endregion
