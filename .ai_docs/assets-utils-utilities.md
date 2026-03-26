# `Utilities`
Este script, definido como una `class_name` `Utilities`, actúa como un contenedor de funciones estáticas de utilidad global dentro del proyecto. Su propósito principal es encapsular funcionalidades comunes que pueden ser reutilizadas en diferentes partes del código sin necesidad de instanciar un nodo `Utilities`. Esto promueve la modularidad y la facilidad de mantenimiento, proporcionando herramientas auxiliares que simplifican tareas recurrentes como la impresión de mensajes con formato o la manipulación de enumeradores.

# Métodos

## Otros métodos

### `print_color(text: String, color: Color) -> void`
Esta función estática permite imprimir un texto en la consola de Godot con un color específico, facilitando la depuración y la diferenciación visual de los mensajes de log. Internamente, convierte el objeto `Color` proporcionado a su representación HTML hexadecimal para ser utilizada por la función `print_rich` de Godot, que soporta tags de formato.

```gdscript
static func print_color(text: String, color: Color) -> void:
	var final_color: String

	# Aunque el tipo de 'color' ya está hintado como Color, esta verificación añade robustez
	# en escenarios donde el tipado dinámico de GDScript podría permitir otro tipo.
	# En el caso ideal, 'color' siempre será un objeto Color.
	if color is Color: final_color = color.to_html()

	print_rich("[color=#%s]%s[/color]" % [final_color, text])
```

**Ejemplo de uso:**
Para imprimir un mensaje de error en rojo o un mensaje de éxito en verde:
```gdscript
Utilities.print_color("¡Error crítico!", Color.RED)
Utilities.print_color("Carga de nivel completada.", Color.GREEN)
Utilities.print_color("Jugador interactuando con objeto.", Color("BLUE")) # También acepta nombres de color CSS válidos si se crea el Color
```
Esta herramienta es particularmente útil para el `BCC DevTeam` para mejorar la legibilidad del output de depuración durante el desarrollo de `Beast Card Clash`, haciendo más eficiente la identificación de eventos o problemas específicos.

### `get_enum_name(value: int, enum_type: Dictionary) -> String`
Esta función estática proporciona una forma conveniente de obtener el nombre (string) de un valor de enumerador dado su valor numérico entero y una representación de su tipo. Espera que `enum_type` sea un `Dictionary` donde las claves son los nombres de los enumeradores (strings) y los valores son sus correspondientes enteros, o directamente el diccionario que representa un enum en GDScript (e.g., `MyEnum`).

```gdscript
static func get_enum_name(value: int, enum_type: Dictionary) -> String:
	return enum_type.keys()[value]
```

**Funcionamiento y Consideraciones:**
En GDScript, un `enum` declarado como `enum { A, B, C }` se puede referenciar como un diccionario que mapea nombres a valores (`{"A": 0, "B": 1, "C": 2}`). La función aprovecha el método `keys()` de este diccionario para obtener un `Array` ordenado de los nombres de los enumeradores. Luego, utiliza el `value` entero proporcionado como índice para acceder al nombre correspondiente en ese `Array`.

**Ejemplo de uso:**
Si tenemos un enumerador para los elementos en el juego `Beast Card Clash`:
```gdscript
# En un script global o donde se defina el enum
enum ElementType { FIRE, WATER, NATURE, NEUTRAL }

# Para usar la función de utilidad
var current_element_value = ElementType.WATER # Esto es 1
var element_name = Utilities.get_enum_name(current_element_value, ElementType)

# 'element_name' contendrá la cadena "WATER"
Utilities.print_color("El elemento actual es: %s" % element_name, Color.YELLOW)
```
Esta función simplifica la tarea de mostrar o loggear los nombres legibles de los enumeradores, lo cual es fundamental para la claridad del código y los mensajes de depuración, especialmente en un juego con varios tipos de cartas y elementos.