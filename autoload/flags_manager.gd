## Almacena todas las banderas del juego para información persistente sobre la partida
extends Node


## Recurso con las banderas
var _flags: Flags = preload("res://autoload/resources/flags.tres")


## Obtiene la bandera por su nombre.
## Revisa flags.tres en el inpector para ver la lista de banderas disponibles
func get_flag(flag: StringName) -> bool:
	return _flags.items[flag]


## Establece la bandera por su nombre.
## Revisa flags.tres en el inpector para ver la lista de banderas disponibles
func set_flag(flag: StringName, value: bool) -> void:
	print_debug("Bandera %s: %s" % ["activada" if value else "desactivada", flag])
	_flags.set_item(flag, value)
