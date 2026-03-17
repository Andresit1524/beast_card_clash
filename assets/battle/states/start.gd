class_name BattleStart extends BattleState


func start() -> void:
	MusicManager.play_music("battle")
	_set_players_data()


## Establece al jugador y los bots
func _set_players_data() -> void:
	# Crea el jugador humano
	manager.player = Player.new()
	manager.player.is_bot = false
	manager.player.create_deck()
	manager.players.append(manager.player)

	# ! Debug
	manager.player.randomize()

	# Establece los datos del jugador desde el singleton
	manager.player.player_name = PlayerStats.player_name
	manager.player.team = PlayerStats.team

	# Mano del jugador
	manager.player.deck_updated.connect(manager.battle_ui.set_hand_from_deck)
	manager.battle_ui.set_hand_from_deck(manager.player.deck)

	# Bots
	var bots_count := randi_range(1, manager.MAX_PLAYERS - 1)
	for i in range(bots_count):
		var new_bot := Player.new()
		new_bot.create_deck()
		new_bot.randomize()
		new_bot.is_bot = true
		print_debug("[BattleManager] Nuevo bot creado: %s!" % new_bot.player_name)
		manager.players.append(new_bot)

	# Establece la UI
	manager.battle_ui.refresh_player_stats(manager.players)
