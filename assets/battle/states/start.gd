## [code]BattleStart[/code] es el estado que contiene la lógica de inicio de juego, para configurar
## antes de comenzar
class_name BattleStart extends BattleState


func start() -> void:
	MusicManager.play_music("battle")

	manager.setup_player()
	manager.setup_bots()
	manager.setup_ui()
	manager.setup_world()

	# Delega el turno al jugador que corresponda
	to_state.emit(BattleLoop if manager.current_turn.is_bot else BattleTurn)
