## Estado de batalla con la lógica de inicio de juego, para configurar antes de comenzar
class_name BattleStart extends BattleState


@export_group("Dependencias")
## Escena de personaje
@export var player_scene: PackedScene


func start() -> void:
	await manager.ready
	MusicManager.play_music("battle")

	_setup_player()
	_setup_bots()

	manager.setup_ui()
	manager.setup_stage()

	# Delega el turno al jugador que corresponda
	await get_tree().create_timer(Constants.BATTLE_WAIT_TIME / 2.0).timeout
	to_state.emit(BattleLoop if battle_data.current_turn.is_bot else BattleTurn)


## Establece al jugador humano
func _setup_player() -> void:
	# Crea el jugador humano
	var player: Player = player_scene.instantiate()
	player.player_name = PlayerStats.player_name
	player.team = PlayerStats.team
	player.is_bot = false
	player.create_deck()

	# Añade a los datos de juego
	battle_data.add_player(player)


## Establece los bots
func _setup_bots() -> void:
	var bots_count := randi_range(1, Constants.MAX_PLAYERS - 1)
	for i in bots_count:
		var new_bot: Player = player_scene.instantiate()
		new_bot.create_deck()
		battle_data.add_player(new_bot)

		print("[BattleManager] Nuevo bot creado: %s!" % new_bot.player_name)

	battle_data.shuffle_players()
	print(
		"[BattleManager] %s jugadores en juego: %s"
		% [bots_count + 1, battle_data.players.map(func(p): return p.player_name)]
	)
