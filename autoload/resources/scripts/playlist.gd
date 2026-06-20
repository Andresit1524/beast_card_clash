## Playlist es un tipo de recurso que almacena la música y efectos de sonido para su acceso directo
## y descentralizado
class_name Playlist extends Resource


## Lista de canciones
@export var items: Dictionary[StringName, AudioStream]
