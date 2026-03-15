# `TeamSelector`
Este script de interfaz de usuario (`Control`) es responsable de gestionar la selección del equipo del jugador y la entrada de su nombre de usuario. Actúa como el puente entre la interacción del jugador en la pantalla de selección de equipo y la persistencia de estos datos para el resto del juego.

El script exporta referencias a un `ButtonGroup` para los botones de selección de equipo, un `LineEdit` para el nombre del jugador y un `Button` para confirmar la selección. Internamente, mantiene un registro del equipo actualmente seleccionado (`current_team`) y gestiona la lógica de validación antes de permitir al jugador continuar.

La funcionalidad principal incluye:
1.  **Manejo de la selección de equipo:** Permite al jugador elegir uno de los equipos disponibles (que corresponden a facultades de la UNAL, como se menciona en el `README.md`).
2.  **Validación de entrada:** Asegura que el jugador haya ingresado un nombre y seleccionado un equipo antes de avanzar.
3.  **Persistencia de datos:** Almacena el nombre y el equipo seleccionado en un componente global (`PlayerStats`) y actualiza el estado del juego mediante otro componente global (`FlagsManager`).
4.  **Navegación:** Permite regresar a la pantalla de selección de aspectos (`skin_selector`).

# Métodos

## Métodos de Godot

### `_ready`
Este método es parte del ciclo de vida de Godot y se ejecuta una vez cuando el nodo y todos sus hijos entran en el árbol de escena. Su propósito principal es configurar las conexiones de señales necesarias.

```gdscript
func _ready():
	teams_button_group.pressed.connect(set_team)
```

En este caso, conecta la señal `pressed` del `teams_button_group` al método `set_team`. Esto significa que cada vez que uno de los botones miembros de este grupo sea presionado, el método `set_team` será invocado, pasando como argumento el `TextureButton` que fue presionado. Este enfoque centraliza la gestión de las interacciones de los botones de equipo, funcionando como un grupo de "radio buttons" donde solo uno puede estar activo a la vez.

## Otros métodos

### `set_team(team_node: TextureButton)`
Este método se invoca cuando se presiona cualquiera de los botones dentro del `teams_button_group`. Su función es determinar qué equipo ha sido seleccionado, actualizar el estado interno del script y proporcionar una retroalimentación visual al jugador.

```gdscript
func set_team(team_node: TextureButton):
	# ... (código de selección de equipo) ...

	for button in teams_button_group.get_buttons():
		button.modulate = Color.DIM_GRAY if button.button_pressed else Color.WHITE

	print_debug("Equipo elegido: ", current_team as GameConstants.Teams)
```

El método opera de la siguiente manera:
1.  **Identificación del equipo:** Utiliza un bloque `match` para comparar el nombre del padre del `team_node` (el botón que fue presionado) con una lista predefinida de nombres de equipos. El nombre del nodo padre se usa como identificador del equipo.
    ```gdscript
    match team_node.get_parent().name:
        "NoTeam":
            current_team = GameConstants.Teams.NO_TEAM
        # ... otros equipos ...
    ```
    Los valores de equipo (`GameConstants.Teams.NO_TEAM`, etc.) provienen de una enumeración global `GameConstants`, lo que asegura consistencia y facilidad de mantenimiento.
2.  **Actualización del `current_team`:** Asigna el valor numérico del equipo seleccionado a la variable `current_team`.
3.  **Feedback visual:** Itera sobre todos los botones del `teams_button_group`. El botón que está actualmente presionado (`button.button_pressed`) se atenúa (`Color.DIM_GRAY`), mientras que los demás se restauran a su color normal (`Color.WHITE`). Esto simula el comportamiento visual de un radio button.
4.  **Depuración:** Imprime en la consola de depuración el equipo que ha sido elegido, lo cual es útil durante el desarrollo.

### `submit_and_play()`
Este método se encarga de validar las entradas del jugador (nombre y equipo) y, si son válidas, de almacenar estos datos y preparar el juego para iniciar.

```gdscript
func submit_and_play():
	if not line_edit_node.text:
		push_warning("Nombre vacío")
		line_edit_node.placeholder_text = "¡Nombre vacío!"
		return

	if current_team == -1:
		push_warning("Equipo vacío")
		submit_button.text = "¡Equipo vacío!"
		for button in teams_button_group.get_buttons():
			button.modulate = Color(0.887, 0.359, 0.359)
		return

	PlayerStats.team = current_team as GameConstants.Teams
	PlayerStats.player_name = line_edit_node.text

	FlagsManager.set_flag("character_selected", true)
	push_warning("No hay escena de juego")
```

La secuencia de operaciones es la siguiente:
1.  **Validación de nombre:** Primero, comprueba si el `line_edit_node` (el campo de entrada de texto) está vacío. Si lo está, emite una advertencia (`push_warning`), actualiza el texto de marcador de posición del `LineEdit` para indicar el error y detiene la ejecución del método.
2.  **Validación de equipo:** Luego, verifica si `current_team` aún es `-1`, lo que indica que no se ha seleccionado ningún equipo. En este caso, emite una advertencia, cambia el texto del `submit_button` para informar al jugador y resalta visualmente todos los botones de equipo en un color rojizo para indicar la necesidad de una selección.
3.  **Persistencia de datos:** Si ambas validaciones son exitosas, los datos del jugador se almacenan:
    *   `PlayerStats.team = current_team as GameConstants.Teams`: Asigna el equipo seleccionado a la variable `team` del componente global `PlayerStats`.
    *   `PlayerStats.player_name = line_edit_node.text`: Asigna el nombre ingresado a la variable `player_name` del mismo componente `PlayerStats`.
    Esto sugiere que `PlayerStats` es un *singleton* o *autoload* que gestiona los datos del jugador a lo largo de las escenas.
4.  **Actualización de flags:** `FlagsManager.set_flag("character_selected", true)` establece un *flag* global indicando que la selección del personaje ha sido completada. `FlagsManager` es presumiblemente otro *singleton* que maneja el estado general del juego.
5.  **Advertencia de desarrollo:** `push_warning("No hay escena de juego")` es una nota interna para los desarrolladores, indicando que la transición a la escena de juego real no está implementada directamente en este script o que la escena de destino aún no existe. Esto implica que la lógica para iniciar el juego se manejará en otro lugar, quizás escuchando la actualización del *flag* `character_selected`.

## Funciones asociadas a señales

#### `_on_back_button_pressed() -> void`
Este método es un *callback* para la señal `pressed` de un botón "Volver" (no exportado directamente en este script, pero implícito por su nombre). Su función es navegar de vuelta a la escena de selección de aspectos.

```gdscript
func _on_back_button_pressed() -> void:
	SceneManager.change_to_scene("skin_selector")
```

Utiliza el componente global `SceneManager` para realizar la transición a la escena nombrada `"skin_selector"`. Esto indica que `SceneManager` es un *singleton* o *autoload* encargado de gestionar los cambios entre las diferentes escenas del juego, como se alinea con el contexto del `README.md` que menciona un "selector de aspectos".