## Nodo que almacena los jugadores
class_name Players extends Node3D


## Añade a los jugadores a la escena [br]
## A diferencia de [code]Rocks[/code]. Los datos vienen de fuera
func add_players(players_list: Array[Player]) -> void:
	for child in get_children():
		child.free()

	for player in players_list:
		add_child(player)
		print("[Players] Jugador añadido a la escena: %s" % player.player_name)
