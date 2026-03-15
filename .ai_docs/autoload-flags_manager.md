# `FlagsManager`
`FlagsManager.gd` es un script `Node` que actúa como un gestor centralizado para las banderas booleanas (flags) dentro del proyecto Beast Card Clash. Su propósito principal es proporcionar una interfaz consistente y validada para acceder y modificar estados globales del juego que se representan como valores booleanos. Estas banderas pueden controlar aspectos como la activación/desactivación de características, el seguimiento del progreso del jugador, el estado de tutoriales o cualquier otra condición binaria del juego.

El script se apoya en un recurso personalizado de Godot, `Flags` (pre-cargado con el UID `uid://calw1rmsghoh8` y que se asume instanciado como `flags.tres`), el cual es responsable de almacenar las definiciones y los valores actuales de todas las banderas. Al centralizar la gestión de banderas a través de este sistema, se busca mejorar la coherencia del código y la experiencia de desarrollo al ofrecer un único punto de control y validación para los estados del juego.

# Métodos

## Métodos de Godot

### `_ready()`
El método `_ready()` se ejecuta una vez que el nodo `FlagsManager` ha entrado en el árbol de la escena. Su función principal en este script es la inicialización y la configuración de las validaciones de tipo para el recurso `_flags`.

```gdscript
func _ready():
	_flags.expected_type = TYPE_BOOL
	_flags.check_item_types()
```

En esta sección, se establece explícitamente la propiedad `_flags.expected_type` a `TYPE_BOOL`. Esto informa al recurso `Flags` que todos los "ítems" (las banderas individuales) que gestiona deben ser de tipo booleano. Inmediatamente después, se invoca `_flags.check_item_types()`. Esta llamada es crucial, ya que presumiblemente activa un mecanismo interno en el recurso `Flags` para verificar que todas las banderas definidas en `flags.tres` (o su equivalente) cumplen con el tipo `TYPE_BOOL`. Esto ayuda a detectar y prevenir errores de tipo en tiempo de ejecución, asegurando la integridad de los datos de las banderas.

## Otros métodos

### `get_flag(flag: String) -> bool`
Este método público proporciona una forma de recuperar el valor booleano actual de una bandera específica por su nombre.

```gdscript
func get_flag(flag: String) -> bool:
	return _flags.get_item(flag)
```

El método acepta un argumento `flag` de tipo `String`, que es el nombre único de la bandera a consultar. La lógica de recuperación del valor se delega directamente al método `get_item()` del recurso `_flags`. Para conocer la lista completa de banderas disponibles y sus descripciones, los desarrolladores deben consultar el recurso `flags.tres`, el cual es normalmente editable a través del Inspector de Godot.

### `set_flag(flag: String, value: bool) -> void`
Este método público permite modificar el valor booleano de una bandera específica.

```gdscript
func set_flag(flag: String, value: bool) -> void:
	print_debug("Bandera %s: %s" % ["activada" if value else "desactivada", flag])
	_flags.set_item(flag, value)
```

El método toma dos argumentos: `flag` (un `String` que representa el nombre de la bandera) y `value` (un `bool` que es el nuevo estado de la bandera). Antes de aplicar el cambio, se imprime un mensaje de depuración (`print_debug`) en la consola. Este mensaje indica si la bandera fue "activada" o "desactivada" y cuál es su nombre, lo que resulta útil para el seguimiento y depuración de la lógica del juego durante el desarrollo. La actualización real del valor de la bandera se gestiona mediante el método `set_item()` del recurso `_flags`. Al igual que con `get_flag`, se recomienda revisar el archivo `flags.tres` para ver la lista de banderas que pueden ser modificadas.