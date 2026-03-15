## Gestiona los datos de un panel de jugador en la interfaz de batalla
class_name PlayerPanel extends PanelContainer

## Nombre del jugador
@export var player_name: String:
	set(value):
		player_name = value
		refresh_panel()
## Equipo del jugador
@export var team: GameConstants.Teams:
	set(value):
		team = value
		refresh_panel()
## Vida del jugador
@export_range(0, 5) var health: int:
	set(value):
		health = value
		refresh_panel()

## Elemento de la carta
@export var element: GameConstants.Elements:
	set(value):
		element = value
		if not hide_card: update_card()
## Valor de la carta
@export_range(1, 10) var value: int:
	set(val):
		value = val
		if not hide_card: update_card()
## Oculta la carta del jugador
@export var hide_card: bool = false:
	set(value):
		if value == hide_card: return
		hide_card = value
		update_card()

## Cards list to get the sprites
@export var cards_list: CardsList
## Teams list to get the sprites
@export var teams_list: TeamsList


@onready var name_label: Label = $Margin/Contents/PlayerData/Name
@onready var team_texture: TextureRect = $Margin/Contents/PlayerData/Team
@onready var card_texture: TextureRect = $Margin/Contents/Card
@onready var life_bar: ProgressBar = $Margin/Contents/LifeBar
@onready var life_label: RichTextLabel = $Margin/Contents/LifeBar/LifeValue
@onready var base_card_scale := card_texture.scale


func _ready():
	refresh_panel()
	update_card()


## Actualiza el panel con los últimos datos del jugador
func refresh_panel() -> void:
	if (not name_label or not team_texture or not card_texture): return

	# Actualiza los datos del jugador
	name_label.text = player_name if player_name else "Sin nombre"
	team_texture.texture = teams_list.get_team(team)

	# Actualiza la barra de vida
	var color := "white" if health > 0 else "red"
	life_bar.value = health
	life_label.text = "[color=%s]%s[/color]" % [color, health]


## Establece la carta
func update_card() -> void:
	if not cards_list: return

	# Actualiza el sprite de la carta
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(card_texture, "scale", Vector2(0, base_card_scale.y), 0.1)
	tween.tween_callback(set_card_sprite)
	tween.tween_property(card_texture, "scale", base_card_scale, 0.1)


## Actualiza el sprite de la carta con una amimación
func set_card_sprite() -> void:
	if not cards_list or not card_texture.texture: return
	card_texture.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder
