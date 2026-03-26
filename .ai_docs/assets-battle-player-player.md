# `Player`
Este script define la clase `Player`, que extiende `CharacterBody3D` y representa a un jugador en una batalla, ya sea controlado por un humano o por la inteligencia artificial (bot). La clase encapsula todos los datos relevantes del jugador (nombre, equipo, salud, baraja, etc.), así como las mecánicas principales de juego asociadas a él, como la gestión de la baraja, la aplicación de daño y el movimiento en el entorno 3D.

El objetivo principal de esta clase es proporcionar una representación coherente y funcional de un participante en el juego de cartas, gestionando su estado a lo largo de las fases de preparación, batalla y movimiento en el mapa. Utiliza señales para notificar a otros componentes del sistema sobre eventos importantes del jugador, como movimientos completados o actualizaciones de la baraja.

# Métodos

## Métodos de Godot

Este script no sobrescribe los métodos intrínsecos de Godot como `_ready`, `_process` o `_physics_process`. La inicialización y la lógica de actualización se gestionan a través de métodos personalizados y señales, o se espera que sean invocados por otros sistemas del juego.

## Otros métodos

### `randomize()`
Este método asigna características aleatorias al jugador, incluyendo un nombre de la lista predefinida `NAMES` y un equipo aleatorio de `GameConstants.Teams`.

```gdscript
func randomize() -> void:
	player_name = NAMES.pick_random()
	team = GameConstants.Teams.values().pick_random()
```

> [!Note] Uso Temporal
> La documentación del código sugiere que esta función es "posiblemente temporal", lo que indica que podría ser una característica de desarrollo o de depuración, y podría ser reemplazada o modificada una vez que la selección de jugadores y equipos sea manejada por una interfaz de usuario o un sistema de emparejamiento más robusto. Actualmente, se usa para inicializar rápidamente las propiedades de un bot o un jugador de prueba.

### `create_deck()`
Este método se encarga de generar la baraja inicial del jugador. Crea `INITIAL_CARDS` cartas, asignando a cada una un `element` aleatorio (excluyendo `NONE`) y un `value` aleatorio entre 1 y 10. Las cartas se instancian a partir de la `card_scene` exportada. Una vez creada la baraja, llama a `_update_deck_if_needed()` para notificar cualquier cambio.

```gdscript
func create_deck() -> void:
	for i in range(INITIAL_CARDS):
		var new_card_element := GameConstants.Elements.NONE
		while new_card_element == GameConstants.Elements.NONE:
			new_card_element = GameConstants.Elements.values().pick_random()

		var new_card: Card = card_scene.instantiate()
		new_card.element = new_card_element
		new_card.value = randi_range(1, 10)
		deck.append(new_card)

	_update_deck_if_needed()
```

### `add_card(card: Card)`
Añade una carta (`Card`) al final de la baraja (`deck`) del jugador. Después de añadir la carta, invoca `_update_deck_if_needed()` para asegurar que cualquier componente que dependa de la baraja actualizada reciba la notificación.

### `remove_card(card: Card)`
Elimina una carta específica (`Card`) de la baraja (`deck`) del jugador. Utiliza el método `erase()` de `Array` para remover la primera ocurrencia de la carta. Al igual que `add_card`, llama a `_update_deck_if_needed()` tras la operación.

### `play_card(card: Card = null) -> Card`
Gestiona la acción de "jugar" una carta.
- Si se proporciona una `card` específica, intenta eliminarla de la baraja.
- Si no se proporciona ninguna `card` (es `null`), selecciona una carta aleatoria de la baraja para jugar.
- Si la baraja se queda vacía después de jugar una carta, el método emite la señal `game_over`, indicando que el jugador ha sido derrotado.
- Retorna la carta que ha sido jugada, o `null` si la baraja estaba vacía y no se pudo jugar ninguna carta.

```gdscript
func play_card(card: Card = null) -> Card:
	# Si no hay carta, elige al azar
	if not card: card = deck.pick_random()

	# Busca y elimina la carta
	if card in deck:
		deck.erase(card)
		_update_deck_if_needed()

	# Muere si no hay más cartas
	if not deck: game_over.emit(self)
	return card
```

### `_update_deck_if_needed()`
Este es un método auxiliar privado (`_`) diseñado para emitir la señal `deck_updated` solo si el jugador no es un bot (`is_bot` es `false`). Esto es útil para actualizar la interfaz de usuario de los jugadores humanos, que necesitan ver el estado actual de su baraja.

### `apply_damage(damage: int)`
Reduce la salud (`health`) actual del jugador por la cantidad especificada de `damage`. Imprime información de depuración sobre el daño aplicado. Si la salud resultante es menor o igual a 0, se ajusta a 0 y se emite la señal `game_over`, señalando la derrota del jugador.

```gdscript
func apply_damage(damage: int) -> void:
	print("[Player] Daño aplicado: %s - %s" % [health, damage])
	health -= damage

	if health < 0:
		health = 0
		game_over.emit(self)
```

### `move_to(new_position: Vector3, new_index: int)`
Mueve el objeto `Player` (que es un `CharacterBody3D`) a una nueva posición en el espacio 3D.
- Actualiza `current_rock_index` con el `new_index` proporcionado, que representa la posición lógica del jugador en el mapa (por ejemplo, en una "roca" o casilla específica).
- Utiliza un `Tween` para animar suavemente el movimiento del jugador desde su posición actual a `new_position`. El movimiento tiene una duración definida por `MOVE_TIME` y utiliza una interpolación `QUAD` con facilidad `IN_OUT`.
- La posición Y del jugador se fija a la constante `Z_POSITION` durante el movimiento, lo que sugiere que los jugadores "flotan" a una altura constante.
- Una vez que la animación de movimiento se completa, se emite la señal `moved()`, notificando a otros componentes que el jugador ha llegado a su destino.

```gdscript
func move_to(new_position: Vector3, new_index: int) -> void:
	current_rock_index = new_index

	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

	var final_pos := Vector3(new_position.x, Z_POSITION, new_position.z)
	tween.tween_property(self, "position", final_pos, MOVE_TIME)
	tween.tween_callback(func(): moved.emit())
```

## Funciones asociadas a señales

Estas son las señales que la clase `Player` puede emitir para notificar a otros componentes del sistema sobre cambios o eventos importantes.

#### `moved()`
Esta señal se emite cuando el jugador ha completado una animación de movimiento, típicamente después de que la función `move_to()` ha finalizado su `Tween`. Es útil para sistemas que necesitan saber cuándo el jugador ha llegado a su destino antes de proceder con la siguiente acción (por ejemplo, activar un evento en la nueva "roca").

#### `deck_updated(new_deck: Array[Card])`
Esta señal se emite cuando la baraja del jugador ha sido modificada (se añade, se elimina o se juega una carta), pero solo si el jugador no es un bot (`is_bot` es `false`). Lleva como argumento la `new_deck` (la baraja actualizada) para que los oyentes puedan reflejar los cambios, por ejemplo, en la interfaz de usuario del jugador humano.

#### `game_over(player: Player)`
Esta señal se emite en dos escenarios que significan la derrota del jugador:
1. Cuando la salud (`health`) del jugador llega a 0 o menos, como resultado de `apply_damage()`.
2. Cuando la baraja (`deck`) del jugador se queda completamente vacía después de jugar una carta a través de `play_card()`.
Esta señal lleva como argumento una referencia al propio jugador (`self`), permitiendo al sistema de juego identificar qué jugador ha sido derrotado.