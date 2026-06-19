## Almacena los íconos de los elementos del juego
class_name ElementIcons


const ICONS_PATH := "res://assets/elements/sprites"
const ICONS: Dictionary[Constants.Elements, CompressedTexture2D] = {
	Constants.Elements.NONE: preload("%s/all_elements.png" % ICONS_PATH),
	Constants.Elements.AIR: preload("%s/air.png" % ICONS_PATH),
	Constants.Elements.EARTH: preload("%s/earth.png" % ICONS_PATH),
	Constants.Elements.ENERGY: preload("%s/energy.png" % ICONS_PATH),
	Constants.Elements.FIRE: preload("%s/fire.png" % ICONS_PATH),
	Constants.Elements.WATER: preload("%s/water.png" % ICONS_PATH),
}


## Obtiene un elemento por su índice
static func get_element(element: Constants.Elements) -> CompressedTexture2D:
	return ICONS[element]
