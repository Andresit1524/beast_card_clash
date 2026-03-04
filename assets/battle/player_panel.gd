extends PanelContainer

## Shown player name
@export var player_name: String:
	set(value):
		player_name = value
		refresh_panel()
## Shown player team
@export var team: GameConstants.Teams:
	set(value):
		team = value
		refresh_panel()
## Shown card element
@export var element: GameConstants.Elements:
	set(value):
		element = value
		refresh_panel()
## Shown card value
@export_range(1, 10) var value: int:
	set(val):
		value = val
		refresh_panel()
## Hide the player card
@export var hide_card: bool = false:
	set(value):
		hide_card = value
		refresh_panel()
## Cards list to get the sprites
@export var cards_list: CardsList
## Teams list to get the sprites
@export var teams_list: TeamsList


@onready var name_label: Label = $Margin/Contents/PlayerData/Name
@onready var team_texture: TextureRect = $Margin/Contents/PlayerData/Team
@onready var card_texture: TextureRect = $Margin/Contents/Card


func _ready():
	refresh_panel()


## Actualiza el panel con los últimos datos del jugador
func refresh_panel() -> void:
	if (not name_label or not team_texture or not card_texture): return


	name_label.text = player_name if player_name else "Sin nombre"
	team_texture.texture = teams_list.get_team(team)
	card_texture.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder
