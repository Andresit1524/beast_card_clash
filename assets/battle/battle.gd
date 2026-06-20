## Actúa como un bus de señales para el resto de componentes de la batalla
class_name Battle extends Node


## Máquina de estados de batalla
@onready var battle_manager: BattleManager = $BattleManager
## Escenario de batalla
@onready var stage: BattleStage = $Stage


func _on_ui_card_selected(card: Card) -> void:
	battle_manager.on_card_selected(card)


func _on_turn_enable_dice() -> void:
	stage.enable_dice(true)


func _on_stage_rock_selected(rock: Rock) -> void:
	battle_manager.on_rock_selected(rock)


func _on_dice_thrown(number: int) -> void:
	battle_manager.on_dice_thrown(number)
