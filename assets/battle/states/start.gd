class_name BattleStart extends BattleState


func start() -> void:
	MusicManager.play_music("battle")

	manager.setup_player()
	manager.setup_bots()
	manager.setup_ui()
