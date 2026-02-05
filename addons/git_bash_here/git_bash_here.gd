@tool
extends EditorPlugin

const PLUGIN_PATH := "plugins/git_bash_here/shortcut"

var shortcut: Shortcut
var shortcut_res: Shortcut = preload("res://addons/git_bash_here/git_bash_here_shortcut.tres")
var timer: SceneTreeTimer

func _enter_tree():
	# On startup or activation, set shortcut
	shortcut = set_shortcut(PLUGIN_PATH, shortcut_res)


func _exit_tree():
	# On exit or deactivation, remove shortcut and ProjectSetting path
	shortcut = null
	ProjectSettings.clear(PLUGIN_PATH)
	ProjectSettings.save()

func _shortcut_input(event: InputEvent) -> void:
	# Will only be called once when pressed
	if not event.is_pressed() or event.is_echo(): return
	if shortcut.matches_event(event):
		git_bash_here()

func set_shortcut(project_setting_path: String, resource: Shortcut) -> Shortcut:
	ProjectSettings.set_setting(PLUGIN_PATH, resource)
	return resource

func git_bash_here() -> void:
	#New call delay
	if timer and timer.time_left:
		return
	timer = get_tree().create_timer(2.5)
	
	
	var path: String = ProjectSettings.globalize_path("res://") ## Project global path
	var command: String = 'cd %s  && start "" "C:\\Program Files\\Git\\bin\\sh.exe" && exit' % path

	OS.create_process("cmd.exe", ["/c", command], true)
