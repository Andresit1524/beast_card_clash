## Flags es un tipo de recurso que almacena las banderas, variables que dictan elementos de la
## progresión de la historia del juego, para su acceso de manera directa y descentralizada
class_name Flags extends Resource


## Lista de banderas
@export var items: Dictionary[StringName, Variant]
