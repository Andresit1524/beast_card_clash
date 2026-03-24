class_name EndUI extends Control


const FADE_TIME := 0.5


@export var ui_visible: bool = false:
	set(value):
		ui_visible = value
		set_ui_visible(value)


@onready var blur_rect: ColorRect = %BlurRect
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	exit_button.pressed.connect(_quit_battle)


## Establece la visibilidad de la interfaz de usuario con un efecto de fade
func set_ui_visible(value: bool) -> void:
	var tween := create_tween()

	if not value:
		tween.tween_property(self, "modulate", Color.TRANSPARENT, FADE_TIME)
		tween.tween_callback(func(): visible = false)
		return

	visible = true
	modulate = Color.TRANSPARENT
	tween.tween_property(self, "modulate", Color.WHITE, FADE_TIME)
	return


## Se sale de la batalla
func _quit_battle() -> void:
	ui_visible = false
	SceneManager.change_to_scene("start_menu")
