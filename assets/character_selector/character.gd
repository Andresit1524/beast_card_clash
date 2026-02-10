extends CharacterBody3D

## Cuando se clica el personaje, emite su id para establecer la skin
signal skin_selected(index: int)

## Identificador de la skin actual.[br]
##
## Depende de que los nodos se llamen "CharacterN", donde N es el índice
@onready var character_id: int = self.name.trim_prefix("Character") as int

# Al inicio, se conecta a su propia señal de clic (evento)
func _ready():
    self.input_event.connect(_on_input_event)

## Detecta y filtra los clics
func _on_input_event(_c, event: InputEvent, _p, _n, _s):
    if event.is_action_pressed("left_click"):
        skin_selected.emit(character_id)
