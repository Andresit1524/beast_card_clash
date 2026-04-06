## Nodo que almacena los jugadores
class_name Players extends Node3D


signal players_game_over(players: Array[Player])


## Añade a los jugadores a la escena [br]
## A diferencia de [code]Rocks[/code]. Los datos vienen de fuera
func add_players(players_list: Array[Player]) -> void:
	# Elimina a los jugadores que no están en la lista
	for player in get_children():
		if player not in players_list:
			print("[Players] Jugador eliminado de la escena: %s" % player.player_name)
			player.free()

	# Añade a los jugadores a la escena
	for player in players_list:
		if player in get_children(): continue

		# Nos conectamos a la señal del jugador
		player.game_over.connect(_on_player_game_over)

		add_child(player)
		print("[Players] Jugador añadido a la escena: %s" % player.player_name)


## Gestiona la pérdida de un jugador
func _on_player_game_over(player: Player) -> void:
	players_game_over.emit([player])
	print("[Players] Jugador eliminado de la escena: %s" % player.player_name)
