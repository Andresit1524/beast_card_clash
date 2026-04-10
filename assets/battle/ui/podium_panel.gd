## Representa un panel para la información del jugador al finalizar el juego
class_name PodiumPanel extends PanelContainer


@export var color: Color:
	set(value):
		color = value
		_configure_color()


## Texto con la posición en al ranking de jugadores
@onready var position_label: Label = %Position
## Imagen del equipo del jugador
@onready var team: TextureRect = %Team
## Nombre del jugador
@onready var name_label: Label = %Name
## Puntaje del jugador
@onready var points: Label = %Points


## Configura el color del panel
func _configure_color() -> void:
	# Obtenemos el estilo actual y lo duplicamos para no afectar a otros paneles.
	var style = get_theme_stylebox("panel").duplicate()

	if style is StyleBoxFlat:
		style.bg_color = color
		add_theme_stylebox_override("panel", style)
