## [code]BattleTurn[/code] permite cederle el turno al jugador humano, principalmente gestionando el
## dado y su resultado para resaltar las rocas
class_name BattleTurn extends BattleState


## Activar el dado
signal enable_dice


func start() -> void:
	# Activa el dado. El manager nos traerá de vuelta cuando se lance
	enable_dice.emit()


## Activa las rocas cuando el dado sea lanzado
func on_dice_thrown(number: int) -> void:
	# Definimos las rocas a las que nos podemos mover y las activamos
	var current_pos = battle_data.player.current_rock_index
	var available_pos := [
		posmod(current_pos - number, manager.get_rocks().size()),
		posmod(current_pos + number, manager.get_rocks().size()),
	]

	# Resaltamos las rocas disponibles
	# El resto del turno corre por cuenta de reacciones en el manager
	manager.battle_stage.enable_rocks(available_pos)
