extends Node

@export var current_skin_mesh: MeshInstance3D
@export var characters_list_node: Node
@export var skins: Array[Material]

var current_skin: String

# Se conecta a cada personaje para detectar sus clics y le asigna su skin
func _ready() -> void:
	var characters = characters_list_node.get_children()
	for i in characters.size():
		var character = characters[i]
		var character_mesh: MeshInstance3D = character.get_child(1)

		character.skin_selected.connect(_change_skin)
		character_mesh.material_override = skins[i]

# ! Por ahora solo estamos trabajando con las skins de oso
## Cambiamos la skin actual por la que hayamos presionado.
func _change_skin(skin_index: int) -> void:
	current_skin_mesh.material_override = skins[skin_index]
	current_skin = GameConstants.SKINS[GameConstants.Species.BEAR][skin_index]

	print_debug("Skin %d seleccionada" % skin_index)

## Pasa al selector de equipo y actualiza los datos cuando se presiona el botón de siguiente
func _on_next_button_pressed() -> void:
	PlayerStats.species = GameConstants.Species.BEAR
	PlayerStats.skin = current_skin

	push_warning("Por ahora solo se trabajan las skins de oso")

	SceneManager.change_to_scene("team_selector")