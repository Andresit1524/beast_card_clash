## [code]BattleLoop[/code] tiene la lógica para hacer que un bot decida la movida de su turno
class_name BattleLoop extends BattleState


## Jugador con el turno actual
@onready var current_turn: Player


func start() -> void:
	# Espera un tiempo
	await get_tree().create_timer(battle_data.WAIT_TIME).timeout

	current_turn = battle_data.current_turn
	print("[Loop] Turno de %s" % current_turn.player_name)

	var dice_value := await _throw_dice()

	# Se mueve a una de las dos rocas disponibles
	var rock_choice: int = [
		posmod(current_turn.current_rock_index - dice_value, manager.get_rocks().size()),
		posmod(current_turn.current_rock_index + dice_value, manager.get_rocks().size()),
	].pick_random()
	var rock_choice_element = manager.get_rocks()[rock_choice].element
	await _move_to_rock(rock_choice)

	# Juega la carta
	var played_card := _choose_card(rock_choice_element)
	if not played_card:
		manager.decide_next_or_end()
		return
	current_turn.play_card(played_card)

	# Actualizamos la interfaz y pasamos el turno
	await get_tree().create_timer(battle_data.WAIT_TIME / 2.0).timeout
	manager.battle_ui.refresh_player_panels(battle_data.players)
	manager.decide_next_or_end()


## Lanza el dado
func _throw_dice() -> int:
	manager.battle_stage.throw_dice()
	await manager.battle_stage.dice.thrown
	print("[Loop] Dado lanzado: %s" % battle_data.current_dice_value)

	return battle_data.current_dice_value


## Mueve el jugador hacia la posición indicada
func _move_to_rock(index: int) -> void:
	current_turn.move_to(manager.get_rocks()[index].position, index)
	await current_turn.moved


## Elige la carta y la retorna
func _choose_card(element: Constants.Elements) -> Card:
	var card_options: Array = current_turn.deck.filter(func(v):
		return v.element == element or not element
	)

	var played_card: Card = card_options.pick_random() if card_options else null
	if not played_card:
		print(
			"[BattleLoop] %s no tiene cartas de %s. Saltando turno."
			% [current_turn.player_name, Utilities.get_enum_name(element, Constants.Elements)]
		)
		current_turn.reset_choice()

	return played_card
