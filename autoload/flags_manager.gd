extends Node

## Lista de banderas, su valor y su descripción
var _flags: Flags = preload("uid://calw1rmsghoh8")

# Revisa al inicio que todas las banderas estén bien definidas
func _ready():
    _flags.expected_type = TYPE_BOOL
    _flags.check_item_types()

## Obtiene la bandera por su nombre.
## Revisa flags.tres en el inpector para ver la lista de banderas disponibles
func get_flag(flag: String) -> bool:
    return _flags.get_item(flag)

## Establece la bandera por su nombre.
## Revisa flags.tres en el inpector para ver la lista de banderas disponibles
func set_flag(flag: String, value: bool) -> void:
    _flags.set_item(flag, value)
