# `MainMenu`
Este script, que extiende `Node`, gestiona la lógica principal del menú inicial del juego **Beast Card Clash**. Se encarga de la reproducción de la música de ambiente al iniciar y de la navegación entre las diferentes escenas del juego (selector de personaje, batalla, créditos, tutorial) en respuesta a las interacciones del jugador con los botones correspondientes. También incluye la funcionalidad para salir del juego.

Este componente es crucial para la experiencia de usuario al ser la puerta de entrada al juego, permitiendo a los jugadores elegir su camino dentro de la aplicación.

# Métodos

## Métodos de Godot

### `_ready`
Este método se ejecuta una vez cuando el nodo y todos sus hijos están listos. Su función principal es iniciar la reproducción de la música de fondo del menú.

```gdscript
func _ready() -> void:
	MusicManager.play_music("menu_loop")
```

La reproducción se realiza a través de una llamada al método `play_music` del singleton `MusicManager`, utilizando el identificador `"menu_loop"` para la pista de audio específica del menú.

## Funciones asociadas a señales

#### `_on_play_button_pressed`
Este método se invoca cuando se activa la señal "pressed" de un botón de "Jugar" (o similar). Su propósito es llevar al jugador a la siguiente escena relevante en el flujo del juego.

```gdscript
func _on_play_button_pressed() -> void:
	if FlagsManager.get_flag("character_selected"):
		push_warning("No hay escena de juego")
	else:
		SceneManager.change_to_scene("skin_selector")
```

El método consulta el estado de una bandera `"character_selected"` a través del singleton `FlagsManager`.
- Si la bandera es `true`, lo que implicaría que un personaje ya ha sido seleccionado previamente, se genera una advertencia (`push_warning`) indicando que la escena de juego no está implementada todavía. Esto sugiere un flujo futuro donde se cargaría directamente la partida con el personaje elegido.
- Si la bandera es `false`, el jugador es redirigido a la escena `"skin_selector"` (selector de personaje) utilizando el método `change_to_scene` del singleton `SceneManager`.

#### `_on_quick_play_button_pressed`
Este método se ejecuta cuando se activa la señal "pressed" de un botón de "Partida Rápida". Su función es iniciar una partida de batalla de forma inmediata.

```gdscript
func _on_quick_play_button_pressed() -> void:
	SceneManager.change_to_scene("battle")
```

El método utiliza el singleton `SceneManager` para cambiar la escena actual a la escena `"battle"`, saltándose cualquier proceso de selección de personaje o configuración previa.

#### `_on_credits_button_pressed`
Este método se invoca al activarse la señal "pressed" de un botón de "Créditos". Su propósito es mostrar la información de créditos del juego.

```gdscript
func _on_credits_button_pressed() -> void:
	SceneManager.change_to_scene("credits")
```

Redirige al jugador a la escena `"credits"` mediante el método `change_to_scene` del singleton `SceneManager`.

#### `_on_quit_button_pressed`
Este método se ejecuta cuando se activa la señal "pressed" de un botón de "Salir". Su función es terminar la aplicación.

```gdscript
func _on_quit_button_pressed() -> void:
	get_tree().quit()
```

Llama directamente al método `quit()` del `SceneTree` (`get_tree()`) para cerrar la aplicación del juego.

#### `_on_tutorial_button_pressed`
Este método se activa al presionarse un botón de "Tutorial". Su propósito es guiar al jugador a la escena que contiene el tutorial del juego.

```gdscript
func _on_tutorial_button_pressed() -> void:
	SceneManager.change_to_scene("tutorial")
```

El método utiliza el singleton `SceneManager` para cambiar la escena actual a la escena `"tutorial"`, permitiendo al jugador aprender las mecánicas del juego.