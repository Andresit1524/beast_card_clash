extends AudioStreamPlayer

## Lista de canciones disponibles
var _playlist: Playlist = preload("res://autoload/resources/playlist.tres")

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
