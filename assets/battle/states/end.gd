class_name BattleEnd extends BattleState


func start() -> void:
	await get_tree().create_timer(battle_data.WAIT_TIME).timeout
	manager.battle_ui.set_end_ui(true)
