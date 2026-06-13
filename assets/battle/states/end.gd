## [code]BattleEnd[/code] acciona la interfaz de fin de juego.
class_name BattleEnd extends BattleState


func start() -> void:
	MusicManager.stream_paused = true

	# Si perdimos, completa el ranking primero
	if battle_data.we_lose(): battle_data.lose_remaining()

	await get_tree().create_timer(battle_data.WAIT_TIME).timeout
	manager.battle_ui.enable_end_ui(true)
