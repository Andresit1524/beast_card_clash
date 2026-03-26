## StateMachine es la clase base para una máquina de estados. [br]
## Los estados son nodos hijos de tipo [code]BaseState[/code] que contienen la lógica de cada estado
## y se comunican entre si
@icon("res://addons/state_machine/state_machine_icon.svg")
class_name StateMachine extends Node


@export var controlled_node: Node
@export var default_state: BaseState


var states: Dictionary[Script, BaseState] = {}
var current_state: BaseState


#region Preparación


func _ready() -> void:
	if not controlled_node:
		push_error("[StateMachine] No hay nodo objetivo para controlar")
		return

	# Se conecta a todos los estados adjuntos
	for child in get_children():
		if not child.get_script():
			push_error("[StateMachine] El estado %s no tiene un script asignado" % child.name)
			continue

		if not child is BaseState:
			push_error("[StateMachine] El estado %s no es un BaseState" % child.name)
			continue

		states[child.get_script()] = child
		child.to_state.connect(change_to_state)

	# Asigna el estado inicial
	current_state = default_state

	if not current_state:
		push_error("[StateMachine] No hay estado inicial")
		return

	_setup_current_state()


#endregion


## Ejecuta el fin del ciclo de vida de un estado y cambia al que se indique
func change_to_state(next_state: Script) -> void:
	# Fin del estado actual
	if current_state.has_method("exit"): current_state.exit()

	# Busca el nuevo estado, asigna y ejecuta
	current_state = states[next_state] if states.has(next_state) else default_state
	_setup_current_state()


func _process(delta: float) -> void:
	if current_state.has_method("update"): current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state.has_method("physics_update"): current_state.physics_update(delta)


func _setup_current_state() -> void:
	print("[StateMachine] Cambiando a estado %s" % current_state.name)

	current_state.controlled_node = controlled_node
	if current_state.has_method("start"): current_state.start()
