## Representa un panel para la información del jugador al finalizar el juego
class_name PodiumPanel extends PanelContainer


## Texto con la posición en al ranking de jugadores
@onready var position_label: Label = %Position
## Imagen del equipo del jugador
@onready var team: TextureRect = %Team
## Nombre del jugador
@onready var name_label: Label = %Name
## Puntaje del jugador
@onready var points: Label = %Points
