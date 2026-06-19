class_name EndUI extends Control


## Tiempo de desvanecimiento de la interfaz
const FADE_TIME := 0.5
## Colores para los diferentes rankings
const COLORS := [Color.GOLD, Color.SILVER, Color.PERU]


## Hace visible la interfaz
@export var ui_visible: bool = false:
	set(value):
		ui_visible = value
		set_ui_visible(value)

@export_group("Dependencias")
## Escena del panel de podium
@export var podium_panel_scene: PackedScene


## Rectángulo para el efecto de desvanecimiento
@onready var blur_rect: ColorRect = %BlurRect
## Lista de paneles del podium
@onready var podium: VBoxContainer = %Podium
## Botón de salir
@onready var exit_button: Button = %ExitButton


## Establece la visibilidad de la interfaz de usuario con un efecto de fade
func set_ui_visible(value: bool) -> void:
	var tween := create_tween()

	if not value:
		tween.tween_property(self, "modulate", Color.TRANSPARENT, FADE_TIME)
		tween.tween_callback(func(): visible = false)
		return

	visible = true
	modulate = Color.TRANSPARENT
	tween.tween_property(self, "modulate", Color.WHITE, FADE_TIME)
	return


## Establece los datos del podium usando la lista que se le provea
func set_podium(ranking: Array[Array]) -> void:
	print(
		"[BattleUI] Estableciendo podium: %s"
		% [ranking]
	)

	# Limpiamos el podium antes de empezar
	for child in podium.get_children():
		child.queue_free()

	# Por cada ranking
	for i in ranking.size():
		# Por cada posición en el ranking
		var rank: Array[Dictionary] = ranking[i]
		for player in rank:
			# Por cada jugador en esa posición
			var new_podium_panel: PodiumPanel = podium_panel_scene.instantiate()
			podium.add_child(new_podium_panel)

			# Datos
			new_podium_panel.position_label.text = str(i + 1)
			new_podium_panel.team.texture = TeamIcons.get_team(player.team)
			new_podium_panel.name_label.text = player.name
			new_podium_panel.points.text = str(0)

			# Aspecto visual
			new_podium_panel.color = get_rank_color(i + 1)


## Selecciona un color de acuerdo al ranking
func get_rank_color(rank: int) -> Color:
	return (COLORS[rank - 1] if rank <= COLORS.size() else Color.DARK_SLATE_GRAY) * 0.7


## Se sale de la batalla
func _quit_battle() -> void:
	ui_visible = false
	SceneManager.change_to_scene(&"start_menu")
