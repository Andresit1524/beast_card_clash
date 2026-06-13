## [code]BattleReferee[/code] contiene funciones para decidir el ganador de cada ronda y
## eventualmente de la partida completa.
class_name BattleReferee extends BattleState


## Se emite cuando la ronda ya fue manejada
signal round_handled


## Matriz de fortalezas. Indica que elementos derrota el elemento dado
## -> "res://docs/ganadores entre elementos.png"
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

	# Creamos los enfrentamientos
	var pairs := []
	var p_count := battle_data.players.size()
	for i in p_count:
		for j in range(i + 1, p_count):
			pairs.append([battle_data.players[i], battle_data.players[j]])

	# Aplicamos los enfrentamientos
	for pair in pairs:
		var player1: Player = pair[0]
		var player2: Player = pair[1]
		var winner := _compare_players(player1, player2)

		match winner:
			1: player2.apply_damage()
			-1: player1.apply_damage()
			0: pass

	# Reseteamos las elecciones de cada jugador
	for player in battle_data.players:
		player.current_element = Constants.Elements.NONE
		player.current_value = 0

	# Fin de juego (ganador o empate fatal)
	battle_data.apply_game_over()
	if battle_data.players.size() <= 1:
		to_state.emit(BattleEnd)
		return

	manager.battle_ui.refresh_player_stats(battle_data.players)

	# Decidimos el nuevo turno
	round_handled.emit()


## Compara dos jugadores entre sí y decide el ganador. [br]
##
## - 1: gana el primero [br]
## - 0: empate [br]
## - -1: gana el segundo
func _compare_players(player1: Player, player2: Player) -> int:
	var element1 := player1.current_element
	var element2 := player2.current_element

	# Uno de los dos no tiene carta: empate
	# ! Esta regla puede cambiar
	if not element1 or not element2: return 0

	# Elementos diferentes: aplica la jerarquía
	if element1 != element2: return 1 if element2 in WINNERS_MATRIX[element1] else -1

	# Elementos iguales: gana el mayor número
	return 1 if player1.current_value > player2.current_value else -1
