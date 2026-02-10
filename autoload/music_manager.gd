extends AudioStreamPlayer

## Lista de canciones disponibles
var _playlist: Playlist = preload("uid://bc3risb100107")

# Revisa al inicio que toda la playlist esté bien definida
func _ready():
	_playlist.expected_type = TYPE_OBJECT
	_playlist.check_item_types()

## Reproduce la canción indicada por su nombre
func play_music(music_name: String) -> void:
	stream = _playlist.get_item(music_name)
	play()

## Alterna o cambia la reproducción la canción actual
func switch_music_playing(on = null) -> void:
	if on == null:
		stream_paused = not stream_paused
		return

	if not (on is bool):
		push_error("Tipo de dato incorrecto en MusicManager. Se espera un valor booleano")

	stream_paused = on
	return
