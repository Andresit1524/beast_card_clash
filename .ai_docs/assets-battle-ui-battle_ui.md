# `BattleUI`
`BattleUI` es una clase `Node` diseñada para centralizar y gestionar los componentes de la interfaz de usuario (UI) específicos del escenario de batalla en **Beast Card Clash**. Actúa como un punto de acceso único para otros sistemas del juego que necesitan interactuar con la UI de la batalla, como el gestor de juego principal o el controlador de turnos. Su propósito principal es encapsular las referencias a nodos UI críticos y proporcionar métodos para actualizarlos de manera coherente, facilitando así el desarrollo y mantenimiento del estado visual del juego durante una partida.

Esta clase expone las siguientes referencias de nodos, que deben ser asignadas desde el editor de Godot o mediante código:

*   `hand: Hand`: Una referencia al nodo que gestiona y muestra la mano de cartas del jugador.
*   `player_panel: PlayerPanel`: Una referencia al panel de UI que muestra las estadísticas y el estado del jugador humano.
*   `bots_panels: Array[PlayerPanel]`: Un arreglo de paneles de UI, donde cada elemento representa las estadísticas y el estado de un bot o personaje controlado por la IA.
*   `rocks_list: Rocks`: Una referencia al nodo que gestiona la lista de "rocas" o elementos interactivos del escenario.

Al centralizar estas referencias, `BattleUI` simplifica la lógica de la UI y asegura que todos los componentes visuales puedan ser actualizados de forma coordinada.

# Métodos

## Otros métodos

### `set_hand_from_deck(deck: Array[CardScene.Card]) -> void`
Este método es utilizado para establecer o refrescar las cartas visibles en la mano del jugador. Recibe un arreglo (`Array`) de objetos `CardScene.Card`, que representan las cartas que deben mostrarse. La lógica de cómo estas cartas son renderizadas y gestionadas es delegada al nodo `hand` referenciado, que debe implementar su propio método `set_from_deck`.

**Funcionamiento:**
Simplemente invoca el método `set_from_deck` del nodo `hand`, pasando el `Array` de cartas recibido.

```gdscript
func set_hand_from_deck(deck: Array[CardScene.Card]) -> void:
	hand.set_from_deck(deck)
```

**Interacciones:**
*   Depende de que el nodo `hand` (de tipo `Hand`) tenga un método `set_from_deck` que acepte un `Array` de `CardScene.Card`.
*   Asume que `CardScene.Card` es una clase o `Resource` que representa una carta del juego.

### `get_abstract_rocks_list() -> Array`
Este método proporciona una forma de obtener una representación simplificada o "abstracta" de la lista de elementos de tipo "roca" presentes en el escenario de batalla. La implementación específica para obtener esta lista es delegada al nodo `rocks_list`.

**Funcionamiento:**
Retorna el resultado de invocar el método `get_abstract_rocks_list()` del nodo `rocks_list`.

```gdscript
func get_abstract_rocks_list() -> Array:
	return rocks_list.get_abstract_rocks_list()
```

**Interacciones:**
*   Depende de que el nodo `rocks_list` (de tipo `Rocks`) tenga un método `get_abstract_rocks_list()` que devuelva un `Array`.
*   El término "abstracta" sugiere que esta lista puede contener datos resumidos o identificadores de las rocas, en lugar de las instancias de nodos `Rock` completas.

### `refresh_player_stats(players_list: Array) -> void`
Este método es fundamental para actualizar la interfaz de usuario que muestra las estadísticas y el estado de todos los participantes en la batalla, incluyendo al jugador humano y a los bots. Recibe un `Array` llamado `players_list`, donde cada elemento es un objeto de tipo `Player`.

**Funcionamiento:**
1.  **Iteración:** Recorre cada `Player` dentro de `players_list`.
2.  **Identificación del Panel:** Para cada `Player`, determina si es el jugador humano (identificado por el índice `0` en la lista) o un bot (`player.is_bot`).
    *   Si es el jugador humano, se utiliza el `player_panel` exportado.
    *   Si es un bot, se selecciona el `PlayerPanel` correspondiente del `bots_panels` `Array`, ajustando el índice (`i - 1`) ya que `bots_panels` solo contiene los paneles de los bots.
3.  **Actualización de Propiedades:** Asigna directamente las propiedades del objeto `Player` (como `player_name`, `team`, `health`, `current_element`, `current_value`, `hide_card`) a las propiedades correspondientes del `current_player_panel` seleccionado. Esto se espera que actualice la representación visual en la UI.
4.  **Poda de Paneles:** Después de actualizar todos los paneles activos, llama al método privado `_prune_bots_panels` para ocultar cualquier `PlayerPanel` de bot que no esté siendo utilizado en la batalla actual.

```gdscript
func refresh_player_stats(players_list: Array) -> void:
	# Establece el panel del jugador
	for i in range(players_list.size()):
		var player: Player = players_list[i]
		var current_player_panel := player_panel if not player.is_bot else bots_panels[i - 1]

		current_player_panel.player_name = player.player_name
		current_player_panel.team = player.team
		current_player_panel.health = player.health
		current_player_panel.element = player.current_element
		current_player_panel.value = player.current_value
		current_player_panel.hide_card = player.hide_card

	_prune_bots_panels(players_list.size() - 1)
```

**Interacciones:**
*   Asume que cada objeto en `players_list` es una instancia de una clase `Player` y que esta clase tiene las propiedades: `is_bot` (booleano), `player_name` (string), `team` (string/enum), `health` (numérico), `current_element` (string/enum), `current_value` (numérico), y `hide_card` (booleano).
*   Requiere que los nodos `PlayerPanel` (tanto `player_panel` como los del `bots_panels`) tengan propiedades con los mismos nombres para recibir los datos (`player_name`, `team`, `health`, etc.).
*   La lógica de actualización visual dentro de cada `PlayerPanel` es responsabilidad de esos nodos.

### `_prune_bots_panels(bot_count: int) -> void`
Este es un método privado (`_` prefijo) que se encarga de gestionar la visibilidad de los paneles de los bots. Su objetivo es ocultar cualquier `PlayerPanel` en el arreglo `bots_panels` que no esté asociado a un bot activo en la partida, evitando así que se muestren paneles vacíos o irrelevantes.

**Funcionamiento:**
1.  **Verificación de Equivalencia:** Primero, compara `bot_count` (el número de bots activos) con el tamaño actual del arreglo `bots_panels`. Si son iguales, significa que no hay paneles que podar, y el método termina.
2.  **Validación de `bot_count`:** Realiza una verificación de validez para `bot_count`. Si es menor que `1` o mayor que el número total de `bots_panels` disponibles, se registra un error (`push_error`) en la consola, indicando un posible problema de configuración.
3.  **Ocultar Paneles Sobrantes:** Si `bot_count` es válido y no coincide con el tamaño del arreglo, itera desde el índice `bot_count` hasta el final de `bots_panels`. Para cada panel en este rango, establece su propiedad `visible` a `false`, ocultándolo de la UI.

```gdscript
func _prune_bots_panels(bot_count: int) -> void:
	if bot_count == bots_panels.size(): return
	if bot_count > bots_panels.size() or bot_count < 1:
		push_error("[BattleUI] Cantidad de bots inválida: %s" % bot_count)
		return

	# Recorre los paneles que sobran
	for i in range(bot_count, bots_panels.size()):
		bots_panels[i].visible = false
```

**Interacciones:**
*   Manipula directamente la propiedad `visible` de los nodos `PlayerPanel` dentro del arreglo `bots_panels`.
*   Es llamado internamente por `refresh_player_stats` para asegurar la coherencia visual después de actualizar las estadísticas de los jugadores.