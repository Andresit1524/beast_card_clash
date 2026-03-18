# `TutorialPanelManager`
El script `TutorialPanelManager` extiende la clase `Node` y actúa como el controlador principal para la presentación y navegación de una serie de paneles visuales, que en el contexto de **Beast Card Clash**, se utilizan para el tutorial del juego. Este componente gestiona la lógica para avanzar entre los paneles, la opción de saltar el tutorial completo y la funcionalidad para retornar al menú principal.

Su funcionamiento se basa en la gestión de un array de texturas y un nodo `TextureRect` en la escena. El script inicializa el tutorial mostrando el primer panel y luego responde a las interacciones del usuario (presiones de botones) para cambiar los paneles o gestionar las transiciones de escena.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez que el nodo `TutorialPanelManager` y todos sus hijos han entrado en el árbol de escenas. Su propósito es inicializar la visualización del tutorial.

```gdscript
func _ready() -> void:
	panel_node.texture = panels_list[0]
```

Al inicio, se encarga de:
1.  Asignar la primera `Resource` (presumiblemente una `Texture2D`) del array `panels_list` a la propiedad `texture` del nodo `panel_node`. Esto asegura que el primer panel del tutorial sea visible tan pronto como la escena se cargue.

## Funciones asociadas a señales

#### `_on_next_button_pressed()`
Este método está diseñado para ser conectado a la señal `pressed()` de un botón de "Siguiente" en la interfaz de usuario. Su función es avanzar al siguiente panel del tutorial.

```gdscript
func _on_next_button_pressed() -> void:
	current_panel += 1

	if current_panel >= panels_list.size():
		_on_skip_button_pressed()
		return

	panel_node.texture = panels_list[current_panel]
```

El flujo de este método es el siguiente:
1.  **Incrementa el índice:** Aumenta en uno el valor de la variable `current_panel`, que rastrea el panel actual.
2.  **Verificación de límite:** Comprueba si `current_panel` ha superado el número total de paneles disponibles en `panels_list`.
    *   Si `current_panel` es igual o mayor que el tamaño del array, significa que se han visto todos los paneles. En este caso, se llama al método `_on_skip_button_pressed()` para finalizar el tutorial.
    *   Si todavía hay paneles disponibles, se continúa con el siguiente paso.
3.  **Actualización del panel:** La `texture` del nodo `panel_node` se actualiza con la `Resource` correspondiente al nuevo `current_panel` del `panels_list`, mostrando así el siguiente panel.

#### `_on_skip_button_pressed()`
Esta función está destinada a ser conectada a la señal `pressed()` de un botón de "Saltar Tutorial".

```gdscript
func _on_skip_button_pressed() -> void:
	print_debug("¡Salta el tutorial!")
```

Actualmente:
1.  **Imprime un mensaje de depuración:** Solo se muestra un mensaje en la consola de salida, indicando que la función ha sido invocada.

> [!NOTE]
> Actualmente, esta función es un **marcador de posición**. Su implementación futura debería gestionar la transición del jugador fuera del tutorial, ya sea al juego principal o a un menú específico, sin necesidad de pasar por todos los paneles.

#### `_on_back_button_pressed()`
Este método se espera que esté conectado a la señal `pressed()` de un botón de "Atrás" o "Menú Principal".

```gdscript
func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("start_menu")
```

Su única acción es:
1.  **Cambiar de escena:** Llama a la función `change_to_scene()` del singleton global `SceneManager`, pasándole la cadena `"start_menu"`. Esto indica al sistema de gestión de escenas que el juego debe cargar la escena correspondiente al menú de inicio.

---

### Interacciones y dependencias

El script `TutorialPanelManager` interactúa con varios componentes externos:

*   **`panels_list: Array[Resource]`**: Es un array que debe ser poblado con recursos de textura (e.g., `Texture2D`) a través del editor de Godot. Cada elemento de este array representa un panel individual del tutorial.
*   **`panel_node: TextureRect`**: Es una referencia a un nodo `TextureRect` en la escena, también configurado desde el editor. Este `TextureRect` es el componente visual donde se mostrarán las texturas de los paneles del tutorial.
*   **Botones de UI**: Requiere de botones en la escena (`next_button`, `skip_button`, `back_button`) cuyas señales `pressed()` estén conectadas a los métodos `_on_next_button_pressed()`, `_on_skip_button_pressed()` y `_on_back_button_pressed()` respectivamente.
*   **`SceneManager`**: Depende de un singleton (AutoLoad) llamado `SceneManager` que exponga un método estático o de instancia `change_to_scene(scene_path: String) -> void` para gestionar las transiciones entre escenas del juego. El script asume que `"start_menu"` es una ruta de escena válida para el menú principal.