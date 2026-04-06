## [code]BattleTurn[/code] permite cederle el turno al jugador humano
class_name BattleTurn extends BattleState


func start() -> void:
	# Activa el dado
	manager.battle_world.enable_dice(true)

	# Esperamos a que el dado se lance para saber su número
	await manager.battle_world.dice_thrown
	var current_dice_value := battle_data.current_dice_value

	# Definimos las rocas a las que nos podemos mover y las activamos
	var current_pos = battle_data.player.current_rock_index
	var available_pos := [
		posmod(current_pos - current_dice_value, manager.get_rocks().size()),
		posmod(current_pos + current_dice_value, manager.get_rocks().size()),
	]

	# Resaltamos las rocas disponibles
	# El resto del juego, practicamente, corre por cuenta de reacciones en el manager
	manager.battle_world.enable_rocks(available_pos)

	# Delega el siguiente turno
	await manager.player_turn_ended
	manager.switch_next_turn_state()
