## Una clase auxiliar para almacenar los íconos de los elementos del juego. Accede a ellas por su
## índice usando [code]get_element()[/code] [code]GameCostants.Elements[/code]
class_name ElementsList extends Resource


## Lista de elementos. Deben ir en el mismo orden que el enumerador en [code]GameConstants.Elements[/code]
@export var sprites_list: Array[Texture2D]


## Obtiene un elemento por su índice
func get_element(element: GameConstants.Elements) -> Texture2D:
	return sprites_list[element]