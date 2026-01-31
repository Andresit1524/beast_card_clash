extends AudioStreamPlayer

# Lista de canciones disponibles (en la carpeta music)
var playlist: Dictionary[String, AudioStream] = {
    "start_menu": preload("res://music/start_menu_tobyfox.mp3")
}

# Reproduce la canción indicada
func play_music(music_name: String) -> void:
    stream = playlist[music_name]
    play()

# Pausa o reanuda la canción actual
func switch_music_playing() -> void:
    stream_paused = not stream_paused