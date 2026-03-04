# `AutoloadResource`
`AutoloadResource` es una clase base abstracta (`abstract class_name`) diseñada para estandarizar y facilitar la gestión de recursos en nodos `Autoload` (también conocidos como Singletons) dentro del proyecto. Su propósito principal es permitir la creación de archivos de recurso (`.tres`) que pueden almacenar diferentes tipos de datos, como referencias a escenas, archivos de música, o banderas de estado del juego, y ser gestionados directamente desde el editor de Godot.

Al extender `Resource`, `AutoloadResource` permite que instancias de este tipo (o de sus clases derivadas) se guarden como archivos `.tres`, lo que facilita la asignación y organización de recursos a través del Inspector de Godot. Esto es particularmente útil para centralizar la configuración y las referencias de recursos globales, mejorando la experiencia de desarrollo al hacer que los recursos sean fácilmente accesibles y modificables sin necesidad de modificar código directamente.

El enfoque de esta clase es proporcionar una base robusta para la validación de tipos de los elementos almacenados, asegurando que los datos cargados en un `Autoload` sean consistentes y del tipo esperado, lo que previene errores comunes y facilita el mantenimiento del código. En el contexto de "Beast Card Clash", esto podría aplicarse a la gestión de sonidos ambientales globales, datos de configuración del juego o referencias a las "Beast Cards" base que necesitan ser accesibles desde cualquier punto del juego.

```gdscript
@abstract class_name AutoloadResource extends Resource

@export var items: Dictionary[String, Variant]
var expected_type: int
```

# Métodos

## Otros métodos

### `get_item(name: String)`
Este método se encarga de recuperar un elemento específico del diccionario `items` utilizando su nombre como clave. Incluye una robusta comprobación de errores para asegurar que el elemento solicitado existe antes de intentar acceder a él. Si el elemento no se encuentra, se genera un error a través de `push_error`, y se retorna `null` para indicar la falla.

Este método es la forma principal y segura de acceder a los recursos almacenados en una instancia de `AutoloadResource` desde cualquier parte del código que tenga una referencia a este recurso.

```gdscript
func get_item(name: String):
	if not name in items.keys():
		push_error("Elemento de AutoloadResource no encontrado: %s" % name)
		return null

	return items[name]
```

### `set_item(name: String, value) -> void`
El método `set_item` permite establecer o actualizar el valor de un elemento en el diccionario `items`. Antes de asignar el valor, se invoca a la función auxiliar `_check_item()` para validar que el `value` proporcionado sea del `expected_type` para esta instancia de recurso. Si la validación falla, la operación se cancela y no se realiza ninguna asignación.

Si el elemento con el `name` especificado no existe en el diccionario, se genera un mensaje de error (`push_error`) para advertir que el elemento será creado. Aunque la función permite esta creación, la práctica ideal es que los elementos sean predefinidos y asignados a través del Inspector de Godot en el archivo `.tres`, y `set_item` se utilice principalmente para actualizar valores existentes.

```gdscript
func set_item(name: String, value) -> void:
	if not _check_item(value):
		return

	if not name in items.keys():
		push_error("Elemento de AutoloadResource no encontrado: %s. El elemento será creado" % name)

	items[name] = value
```

### `check_item_types() -> bool`
Esta función itera sobre todos los valores almacenados en el diccionario `items` y utiliza la función auxiliar privada `_check_item()` para verificar que cada uno de ellos sea del `expected_type`. Si algún elemento no cumple con el tipo esperado, la función detiene su ejecución y retorna `false` inmediatamente. Si todos los elementos pasan la validación de tipo, la función retorna `true`.

Este método es útil para realizar una validación completa de los recursos cargados, especialmente al inicio del juego o en puntos críticos, para asegurar la integridad de los datos.

```gdscript
func check_item_types() -> bool:
	for item in items.values():
		if not _check_item(item): return false

	return true
```

### `_check_item(item)`
Este es un método auxiliar privado (`_` indica que es para uso interno) que realiza la comprobación de tipo para un solo `item` dado. Compara el `typeof(item)` con el `expected_type` definido para la clase. Si los tipos no coinciden, se emite un error detallado a través de `push_error` indicando el tipo esperado y el tipo recibido, y la función retorna `false`. En caso de que los tipos coincidan, retorna `true`.

La variable `expected_type` debe ser establecida por las clases que hereden de `AutoloadResource` para especificar el tipo de datos que esperan almacenar. Por ejemplo, una clase `SoundResource` podría establecer `expected_type` a `TYPE_OBJECT` y esperar objetos `AudioStream`.

```gdscript
func _check_item(item):
	if typeof(item) != expected_type:
		push_error(
			"Valor de AutoloadResource de tipo incorrecto. Esperado: %s, Obtenido: %s."
			% [expected_type, typeof(item)]
		)
		return false

	return true
```