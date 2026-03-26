# `team_selector`
Este script `Control` gestiona la interfaz de usuario para la selección de equipo y la introducción del nombre de jugador. Es un componente crucial en el flujo de configuración inicial del jugador en Beast Card Clash. Su función principal es permitir al jugador elegir uno de los equipos disponibles, ingresar un nombre de usuario y luego validar estas selecciones antes de proceder. También facilita la navegación de regreso a la pantalla de selección de aspectos si el jugador lo desea.

El script se encarga de:
*   Manejar la lógica detrás de un grupo de botones de equipo con comportamiento de "radio button".
*   Capturar el nombre ingresado por el jugador.
*   Validar que tanto el nombre como el equipo hayan sido seleccionados.
*   Actualizar las estadísticas globales del jugador (`PlayerStats`) con la información elegida.
*   Gestionar el cambio de escenas para la navegación.

# Métodos

## Métodos de Godot

### `_ready()`
Este método de Godot se llama una vez que el nodo y todos sus hijos han entrado en el árbol de la escena. Su propósito en este script es inicializar el comportamiento del grupo de botones de equipo.

```gdscript
func _ready():
	teams_button_group.pressed.connect(set_team)
```

Aquí, la señal `pressed` del nodo `teams_button_group` (que es un `ButtonGroup` exportado) se conecta al método `set_team`. Esto asegura que cada vez que un `TextureButton` miembro de `teams_button_group` sea presionado, el método `set_team` se invocará automáticamente, permitiendo que el script reaccione a la selección del jugador y actualice el estado del equipo. El comentario en el código fuente explica que el `ButtonGroup` centraliza las señales y proporciona el comportamiento de "Radio Button" (solo un botón seleccionado a la vez).

## Otros métodos

### `set_team(team_node: TextureButton)`
Este método es responsable de establecer el equipo actual (`current_team`) del jugador basándose en el botón de equipo que ha sido presionado.

```gdscript
func set_team(team_node: TextureButton):
	# VA-Games no es equipo elegible, ergo, no aparece. No lo añadas
	match team_node.get_parent().name:
		"NoTeam":
			current_team = GameConstants.Teams.NO_TEAM
		"Acetiles":
			current_team = GameConstants.Teams.ACETILES
		"ADN":
			current_team = GameConstants.Teams.ADN
		"IngeniososElementales":
			current_team = GameConstants.Teams.INGENIOSOS_ELEMENTALES
		"PhotoAgros":
			current_team = GameConstants.Teams.PHOTO_AGROS
		"PlumaDorada":
			current_team = GameConstants.Teams.PLUMA_DORADA
		"RCPTeam":
			current_team = GameConstants.Teams.RPC_TEAM
		"RealPincel":
			current_team = GameConstants.Teams.REAL_PINCEL
		"Zootecnicos":
			current_team = GameConstants.Teams.ZOOTECNICOS

	# Oscurece el boton presionado y resetea los demás
	for button in teams_button_group.get_buttons():
		button.modulate = Color.DIM_GRAY if button.button_pressed else Color.WHITE

	print_debug("Equipo elegido: ", current_team as GameConstants.Teams)
```

1.  **Determinación del Equipo:** Utiliza una sentencia `match` para comparar el `name` del nodo padre del `team_node` (el `TextureButton` presionado). Según el nombre, asigna el valor correspondiente de la enumeración `GameConstants.Teams` a la variable `current_team`. El comentario `VA-Games no es equipo elegible, ergo, no aparece. No lo añadas` es una nota importante para futuros desarrolladores sobre la lógica de selección.
2.  **Feedback Visual:** Itera sobre todos los botones dentro de `teams_button_group`. Si un botón está presionado, su `modulate` se establece en `Color.DIM_GRAY` para oscurecerlo, indicando visualmente que está seleccionado. Los demás botones se restablecen a `Color.WHITE`.
3.  **Depuración:** Imprime un mensaje de depuración con el equipo seleccionado en la consola.

### `submit_and_play()`
Este método se encarga de la validación final y la transición una vez que el jugador ha terminado de seleccionar su equipo y de ingresar su nombre.

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

1.  **Validación del Nombre:** Primero, verifica si el campo `line_edit_node.text` está vacío. Si lo está, emite una advertencia (`push_warning`), actualiza el `placeholder_text` del `LineEdit` para indicar el error y detiene la ejecución del método.
2.  **Validación del Equipo:** Luego, comprueba si `current_team` sigue siendo `-1` (el valor inicial, que indica que no se ha seleccionado ningún equipo). Si es así, emite una advertencia, cambia el texto del `submit_button` para indicar el error y modula el color de todos los botones del equipo a un tono rojizo para resaltar la falta de selección. También detiene la ejecución.
3.  **Actualización de `PlayerStats`:** Si ambas validaciones pasan, el `current_team` seleccionado se asigna a `PlayerStats.team` (asegurando la conversión al tipo `GameConstants.Teams`), y el texto del `line_edit_node` se asigna a `PlayerStats.player_name`. Esto actualiza las estadísticas globales del jugador.
4.  **Actualización de `FlagsManager`:** Se establece la bandera `character_selected` en `true` a través de `FlagsManager.set_flag()`, lo que probablemente indica que el jugador ha completado la configuración de su personaje y equipo.
5.  **Advertencia de Escena:** Finalmente, emite una advertencia (`push_warning`) indicando que "No hay escena de juego". Esto sugiere que la funcionalidad para cambiar a la escena de juego principal aún no está implementada o conectada, y es una nota para los desarrolladores.

## Funciones asociadas a señales

#### `_on_back_button_pressed() -> void`
Esta función es un *callback* (método de retorno de llamada) para la señal `pressed` de un botón llamado `back_button` (o similar, por convención de Godot).

Explica la señal a la que apunta y que hace el método:
Cuando el botón al que está conectada esta función es presionado, el método `SceneManager.change_to_scene("skin_selector")` se ejecuta. Esto indica que el botón tiene la finalidad de permitir al jugador regresar a la escena de "selección de aspectos", la cual probablemente es una pantalla anterior en el flujo de configuración del jugador. `SceneManager` es un `Singleton` global (o un AutoLoad) que se encarga de la gestión de cambio de escenas.