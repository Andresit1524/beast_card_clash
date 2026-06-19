## Gestiona los datos de un panel de jugador en la interfaz de batalla
class_name PlayerPanel extends PanelContainer


## Tiempo de la animación al refrescar la vida del jugador
const REFRESH_HEALTH_TIME := 0.5


@export_group("Player")
## Nombre del jugador
@export var player_name: String:
	set(value):
		player_name = value
		refresh_panel()
## Equipo del jugador
@export var team: Constants.Teams:
	set(value):
		team = value
		refresh_panel()
## Vida del jugador
@export_range(0, 5) var health: int = 5:
	set(value):
		health = value
		refresh_panel()

@export_group("Card")
## Elemento de la carta
@export var element: Constants.Elements:
	set(value):
		if value == element: return
		element = value
		update_card()
## Valor de la carta
@export_range(1, Constants.MAX_CARD_VALUE) var value: int:
	set(val):
		if val == value: return
		value = val
		update_card()

## Lista de cartas para obtener los sprites
@export var cards_list: CardsList


## Nombre
@onready var name_label: Label = %Name
## Sprite del equipo
@onready var team_texture: TextureRect = %Team
## Sprite de la carta
@onready var card_texture: TextureRect = %Card
## Barra de vida
@onready var life_bar: ProgressBar = %LifeBar
## Valor de la vida
@onready var life_label: RichTextLabel = %LifeValue

## Escala base de la carta, para las animaciones
@onready var base_card_scale := card_texture.scale


func _ready() -> void:
	refresh_panel()
	update_card()


## Actualiza el panel con los últimos datos del jugador
func refresh_panel() -> void:
	if not (name_label and team_texture and card_texture): return
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Actualiza los datos del jugador
	name_label.text = player_name if player_name else "Sin nombre"
	team_texture.texture = TeamIcons.get_team(team)

	# Actualiza la barra de vida
	# Si la vida bajo, hace un efecto de destello en rojo
	var color2 := Color.WHITE if health > 0 else Color.RED
	if life_bar.value > health:
		modulate = Color.RED
		tween.tween_property(self, "modulate", Color.WHITE, REFRESH_HEALTH_TIME)

	tween.tween_property(life_bar, "value", health, REFRESH_HEALTH_TIME)
	life_label.text = "[color=%s]%s[/color]" % [color2.to_html(), health]


## Actualiza la carta
func update_card() -> void:
	if not cards_list: return

	# Actualiza el sprite de la carta
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(card_texture, "scale", Vector2(0, base_card_scale.y), 0.1)
	tween.tween_callback(_set_card_sprite)
	tween.tween_property(card_texture, "scale", base_card_scale, 0.1)


## Actualiza el sprite de la carta con una amimación
func _set_card_sprite() -> void:
	if not cards_list: return
	card_texture.texture = cards_list.get_card(element, value)
