## AutoloadResource es una clase base para la gestión de recursos para autoloads (Singletons),
## tales como escenas, música y banderas.[br]
##
## Su uso es la creación de recursos [code].tres[/code] para almacenar esos datos y gestionarlos
## desde el editor. Los recursos están en la carpeta [code]res://autoload/resources[/code].
@abstract class_name AutoloadResource extends Resource

## Elementos a almacenar en el recurso. Usa el inspector para asignarlos
@export var items: Dictionary[String, Variant]

## Tipo a esperar para los recursos. Cada gestor de recursos lo establece
var expected_type: int

## Obtiene el elemento por su nombre
func get_item(name: String):
	if not name in items.keys():
		push_error("Elemento de AutoloadResource no encontrado: %s" % name)
		return null

	return items[name]

## Establece el valor del elemento. Si no existe, lo crea, pero no es el comportamiento ideal
func set_item(name: String, value) -> void:
	if not _check_item(value):
		return

	if not name in items.keys():
		push_error("Elemento de AutoloadResource no encontrado: %s. El elemento será creado" % name)

	items[name] = value

## Checa todos los valores del recurso
func check_item_types() -> bool:
	for item in items.values():
		if not _check_item(item): return false

	return true

## Función auxiliar que checa el tipo de un dato
func _check_item(item):
	if typeof(item) != expected_type:
		push_error(
			"Valor de AutoloadResource de tipo incorrecto. Esperado: %s, Obtenido: %s."
			% [expected_type, typeof(item)]
		)
		return false

	return true
