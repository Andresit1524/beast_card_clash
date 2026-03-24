## [code]BattleStart[/code] es el estado que contiene la lógica de inicio de juego, para configurar
class_name BattleStart extends BattleState


func start() -> void:
	MusicManager.play_music("battle")

	manager.setup_player()
	manager.setup_bots()
	manager.setup_ui()
