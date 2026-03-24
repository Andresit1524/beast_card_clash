## Clase que almacena los elementos del mundo 3D, de forma diferida al mundo de la interfaz 2D
class_name BattleWorld extends Node3D


## Dado del juego
@export var dice: Dice
## Lista de rocas del mundo
@export var rocks: Rocks
## Lista de jugadores
@export var players: Players


## Activa o desactiva el dado
func set_dice(enabled: bool) -> void:
	dice.clickable = enabled
