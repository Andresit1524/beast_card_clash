## Clase que almacena los elementos del mundo 3D, de forma diferida al mundo de la interfaz 2D
class_name BattleWorld extends Node3D


signal dice_thrown(number: int)
signal rock_selected(rock: Rock)
signal players_ready()
signal _rocks_ready()


## Nodo del dado
@export var dice: Dice
## Nodo que contiene a las rocas
@export var rocks: Rocks
## Nodo que contiene a los jugadores
@export var players: Players
## Datos de batalla
@export var battle_data: BattleData


# var player: Player
# var players_list: Array[Player] = []
var rocks_list: Array[Rock] = []


func _ready() -> void:
	_set_rocks()
	players.players_game_over.connect(battle_data.queue_game_over)


#region Funciones del dado


## Lanza el dado. Destinado a lanzamientos automáticos (como los de los bots)
func throw_dice() -> void:
	dice.throw_dice()


## Activa o desactiva el dado
func enable_dice(enabled: bool) -> void:
	dice.clickable = enabled


## Replica la señal del dado
func _on_dice_thrown_dice(number: int) -> void:
	dice_thrown.emit(number)


#endregion


#region Funciones de las rocas


## Activa las rocas dada la lista de índices
func enable_rocks(index: Array) -> void:
	for i in index:
		rocks_list[i].selectable = true


## Establece las rocas y las configura [br]
## Este método se basa en que las rocas se instancian desde [code]Rocks[/code]. Acá solo las registramos
func _set_rocks() -> void:
	# Filtra las rocas y se conecta a cada una
	rocks_list.clear()
	for rock in rocks.get_children():
		if rock is Rock:
			rocks_list.append(rock)
			rock.rock_selected.connect(_on_rock_selected)

	if rocks.get_child_count() != rocks.ROCK_COUNT:
		push_warning(
			"[World] Cantidad de rocas inesperada. Esperado: %s, Obtenido: %s"
			% [rocks.ROCK_COUNT, rocks.get_child_count()]
		)

	_rocks_ready.emit()


## Desactiva todas las rocas
func disable_rocks() -> void:
	if not is_node_ready(): await ready
	for rock in rocks_list:
		rock.selectable = false


## Replica la señal de cada roca al pulsarse
func _on_rock_selected(selected_rock: Rock) -> void:
	Utilities.print_color(
		"[World] Roca seleccionada: %s"
		% Utilities.get_enum_name(selected_rock.element, Constants.Elements),
		Constants.ELEMENTS_COLORS[selected_rock.element]
	)
	rock_selected.emit(selected_rock)


#endregion


#region Funciones de los jugadores


## Establece a los jugadores, definidos desde afuera
func set_players(new_players: Array[Player]) -> void:
	battle_data.players = new_players
	players.add_players(new_players)

	# Posiciona a los jugadores en rocas igualmente espaciadas
	await _rocks_ready
	for i in range(battle_data.get_players_count()):
		var current_player := battle_data.players[i]

		# Usamos una referencia aparte para el jugador humano
		if not current_player.is_bot: battle_data.player = current_player

		# Calculamos la posición y ubicamos
		var position_idx := int((float(i) / battle_data.players.size()) * rocks_list.size())
		current_player.move_to(rocks_list[position_idx].position, position_idx)

		print("[World] %s en índice %s" % [current_player.player_name, position_idx])

	await players_ready


#endregion
