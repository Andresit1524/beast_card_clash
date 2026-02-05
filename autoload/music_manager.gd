extends AudioStreamPlayer

## Lista de canciones disponibles (en la carpeta [code]music[/code])
var _playlist: Dictionary[String, AudioStream] = {
    "start_menu": preload("uid://cw6yfwstm10it")
}

## Reproduce la canción indicada por su nombre exacto.
## Consulta en el singleton por los nombres dispoibles
func play_music(music_name: String) -> void:
    stream = _playlist[music_name]
    play()

## Alterna o cambia la reproducción la canción actual
func switch_music_playing(on = null) -> void:
    if on == null:
        stream_paused = not stream_paused
        return

    # Error: no es un valor booleano
    if not (on is bool):
        push_error("Tipo de dato incorrecto en MusicManager. Se espera un valor booleano")

    stream_paused = on
    return
