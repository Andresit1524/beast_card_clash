extends Node

## Lista de banderas, su valor y su descripción
var _flags: Dictionary[String, bool] = {
    "played": false
}

## Obtiene la bandera por su nombre.
## Consulta en el singleton a por los nombres disponibles
func get_flag(flag: String):
    return _flags[flag]
