## Clase que maneja los datos de la partida de forma centralizada y conectando las piezas del escenario
class_name BattleManager extends Node


const MAX_PLAYERS := 4


## Gestor de la interfaz de batalla
@export var battle_ui: BattleUI


var player: Player
var players: Array[Player]
var rocks: Array[RockScene.Rock]
