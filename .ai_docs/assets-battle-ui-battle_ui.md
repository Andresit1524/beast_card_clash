# `BattleUI`
`BattleUI` es una clase `Node` diseñada para centralizar y gestionar la interfaz de usuario del escenario de batalla. Actúa como un coordinador entre los diferentes componentes visuales de la batalla, como la mano de cartas del jugador, los paneles de estadísticas de los jugadores (humano y bots) y la interfaz de fin de juego. Su propósito principal es abstraer la lógica de actualización y visibilidad de estos elementos de UI, permitiendo que otros scripts (como un gestor de batalla principal) interactúen con la UI de manera simplificada y coherente.

La clase expone una señal que se emite cuando una carta es seleccionada en la mano del jugador, facilitando la comunicación con el sistema de juego principal.

```gdscript
class_name BattleUI extends Node
```

## Señales

### `card_selected(card: Card)`
Esta señal se emite cuando el jugador selecciona una carta de su mano. La señal incluye una referencia a la `Card` seleccionada, lo que permite al controlador de juego principal procesar la selección y ejecutar la lógica de juego correspondiente.

## Variables `@onready`

- `hand: Hand = %Hand`: Referencia al nodo `Hand`, que gestiona la visualización y la interacción con las cartas que el jugador tiene en su mano. La tipificación como `Hand` sugiere que existe una clase `Hand` personalizada.
- `player_panel: PlayerPanel = %PlayerPanel`: Referencia al nodo `PlayerPanel` que muestra las estadísticas y el estado del jugador principal (humano). La tipificación como `PlayerPanel` sugiere que existe una clase `PlayerPanel` personalizada.
- `bots_panels: VBoxContainer = %BotsPanels`: Referencia a un `VBoxContainer` que contiene los nodos `PlayerPanel` de los bots en la batalla. Este contenedor organiza y permite acceder a los paneles de cada oponente controlado por IA.
- `end_ui: EndUI = %EndUI`: Referencia al nodo `EndUI`, que representa la interfaz de usuario de fin de juego (por ejemplo, pantalla de victoria o derrota). La tipificación como `EndUI` sugiere que existe una clase `EndUI` personalizada.

## Métodos

### `enable_hand(enabled: bool) -> void`
Controla la visibilidad y la interactividad de la mano de cartas del jugador.

- **`enabled`**: Un valor booleano que determina si la mano de cartas debe estar activa (`true`) o desactivada (`false`).
  - Cuando es `true`, la propiedad `hide_cards` del nodo `hand` se establece en `false`, lo que permite que las cartas sean visibles e interactivas.
  - Cuando es `false`, la propiedad `hide_cards` del nodo `hand` se establece en `true`, ocultando las cartas y deshabilitando su interacción.

```gdscript
func enable_hand(enabled: bool) -> void:
	hand.hide_cards = not enabled
```

### `set_hand_from_deck(deck: Array[Card]) -> void`
Actualiza la mano de cartas del jugador con un nuevo conjunto de cartas.

- **`deck`**: Un array de objetos `Card` que representan las cartas que el jugador debe tener en su mano.
  - Este método invoca el método `set_from_deck()` en el nodo `hand` para poblarlo con las cartas provistas.
  - Para cada carta en la mano (`hand.get_cards()`), se conecta su señal `card_selected` a una función anónima. Esta función anónima, a su vez, re-emite la señal `card_selected` de la propia clase `BattleUI`, pasando la carta seleccionada como argumento. Esto centraliza la gestión de la selección de cartas, permitiendo que el controlador de batalla principal solo tenga que escuchar la señal de `BattleUI`.

```gdscript
func set_hand_from_deck(deck: Array[Card]) -> void:
	hand.set_from_deck(deck)
	for card in hand.get_cards():
		card.card_selected.connect(func(c): card_selected.emit(c))
```

### `set_hand_element(new_element: GameConstants.Elements) -> void`
Establece el elemento actual asociado a la mano de cartas del jugador.

- **`new_element`**: Un valor del tipo `GameConstants.Elements` que representa el nuevo elemento de la mano (e.g., fuego, agua, planta).
  - Este elemento puede influir en la visualización de la mano o en las reglas de juego relacionadas con los elementos. La propiedad `current_element` del nodo `hand` se actualiza con este valor.

### `refresh_player_stats(players_list: Array) -> void`
Actualiza la información de los paneles de estadísticas para todos los jugadores (humano y bots) presentes en la batalla.

- **`players_list`**: Un array de objetos `Player` que contiene la información actual de todos los participantes en la batalla. Se asume que el `Player` en la posición 0 de la lista es el jugador humano, y el resto son bots.
  - El método itera sobre `players_list`:
    - Si el `player` no es un bot, actualiza el `player_panel` (el panel del jugador principal).
    - Si el `player` es un bot, selecciona el `PlayerPanel` correspondiente del `bots_panels` (usando `get_child()`) y lo hace visible.
  - Para cada panel, se actualizan las propiedades visuales como `player_name`, `team`, `health`, `element`, `value` y `hide_card` con los datos del objeto `Player` correspondiente.
  - Después de actualizar los paneles de los jugadores activos, llama a `_prune_bots_panels()` para ocultar cualquier panel de bot que no esté en uso en la batalla actual.

```gdscript
func refresh_player_stats(players_list: Array) -> void:
	var bot_ui_index := 0

	for i in range(players_list.size()):
		var player: Player = players_list[i]
		var current_player_panel: PlayerPanel

		if not player.is_bot:
			current_player_panel = player_panel
		else:
			current_player_panel = bots_panels.get_child(bot_ui_index)
			bot_ui_index += 1
			current_player_panel.visible = true

		current_player_panel.player_name = player.player_name
		current_player_panel.team = player.team
		current_player_panel.health = player.health
		current_player_panel.element = player.current_element
		current_player_panel.value = player.current_value
		current_player_panel.hide_card = player.hide_card

	_prune_bots_panels(bot_ui_index)
```

### `_prune_bots_panels(bot_count: int) -> void`
Método auxiliar privado (`_` prefix) que se encarga de ocultar los paneles de bots que no están actualmente participando en la batalla. Esto asegura que solo se muestren los paneles correspondientes a los bots activos.

- **`bot_count`**: El número de bots activos en la batalla.
  - El método primero realiza verificaciones básicas para evitar operaciones innecesarias o erróneas:
    - Si `bot_count` es igual al número total de hijos en `bots_panels`, no hay paneles que podar.
    - Si `bot_count` es mayor que el número de paneles existentes o es negativo, se emite un error usando `push_error()` y el método termina.
  - Recorre los paneles de bots desde el índice `bot_count` hasta el final, estableciendo su propiedad `visible` a `false` para ocultarlos.

```gdscript
func _prune_bots_panels(bot_count: int) -> void:
	if bot_count == bots_panels.get_child_count(): return
	if bot_count > bots_panels.get_child_count() or bot_count < 0:
		push_error("[BattleUI] Cantidad de bots inválida: %s" % bot_count)
		return

	# Recorre los paneles que sobran
	for i in range(bot_count, bots_panels.get_child_count()):
		bots_panels.get_child(i).visible = false
```

### `set_end_ui(set_visible: bool) -> void`
Controla la visibilidad de la interfaz de fin de juego.

- **`set_visible`**: Un valor booleano.
  - Si es `true`, la propiedad `ui_visible` del nodo `end_ui` se establece en `true`, mostrando la pantalla de fin de juego.
  - Si es `false`, la propiedad `ui_visible` del nodo `end_ui` se establece en `false`, ocultando la pantalla de fin de juego.

```gdscript
func set_end_ui(set_visible: bool) -> void:
	end_ui.ui_visible = set_visible
```