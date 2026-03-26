## [code]BattleReferee[/code] contiene funciones para decidir el ganador de cada ronda y
## eventualmente de la partida completa.
class_name BattleReferee extends BattleState


func start() -> void:
	# Espera un tiempo
	await get_tree().create_timer(manager.WAIT_TIME).timeout

	# Creamos la lista de todos los pares de enfrentamientos
	var pairs := []
	for player in manager.players:
		for rival in manager.players:
			# Omite a sí mismo
			if player == rival: continue

			# Omite duplicados
			if [player, rival] in pairs or [rival, player] in pairs: continue
			pairs.append([player, rival])

	# Por cada enfrentamiento, comparamos y aplicamos los daños
	for pair in pairs:
		var player1: Player = pair[0]
		var player2: Player = pair[1]
		var winner := _compare_players(pair[0], pair[1])
		match winner:
			1: player2.apply_damage(1)
			-1: player1.apply_damage(1)
			0: pass

	# Reseteamos las elecciones de cada jugador
	for player in manager.players:
		player.current_element = GameConstants.Elements.NONE
		player.current_value = 0

	# Actualizamos la interfaz
	manager.battle_ui.refresh_player_stats(manager.players)

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
			var _p when player1.current_value > player2.current_value: return 1
			var _p when player1.current_value < player2.current_value: return -1
			_: return 0

	# Elementos diferentes: se combate siguendo las reglas en "res://.docs/ganadores entre elementos.png"
	match player1.current_element:
		GameConstants.Elements.AIR:
			match player2.current_element:
				GameConstants.Elements.EARTH: return 1
				GameConstants.Elements.ENERGY: return -1
				GameConstants.Elements.FIRE: return -1
				GameConstants.Elements.WATER: return 1

		GameConstants.Elements.EARTH:
			match player2.current_element:
				GameConstants.Elements.AIR: return -1
				GameConstants.Elements.ENERGY: return 1
				GameConstants.Elements.FIRE: return 1
				GameConstants.Elements.WATER: return -1

		GameConstants.Elements.ENERGY:
			match player2.current_element:
				GameConstants.Elements.AIR: return 1
				GameConstants.Elements.EARTH: return -1
				GameConstants.Elements.FIRE: return -1
				GameConstants.Elements.WATER: return 1

		GameConstants.Elements.FIRE:
			match player2.current_element:
				GameConstants.Elements.AIR: return 1
				GameConstants.Elements.EARTH: return -1
				GameConstants.Elements.ENERGY: return 1
				GameConstants.Elements.WATER: return -1

		GameConstants.Elements.WATER:
			match player2.current_element:
				GameConstants.Elements.AIR: return -1
				GameConstants.Elements.EARTH: return 1
				GameConstants.Elements.ENERGY: return -1
				GameConstants.Elements.FIRE: return 1

	# Nada funciona: empate
	# ! No deberíamos llegar aquí btw
	push_warning(
		"[BattleReferee] Enfrentamiento entre %s y %s no definible"
		% [player1.player_name, player2.player_name]
	)
	return 0
