extends AudioStreamPlayer

## Lista de canciones disponibles (en la carpeta [code]music[/code])
var playlist: Dictionary[String, AudioStream] = {
    "start_menu": preload("res://music/start_menu_tobyfox.mp3")
}

## Reproduce la canción indicada por su nombre exacto.
## Consulta en el singleton por los nombres dispoibles
func play_music(music_name: String) -> void:
    stream = playlist[music_name]
    play()

## Alterna o cambia la reproducción la canción actual
func switch_music_playing(on = null) -> void:
    if on == null:
        stream_paused = not stream_paused
        return

    # Error: no es un valor booleano
    if not (on is bool):
        print("[Error] Tipo de dato incorrecto en MusicManager.switch_music_playing(). Se espera un valor booleano")

    stream_paused = on
    return
