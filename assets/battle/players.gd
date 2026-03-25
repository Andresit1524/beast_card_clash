## Nodo que almacena los jugadores
class_name Players extends Node3D


## Añade a los jugadores a la escena [br]
## A diferencia de [code]Rocks[/code]. Los datos vienen de fuera
func add_players(players_list: Array[Player]) -> void:
	# Elimina a los jugadores que no están en la lista
	for player in get_children():
		print("[Players] Jugador eliminado de la escena: %s" % player.player_name)
		if player not in players_list: player.free()

	# Añade a los jugadores a la escena
	for player in players_list:
		if player in get_children(): continue

		add_child(player)
		print("[Players] Jugador añadido a la escena: %s" % player.player_name)
