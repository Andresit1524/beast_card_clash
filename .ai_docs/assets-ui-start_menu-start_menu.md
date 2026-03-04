# `main_menu`
Este script extiende `Node` y es el encargado de gestionar la lógica principal del menú inicial del juego. Su función principal es inicializar la música al cargar el menú y responder a las interacciones del usuario con los botones de la interfaz, delegando la gestión de escenas y la salida de la aplicación a sistemas de gestión centralizados.

# Métodos

## Métodos de Godot

### `_ready()`
Este método de ciclo de vida de Godot es invocado una vez cuando el nodo `main_menu` entra en el árbol de escenas y está listo. Su responsabilidad es iniciar la reproducción de la música designada para el menú principal.

```gdscript
func _ready() -> void:
	MusicManager.play_music("start_menu")
```

Utiliza el singleton `MusicManager` (presumiblemente un AutoLoad) para reproducir la pista de audio identificada como `"start_menu"`. Esto asegura que el ambiente sonoro del menú se establezca correctamente al inicio.

## Funciones asociadas a señales

#### `_on_play_button_pressed()`
Este método se ejecuta en respuesta a la señal `pressed()` emitida por un botón de interfaz de usuario (UI) que actúa como el botón "Jugar". Su lógica determina si el juego debe pasar al selector de personaje o si el jugador ya tiene un personaje seleccionado y, por lo tanto, debería ir directamente a la escena de juego.

```gdscript
func _on_play_button_pressed() -> void:
	if FlagsManager.get_flag("character_selected"):
		push_warning("No hay escena de juego")
	else:
		SceneManager.change_to_scene("skin_selector")
```

1.  **Verificación de Bandera:** Consulta el singleton `FlagsManager` (un AutoLoad para gestionar estados globales) para verificar el valor de la bandera `"character_selected"`.
2.  **Lógica Condicional:**
    *   Si `character_selected` es `true`, indica que un personaje ya ha sido elegido. Actualmente, esta rama produce una advertencia en la consola de Godot (`push_warning`) señalando que la escena de juego aún no está implementada.
    *   Si `character_selected` es `false`, significa que el jugador necesita seleccionar un personaje. En este caso, el método utiliza el singleton `SceneManager` (otro AutoLoad para la gestión de escenas) para cargar la escena `"skin_selector"`.

#### `_on_credits_button_pressed()`
Este método se invoca cuando el botón de "Créditos" de la UI es presionado. Su única función es transicionar a la escena que muestra los créditos del juego.

```gdscript
func _on_credits_button_pressed() -> void:
	SceneManager.change_to_scene("credits")
```

Para realizar la transición, utiliza el singleton `SceneManager` para cargar la escena `"credits"`.

#### `_on_quit_button_pressed()`
Este método se activa al presionar el botón de "Salir" en la UI. Su propósito es finalizar la aplicación del juego de manera inmediata.

```gdscript
func _on_quit_button_pressed() -> void:
	get_tree().quit()
```

Accede al objeto `SceneTree` global a través de `get_tree()` y llama a su método `quit()` para cerrar la aplicación.

#### `_on_tutorial_button_pressed()`
Este método se ejecuta al presionar el botón de "Tutorial" en la UI. Su objetivo es cambiar a la escena que contiene la información o la secuencia del tutorial del juego.

```gdscript
func _on_tutorial_button_pressed() -> void:
	SceneManager.change_to_scene("tutorial")
```

Similar a otros métodos de navegación, utiliza el singleton `SceneManager` para cargar la escena `"tutorial"`.