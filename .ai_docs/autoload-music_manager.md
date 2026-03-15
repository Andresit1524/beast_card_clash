# `MusicManager`
Este script extiende la funcionalidad del nodo `AudioStreamPlayer` de Godot, sirviendo como un gestor centralizado para la reproducción de música de fondo en el juego **Beast Card Clash**. Su propósito principal es facilitar la carga, reproducción, pausa y control de las distintas pistas musicales que ambientan el juego, utilizando un recurso `Playlist` predefinido para organizar la banda sonora.

Al centralizar la gestión de la música, `MusicManager` permite que otros componentes del juego (como controladores de escenas, menús o estados de juego) puedan solicitar la reproducción de una pieza musical específica por su nombre, sin necesidad de manejar directamente los objetos `AudioStream` o la lógica de `AudioStreamPlayer`. Esto contribuye a una mejor estructura y organización del código, alineándose con el objetivo de facilitar el desarrollo para los programadores del proyecto.

# Métodos

## Métodos de Godot

### `_ready()`
Este método de callback de Godot se ejecuta una vez que el nodo `MusicManager` ha entrado en el árbol de escenas. Su función principal es realizar una inicialización y una verificación de integridad del recurso `_playlist` que contiene la colección de música.

```gdscript
func _ready():
	_playlist.expected_type = TYPE_OBJECT
	_playlist.check_item_types()
```
En esta sección, se establece la propiedad `expected_type` del recurso `_playlist` a `TYPE_OBJECT`. `TYPE_OBJECT` es una constante de Godot que representa un tipo de dato genérico para objetos. Aunque el contexto de un `AudioStreamPlayer` sugiere que la playlist almacenará `AudioStream`s, la configuración a `TYPE_OBJECT` indica que el recurso `Playlist` está diseñado para ser flexible o que los elementos se manejan como objetos genéricos antes de ser asignados al `stream`.

Posteriormente, se llama al método `check_item_types()` del recurso `_playlist`. Esta llamada implica que el `Playlist` tiene una lógica interna para validar que todos los elementos que contiene son del `expected_type` configurado. Esto es una buena práctica para asegurar que los datos de la playlist sean válidos y consistentes antes de que cualquier música sea solicitada para reproducción.

## Otros métodos

### `play_music(music_name: String) -> void`
Este método es la interfaz principal para iniciar la reproducción de una pista musical específica dentro del juego.

```gdscript
func play_music(music_name: String) -> void:
	stream = _playlist.get_item(music_name)
	play()
```
Recibe un argumento `music_name` de tipo `String`, que sirve como identificador de la canción deseada. Utiliza este nombre para recuperar el objeto `AudioStream` correspondiente del recurso `_playlist` mediante el método `get_item()`. Se asume que el `_playlist` mapea nombres de canciones a sus respectivos `AudioStream`s.

Una vez que se obtiene el `AudioStream`, se asigna a la propiedad `stream` del nodo `AudioStreamPlayer` base. Finalmente, se invoca el método `play()` del `AudioStreamPlayer` para comenzar la reproducción de la música seleccionada. Este enfoque permite que la lógica de selección y asignación de música esté desacoplada de la lógica de reproducción, simplificando el control de la banda sonora del juego.

### `switch_music_playing(on = null) -> void`
Este método proporciona control sobre el estado de pausa/reproducción de la música actual, permitiendo tanto alternar su estado como establecerlo explícitamente.

```gdscript
func switch_music_playing(on = null) -> void:
	if on == null:
		stream_paused = not stream_paused
		return

	if not (on is bool):
		push_error("Tipo de dato incorrecto en MusicManager. Se espera un valor booleano")

	stream_paused = on
	return
```
*   **Alternar el estado:** Si el parámetro `on` no se proporciona (es decir, su valor es `null`), el método invierte el valor de la propiedad `stream_paused` del `AudioStreamPlayer` base. Esto significa que si la música estaba reproduciéndose, se pausará; si estaba pausada, se reanudará. Este comportamiento es útil para funcionalidades como botones de pausa/reproducir o al entrar/salir de un menú.

*   **Establecer el estado explícitamente:** Si se proporciona un valor para `on`, el método primero realiza una verificación de tipo para asegurar que `on` es un `bool`. Si no lo es, se utiliza `push_error()` para emitir un mensaje de error en la consola de Godot, indicando un uso incorrecto del método. Si `on` es un booleano válido, la propiedad `stream_paused` se establece directamente con este valor. Por ejemplo, `switch_music_playing(true)` pausaría la música, y `switch_music_playing(false)` la reanudaría.

Este método es fundamental para la interacción de la interfaz de usuario y los eventos del juego que requieren controlar el flujo de la música, como pausar la música al abrir el menú de pausa o reanudarla al volver al juego.