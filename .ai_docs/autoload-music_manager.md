# `MusicManager`
El script `MusicManager` actúa como el controlador centralizado para la reproducción de pistas musicales dentro de **Beast Card Clash**. Al heredar de `AudioStreamPlayer`, aprovecha las capacidades nativas de Godot para manejar buses de audio, efectos y control de flujo de sonido. Su arquitectura se basa en un diccionario de recursos precargados (`_playlist`), lo que permite un acceso rápido a las pistas sin tiempos de carga adicionales durante la ejecución del juego.

Este componente está diseñado para funcionar preferiblemente como un **Singleton (Autoload)**, permitiendo que otros sistemas (como gestores de UI o controladores de batalla) cambien la música ambiental mediante llamadas directas a sus métodos públicos.

```gdscript
var _playlist: Dictionary[String, AudioStream] = {
    "start_menu": preload("uid://cw6yfwstm10it")
}
```

# Métodos

## Otros métodos

### `play_music(music_name: String) -> void`
Este método es el punto de entrada principal para cambiar la pista de audio activa. Recibe una cadena de texto que debe coincidir con una de las llaves definidas en el diccionario `_playlist`.

*   **Funcionamiento:** Asigna el recurso `AudioStream` correspondiente a la propiedad `stream` del nodo y ejecuta el método `play()`.
*   **Nota técnica:** Si el nombre proporcionado no existe en el diccionario, el motor lanzará un error en tiempo de ejecución al intentar acceder a una llave inexistente.

### `switch_music_playing(on = null) -> void`
Controla el estado de pausa de la música actual de forma flexible. Permite tanto el toggle (alternancia) como la definición explícita del estado.

*   **Comportamiento con `null` (por defecto):** Si se llama sin argumentos, invierte el estado actual de `stream_paused`. Es ideal para botones de pausa genéricos.
*   **Comportamiento con `bool`:** Si se pasa `true` o `false`, asigna ese valor directamente a `stream_paused`.
*   **Validación de datos:** El método incluye una comprobación de tipo. Si se pasa un valor que no es booleano ni nulo, el sistema imprime un error en la consola para facilitar el depurado, evitando comportamientos erráticos en el audio.

> [!IMPORTANT]
> El parámetro `on` utiliza un tipado dinámico en la firma pero es validado internamente. Para silenciar la música se debe pasar `true` (pausar) y para reanudar `false`.

```gdscript
if on == null:
    stream_paused = not stream_paused
    return

if not (on is bool):
    print("[Error] Tipo de dato incorrecto en MusicManager.switch_music_playing(). Se espera un valor booleano")
```