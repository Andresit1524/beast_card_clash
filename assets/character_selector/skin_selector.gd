class_name SkinSelector extends Node


# Sprite que muestra el aspecto actual del personaje
@onready var current_skin_sprite: Sprite3D = %CurrentSkin
# Nodo que contiene a todos los personajes
@onready var characters_list: Node = %Skins


var current_skin: Texture2D


# Se conecta a cada personaje para detectar sus clics y le asigna su skin
func _ready() -> void:
	for character: Character in characters_list.get_children():
		character.skin_selected.connect(_change_skin)


## Cambiamos la skin actual por la que hayamos presionado.
# ! Por ahora solo estamos trabajando con las skins de oso
func _change_skin(skin: Texture2D) -> void:
	current_skin_sprite.texture = skin
	current_skin = skin

	print("[SkinSelector] Skin %s seleccionada" % skin.resource_path)


## Actualiza los datos y pasa al selector de equipos cuando se presiona el botón de siguiente
func _on_team_button_pressed() -> void:
	push_warning("[SkinSelector] Por ahora solo se trabajan las skins de oso")

	PlayerStats.species = Constants.Species.BEAR
	PlayerStats.skin = current_skin

	SceneManager.change_to_scene("team_selector")
