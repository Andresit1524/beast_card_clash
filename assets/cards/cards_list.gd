## Una clase auxiliar para almacenar las cartas del juego. Accede a ellas por su elemento y valor
## usando [code]get_card()[/code]
class_name CardsList extends Resource


@export var placeholder: Texture2D
@export var air_cards: Array[Texture2D]
@export var earth_cards: Array[Texture2D]
@export var energy_cards: Array[Texture2D]
@export var fire_cards: Array[Texture2D]
@export var water_cards: Array[Texture2D]


## Obtiene la carta por su elemento y valor
func get_card(element: int, value: int) -> Texture2D:
	match element:
		GameConstants.Elements.NONE:
			return placeholder
		GameConstants.Elements.AIR:
			return air_cards[value - 1]
		GameConstants.Elements.EARTH:
			return earth_cards[value - 1]
		GameConstants.Elements.ENERGY:
			return energy_cards[value - 1]
		GameConstants.Elements.FIRE:
			return fire_cards[value - 1]
		GameConstants.Elements.WATER:
			return water_cards[value - 1]

	push_error("Carta no identificada")
	return placeholder
