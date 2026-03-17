## [code]BaseState[/code] es una clase base para almacenar los estados de una SFM. [br]
## Los estados pueden implementar métodos como [code]start[/code] y [code]update[/code] de forma
## análoga al ciclo de vida de un nodo convencional. [br]
## Todos los métodos son opcionales
@abstract class_name BaseState extends Node


## Nodo a controlar
var controlled_node: Node


## Indica a la máquina de estados que se mueva hacia otro estado.
## Escribe el classname del siguiente estado como un tipo
@warning_ignore("unused_signal")
signal to_state(next_state: Script)


## [code]Start[/code] se ejecuta al principio del estado
func start() -> void:
	pass


## [code]Update[/code] se ejecuta en cada frame
@warning_ignore("unused_parameter")
func update(delta: float) -> void:
	pass


## [code]Physics Update[/code] se ejecuta en cada paso de físicas
@warning_ignore("unused_parameter")
func physics_update(delta: float) -> void:
	pass


## [code]Exit[/code] se ejecuta al salir del estado y antes de empezar el siguiente
func exit() -> void:
	pass
