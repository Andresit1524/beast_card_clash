# `TutorialController`
Este script gestiona la presentación y navegación a través de una secuencia de paneles visuales, sirviendo como base para un tutorial, una introducción al juego o una presentación informativa. Controla la lógica para avanzar entre paneles, saltar la secuencia completa o regresar al menú principal. Su funcionamiento se basa en un array de recursos gráficos (presumiblemente `Texture2D`) y un nodo `TextureRect` para la visualización.

El propósito principal es guiar al jugador o usuario a través de información secuencial de una manera sencilla y controlable, facilitando la integración de contenido educativo o de bienvenida al proyecto "Beast Card Clash".

# Métodos

## Métodos de Godot

### `_ready`
Este método de ciclo de vida de Godot es invocado automáticamente una vez que el nodo y todos sus hijos han sido inicializados y añadidos al árbol de la escena. Su función principal es asegurar que el primer panel de la secuencia se muestre al inicio.

```gdscript
func _ready() -> void:
	panel_node.texture = panels_list[0]
```

La línea de código anterior asigna la primera textura del array `panels_list` (que contiene los recursos gráficos de los paneles) a la propiedad `texture` del nodo `panel_node`. Esto garantiza que, al cargar la escena que utiliza este controlador, el usuario vea inmediatamente el panel inicial.

## Funciones asociadas a señales

#### `_on_next_button_pressed: void`
Este método está diseñado para ser conectado a la señal de un botón de "Siguiente" en la interfaz de usuario, permitiendo al jugador avanzar al siguiente panel de la secuencia.

```gdscript
func _on_next_button_pressed() -> void:
	current_panel += 1

	if current_panel >= panels_list.size():
		_on_skip_button_pressed()
		return

	panel_node.texture = panels_list[current_panel]
```

Al ser invocado:
1.  Incrementa el índice `current_panel` para apuntar al siguiente panel.
2.  Verifica si el `current_panel` ha superado el número total de paneles en `panels_list`. Si es así (lo que significa que se han visto todos los paneles), invoca el método `_on_skip_button_pressed()` para finalizar la secuencia, asumiendo que el "siguiente" después del último panel es equivalente a "saltar" o "finalizar".
3.  Si aún quedan paneles por mostrar, actualiza la propiedad `texture` de `panel_node` con el recurso gráfico correspondiente al nuevo `current_panel`, mostrando así el siguiente panel.

#### `_on_skip_button_pressed: void`
Este método está destinado a ser activado por la señal de un botón de "Saltar" en la interfaz de usuario, proporcionando una opción para que el jugador omita el resto de la secuencia de paneles.

```gdscript
func _on_skip_button_pressed() -> void:
	print_debug("¡Salta el tutorial!")
```

Actualmente, este método contiene una funcionalidad de *placeholder*. Simplemente imprime un mensaje de depuración en la consola indicando que el tutorial ha sido saltado. La nota `! Por ahora no está la acción para esto` en el script original indica que la implementación final para transicionar fuera del tutorial (por ejemplo, cargar otra escena) está pendiente y se desarrollará en futuras iteraciones del proyecto.

#### `_on_back_button_pressed: void`
Este método espera ser conectado a la señal de un botón de "Atrás" en la interfaz de usuario, permitiendo al jugador salir de la secuencia de paneles actual y regresar a una escena específica, en este caso, el menú principal.

```gdscript
func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("start_menu")
```

El método realiza una llamada a `SceneManager.change_to_scene("start_menu")`. Esto implica la existencia de un *singleton* global o un *autoload* llamado `SceneManager` en la arquitectura del proyecto, el cual es responsable de manejar las transiciones entre escenas. La cadena `"start_menu"` es el identificador reconocido por el `SceneManager` para cargar la escena del menú principal del juego.