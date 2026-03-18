class_name Utilities extends Node


## Imprime un texto con el color. El color puede ser indicado por valor o por nombre
static func print_color(text: String, color: Color) -> void:
	var final_color: String

	if color is Color: final_color = color.to_html()

	print_rich("[color=#%s]%s[/color]" % [final_color, text])


## Imprime un valor de enumerador por su nombre. Indica el valor y luego el tipo enumerador
static func get_enum_name(value: int, enum_type: Dictionary) -> String:
	return enum_type.keys()[value]
