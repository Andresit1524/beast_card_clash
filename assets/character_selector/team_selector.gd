extends Control


## Lista de botones asociados al equipo que representan
@export var teams: Dictionary[Button, Constants.Teams]
## Grupo de botones de los equipos
@export var teams_button_group: ButtonGroup


## Campo para escribir el nombre del jugador
@onready var line_edit_node: LineEdit = %LineEdit
## Botón de enviar y jugar
@onready var play_button: Button = %PlayButton


var selected_team: int = -1


func _ready():
	# Conecta todos los botones de los equipos al selector
	teams_button_group.pressed.connect(_set_team)


## Vuelve al selector de aspectos con el botón de volver
func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("skin_selector")


## Establece el equipo del jugador dependiendo del botón pulsado en el selector de equipo
func _set_team(pressed_button: Button):
	print(
		"[TeamSelector] Equipo elegido: %s"
		% Utilities.get_enum_name(selected_team, Constants.Teams)
	)

	# VA-Games no es equipo elegible, ergo, no aparece. No lo añadas
	selected_team = teams[pressed_button]

	# Oscurece el boton presionado y resetea los demás
	_highlight_buttons()


## Actualiza los datos y pasa a jugar cuando se presiona el botón de jugar
func _submit_and_play():
	# Nombre vacío
	if not line_edit_node.text:
		push_warning("[TeamSelector] Nombre vacío")
		line_edit_node.placeholder_text = "¡Nombre vacío!"
		return

	# Equipo vacío
	if selected_team == -1:
		push_warning("[TeamSelector] Equipo vacío")
		play_button.text = "¡Equipo vacío!"
		_highlight_buttons(true)
		return

	# Establece los datos del jugador y pasa a jugar
	PlayerStats.team = selected_team as Constants.Teams
	PlayerStats.player_name = line_edit_node.text
	FlagsManager.set_flag("character_selected", true)

	push_warning("[TeamSelector] No hay escena de mapa. Pasando a batalla")
	SceneManager.change_to_scene("battle")


## Establece el color de los botones
func _highlight_buttons(warn := false) -> void:
	for button: Button in teams_button_group.get_buttons():
		if warn:
			button.modulate = Color.ORANGE
			continue

		button.modulate = Color.DIM_GRAY if button.button_pressed else Color.WHITE
