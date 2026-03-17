class_name BattleState extends BaseState


## Wrapper para el BattleManager
var manager: BattleManager:
	set(value):
		controlled_node = value
	get:
		return controlled_node
