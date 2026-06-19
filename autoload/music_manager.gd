## Permite reproducir de forma sencilla cualquier sonido necesario. Añada el recurso a playlist.tres
## para ello primero.
extends AudioStreamPlayer


## Recurso con las canciones y efectos
var _playlist: Playlist = preload("res://autoload/resources/playlist.tres")


## Reproduce la canción indicada por su nombre
func play_music(track_name: StringName) -> void:
	stream = _playlist.items[track_name]
	play()
