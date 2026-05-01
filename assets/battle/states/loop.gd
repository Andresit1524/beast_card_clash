## [code]BattleLoop[/code] tiene la lógica para hacer que un bot decida la movida de su turno
class_name BattleLoop extends BattleState


func start() -> void:
	# Espera un tiempo
	await get_tree().create_timer(battle_data.WAIT_TIME).timeout
	print("[Loop] Turno de %s" % battle_data.current_turn.player_name)

	# Lanza el dado
	manager.battle_world.throw_dice()
	await manager.battle_world.dice_thrown
	var current_dice_value := battle_data.current_dice_value
	print("[Loop] Dado lanzado: %s" % battle_data.current_dice_value)

	# Se mueve a una de las dos rocas disponibles
	var rock_choice: int = [
		posmod(battle_data.current_turn.current_rock_index - current_dice_value, manager.get_rocks().size()),
		posmod(battle_data.current_turn.current_rock_index + current_dice_value, manager.get_rocks().size()),
	].pick_random()

	battle_data.current_turn.move_to(manager.get_rocks()[rock_choice].position, rock_choice)
	await battle_data.current_turn.moved
	var rock_choice_element = manager.get_rocks()[rock_choice].element

	# Elige la carta
	var card_choices: Array = battle_data.current_turn.deck.filter(func(v):
		return v.element == rock_choice_element or not rock_choice_element
	)
	var played_card: Card = card_choices.pick_random() if card_choices else null

	# Si no tiene cartas de ese elemento, salta turno
	if not played_card:
		print(
			"[BattleLoop] %s no tiene cartas de %s. Saltando turno."
			% [battle_data.current_turn.player_name, Utilities.get_enum_name(rock_choice_element, Constants.Elements)]
		)
		battle_data.current_turn.current_element = Constants.Elements.NONE
		battle_data.current_turn.current_value = 0
		manager.switch_next_turn_state()
		return

	# Guardamos los valores antes de que la carta sea liberada por la UI
	var card_element := played_card.element
	var card_value := played_card.value

	# Liberamos la carta y actualizamos la interfaz
	battle_data.current_turn.play_card(played_card)
	await get_tree().create_timer(battle_data.WAIT_TIME / 2.0).timeout
	battle_data.current_turn.current_element = card_element
	battle_data.current_turn.current_value = card_value
	manager.battle_ui.refresh_player_stats(battle_data.players)
	print(
		"[Loop] Carta elegida: %s-%s"
		% [Utilities.get_enum_name(card_element, Constants.Elements), card_value]
	)

	# Delega el siguiente turno
	manager.switch_next_turn_state()
