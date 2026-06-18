## Permite reproducir de forma sencilla cualquier sonido necesario. Añada el recurso a playlist.tres
## para ello primero.
extends AudioStreamPlayer


## Lista de canciones disponibles
var _playlist: Playlist = preload("uid://bc3risb100107")


# Revisa al inicio que toda la playlist esté bien definida
func _ready() -> void:
	_playlist.expected_type = TYPE_OBJECT
	_playlist.check_item_types()


## Reproduce la canción indicada por su nombre
func play_music(music_name: String) -> void:
	stream = _playlist.get_item(music_name)
	play()
