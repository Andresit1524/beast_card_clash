## [code]BattleReferee[/code] contiene funciones para decidir el ganador de cada ronda y
## eventualmente de la partida completa.
class_name BattleReferee extends BattleState


## Matriz de fortalezas. Indica que elementos derrota el elemento dado
const WINNERS_MATRIX: Dictionary[Constants.Elements, Array] = {
	Constants.Elements.AIR: [Constants.Elements.EARTH, Constants.Elements.WATER],
	Constants.Elements.EARTH: [Constants.Elements.ENERGY, Constants.Elements.FIRE],
	Constants.Elements.ENERGY: [Constants.Elements.AIR, Constants.Elements.WATER],
	Constants.Elements.FIRE: [Constants.Elements.AIR, Constants.Elements.ENERGY],
	Constants.Elements.WATER: [Constants.Elements.EARTH, Constants.Elements.FIRE],
}


func start() -> void:
	# Espera un tiempo
	await get_tree().create_timer(battle_data.WAIT_TIME).timeout

	# Creamos la lista de todos los pares de enfrentamientos
	var pairs := []
	var p_count := battle_data.players.size()
	for i in range(p_count):
		for j in range(i + 1, p_count):
			pairs.append([battle_data.players[i], battle_data.players[j]])

	# Por cada enfrentamiento, comparamos y aplicamos los daños
	for pair in pairs:
		var player1: Player = pair[0]
		var player2: Player = pair[1]
		var winner := _compare_players(pair[0], pair[1])

		match winner:
			1: player2.apply_damage()
			-1: player1.apply_damage()
			0: pass

	# Reseteamos las elecciones de cada jugador
	for player in battle_data.players:
		player.current_element = Constants.Elements.NONE
		player.current_value = 0

	# Actualizamos los jugadores
	battle_data.apply_game_over()

	# Si solo queda un jugador (o ninguno por un empate fatal), la partida termina
	if battle_data.players.size() <= 1:
		to_state.emit(BattleEnd)
		return

	manager.battle_ui.refresh_player_stats(battle_data.players)

	# Decidimos el nuevo turno
	manager.round_handled.emit()


## Compara dos jugadores entre sí y decide el ganador. 1 si gana el primero, 0 si empatan, -1 si gana el segundo
func _compare_players(player1: Player, player2: Player) -> int:
	# Uno de los dos no tiene carta: empate
	# ! Esta regla puede cambiar
	if not player1.current_element or not player2.current_element: return 0

	# Elementos iguales: gana el mayor número
	if player1.current_element == player2.current_element:
		match player1.current_value:
			var value when value > player2.current_value: return 1
			var value when value < player2.current_value: return -1
			_: return 0

	# Elementos diferentes: se combate siguendo las reglas en "res://.docs/ganadores entre elementos.png"
	if player2.current_element in WINNERS_MATRIX[player1.current_element]: return 1
	if player1.current_element in WINNERS_MATRIX[player2.current_element]: return -1

	# En caso de que no se cumpla nada
	return 0
