## [code]BattleState[/code] es una clase que contiene utilidades para que la máquina de estados de
## batalla pueda acceder a la información de la partida de forma más directa.
class_name BattleState extends BaseState


## Envoltorio con tipo para el BattleManager
var manager: BattleManager:
	set(value):
		controlled_node = value
	get:
		return controlled_node

## Atajo para los datos de batalla
var battle_data: BattleData:
	set(value):
		manager.battle_data = value
	get:
		return manager.battle_data