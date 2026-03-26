# `BattleWorld`
La clase `BattleWorld` extiende `Node3D` y actúa como el contenedor principal para los elementos visuales y lógicos 3D del escenario de batalla. Su propósito central es la gestión y orquestación de la interacción entre los componentes clave del juego en 3D, como el dado (`Dice`), las rocas seleccionables (`Rocks`), y las representaciones visuales de los jugadores (`Players`).

`BattleWorld` se encarga de:
*   **Almacenar referencias** a los nodos `Dice`, `Rocks` y `Players` exportados desde el editor.
*   **Gestionar el estado** de los elementos 3D, como la lista de rocas (`rocks_list`) y la lista de jugadores (`players_list`).
*   **Centralizar la comunicación** al re-emitir señales importantes (como `dice_thrown` o `rock_selected`) que se originan en sus nodos hijos, lo que permite que otros sistemas (como la interfaz de usuario 2D o la lógica de juego) interactúen con estos elementos sin tener referencias directas a ellos.
*   **Realizar la configuración inicial** de las rocas y el posicionamiento de los jugadores dentro del mundo 3D.

En esencia, `BattleWorld` funciona como una interfaz de alto nivel para los componentes 3D del juego, abstrayendo la complejidad de sus interacciones directas y proporcionando un punto de control unificado para la escena de batalla.

# Métodos

## Métodos de Godot

### `_ready()`
Este método de ciclo de vida de Godot es invocado cuando el nodo y todos sus hijos están listos.
Su función principal es la inicialización:
1.  Llama a `_set_rocks()` para configurar y registrar todas las rocas presentes en la escena, asegurando que estén listas para ser interaccionadas.
2.  Conecta la señal `players_updated` del nodo `players` con una función anónima que re-emite esta misma señal desde `BattleWorld`. Esto permite que cualquier componente que esté escuchando `BattleWorld` pueda recibir notificaciones sobre cambios en la lista de jugadores.

```gdscript
func _ready() -> void:
	_set_rocks()
	players.players_updated.connect(func(new_players): players_updated.emit(new_players))
```

## Otros métodos

### `throw_dice()`
Este método invoca la función `throw_dice()` del nodo `dice` exportado. Está diseñado para ser utilizado cuando se necesita que el dado sea lanzado por la lógica del juego o por bots, en lugar de una interacción directa del jugador.

### `enable_dice(enabled: bool)`
Este método controla la interactividad del dado. Al pasar `true`, el dado se vuelve clickeable; al pasar `false`, se desactiva la posibilidad de interactuar con él. Internamente, simplemente asigna el valor de `enabled` a la propiedad `dice.clickable`.

### `enable_rocks(index: Array)`
Activa un subconjunto de rocas para que sean seleccionables por el jugador.
El método toma un array de índices (`index`). Itera sobre estos índices y para cada uno, establece la propiedad `selectable` de la roca correspondiente en `rocks_list` a `true`, permitiendo la interacción con ellas.

### `_set_rocks()`
Este es un método de configuración crucial que se encarga de inicializar la lista de rocas seleccionables en la escena.
1.  Limpia la `rocks_list` existente.
2.  Itera a través de todos los hijos del nodo `rocks`.
3.  Para cada hijo que sea una instancia de `Rock`, lo añade a `rocks_list` y conecta su señal `rock_selected` al método `_on_rock_selected` de `BattleWorld`. Esto permite que `BattleWorld` capture y re-emita la selección de cualquier roca.
4.  Realiza una comprobación para asegurar que el número de rocas encontradas (`rocks.get_child_count()`) coincide con el número esperado (`rocks.ROCK_COUNT`). Si no coinciden, emite una advertencia de consola, lo cual es útil para la depuración y para mantener la consistencia en el diseño del nivel.
5.  Finalmente, emite la señal `_rocks_ready`, indicando que la configuración de las rocas ha sido completada y que están listas para ser utilizadas por otros componentes, como el posicionamiento de jugadores.

```gdscript
func _set_rocks() -> void:
	# Filtra las rocas y se conecta a cada una
	rocks_list.clear()
	for rock in rocks.get_children():
		if rock is Rock:
			rocks_list.append(rock)
			rock.rock_selected.connect(_on_rock_selected)

	if rocks.get_child_count() != rocks.ROCK_COUNT:
		push_warning(
			"[World] Cantidad de rocas inesperada. Esperado: %s, Obtenido: %s"
			% [rocks.ROCK_COUNT, rocks.get_child_count()]
		)

	_rocks_ready.emit()
```

### `disable_rocks()`
Este método desactiva la interactividad de todas las rocas en la escena. Itera sobre `rocks_list` y establece la propiedad `selectable` de cada roca a `false`, impidiendo que el jugador pueda seleccionarlas. Incluye un `await ready` para asegurar que el nodo esté completamente inicializado antes de intentar acceder a `rocks_list`, previniendo posibles errores en situaciones de carga asíncrona.

### `set_players(new_players: Array[Player])`
Este método es responsable de configurar y posicionar a los jugadores en la escena de batalla.
1.  Recibe un array de objetos `Player` y los almacena en `players_list`.
2.  Llama a `players.add_players(players_list)` para añadir estos jugadores al nodo `players`, que es el encargado de gestionar las representaciones 3D de los jugadores.
3.  Utiliza `await _rocks_ready` para asegurarse de que todas las rocas hayan sido inicializadas y registradas antes de intentar posicionar a los jugadores.
4.  Itera a través de la `players_list`:
    *   Si un jugador no es un bot (`current_player.is_bot` es `false`), su referencia se guarda en la variable `player` para un acceso fácil al jugador humano.
    *   Calcula una `position_idx` para distribuir a los jugadores uniformemente sobre las rocas disponibles, utilizando una lógica de espaciado proporcional.
    *   Mueve al jugador a la posición de la roca calculada utilizando `current_player.move_to()`.
    *   Imprime un mensaje de depuración indicando la posición de cada jugador.
5.  Finalmente, emite la señal `players_ready` una vez que todos los jugadores han sido configurados y posicionados en la escena.

```gdscript
func set_players(new_players: Array[Player]) -> void:
	players_list = new_players
	players.add_players(players_list)

	# Posiciona a los jugadores en rocas igualmente espaciadas
	await _rocks_ready
	for i in range(players_list.size()):
		var current_player := players_list[i]

		# Usamos una referencia aparte para el jugador humano
		if not current_player.is_bot: player = current_player

		# Calculamos la posición y ubicamos
		var position_idx := int((float(i) / players_list.size()) * rocks_list.size())
		current_player.move_to(rocks_list[position_idx].position, position_idx)

		print("[World] %s en índice %s" % [current_player.player_name, position_idx])

	await players_ready
```

## Funciones asociadas a señales

#### `_on_dice_thrown_dice(number: int)`
Este método es una función de *callback* que se ejecuta cuando el nodo `dice` emite su señal `dice_thrown`. Recibe el número resultante del lanzamiento del dado. Su principal función es re-emitir este número a través de la señal `dice_thrown` de `BattleWorld`, sirviendo como un intermediario para que otros sistemas puedan reaccionar al lanzamiento del dado sin necesidad de conectar directamente al nodo `dice`.

#### `_on_rock_selected(selected_rock: Rock)`
Esta función de *callback* se activa cuando una de las rocas en `rocks_list` emite su señal `rock_selected`. Recibe la instancia de la roca que fue seleccionada. El método imprime un mensaje de depuración en la consola, utilizando colores para indicar el elemento de la roca, lo cual es útil para el seguimiento durante el desarrollo. Posteriormente, re-emite la `selected_rock` a través de la señal `rock_selected` de `BattleWorld`, notificando a cualquier oyente externo sobre la roca que ha sido elegida.