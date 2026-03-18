# `Player`
La clase `Player`, que hereda de `Node`, es una clase abstracta fundamental en `Beast Card Clash` diseñada para representar a cualquier participante en las batallas del juego. Su propósito principal es encapsular y gestionar todos los datos y la lógica esenciales relacionados con un jugador individual, ya sea controlado por un ser humano o por inteligencia artificial (bot).

Esta clase actúa como un contenedor central para atributos del jugador como la `health` (salud), el `player_name` (nombre), el `team` (equipo) y, crucialmente, la `deck` (baraja) de cartas coleccionables. Implementa mecánicas básicas pero vitales del juego, incluyendo la creación de la baraja, la gestión de cartas (añadir, eliminar y jugar cartas), la aplicación de daño y la detección de condiciones de "game over" (fin de partida).

Al fusionar la jugabilidad competitiva con elementos educativos, se espera que las instancias de `Player` interactúen con `CardScene.Card` que representen la biodiversidad colombiana y las facultades de la UNAL. Su diseño modular permite una fácil integración con el resto del sistema de juego, facilitando el seguimiento del estado de cada combatiente y la orquestación de los turnos de juego.

# Métodos

## Métodos de Godot

### `_init(new_name: String = "", new_team := GameConstants.Teams.NO_TEAM, bot: bool = true) -> void`
Este es el método constructor de la clase `Player`. Se encarga de inicializar una nueva instancia de jugador con sus características básicas al momento de su creación.

-   **`new_name`**: Si se proporciona una cadena vacía (`""`), el jugador recibirá un nombre aleatorio seleccionado de la constante `NAMES`. Esto permite la creación rápida de jugadores sin necesidad de predefinir sus nombres.
-   **`new_team`**: Si el equipo proporcionado es `GameConstants.Teams.NO_TEAM`, se asignará un equipo aleatorio de entre los valores definidos en `GameConstants.Teams`. Esto brinda flexibilidad para asignar equipos específicos o para configurar batallas con equipos aleatorios.
-   **`bot`**: Este parámetro booleano (`true` por defecto) define si el jugador es controlado por la IA (`true`) o por un ser humano (`false`). Esta distinción es crucial para la lógica del juego, especialmente para la emisión de señales de actualización de la UI (como `deck_updated`) que solo son relevantes para los jugadores humanos.

Además, el constructor inicializa la `health` del jugador a `MAX_HEALTH` (5) y otras propiedades relacionadas con las cartas, como `current_element`, `current_value` y `hide_card`, con sus valores por defecto.

## Otros métodos

### `randomize() -> void`
Este método asigna características aleatorias temporales al jugador para su `current_element` y `current_value`.
-   Asegura que `current_element` no sea `GameConstants.Elements.NONE` al seleccionar continuamente un elemento aleatorio hasta que se elija uno válido.
-   `current_value` se establece como un número entero aleatorio entre 1 y 10.
-   El comentario `! Función temporal` indica que este método es probablemente una herramienta de desarrollo o un *placeholder* para pruebas, y es posible que sea modificado o eliminado en futuras iteraciones del juego a medida que se implemente una lógica más sofisticada para la creación de personajes o asignación de propiedades.

### `create_deck() -> void`
Este método se encarga de crear la baraja inicial de cartas para el jugador.
-   Itera un número de veces igual a `INITIAL_CARDS` (actualmente 7).
-   En cada iteración, genera una nueva instancia de `CardScene.Card`.
-   Para cada nueva carta, se asigna un `element` aleatorio (asegurándose de que no sea `GameConstants.Elements.NONE`) y un `value` aleatorio entre 1 y 10.
-   La carta recién creada se añade a la `deck` del jugador.
-   Finalmente, invoca a `_update_deck_if_needed()` para notificar si la baraja ha cambiado, especialmente si el jugador es humano y su interfaz necesita actualizarse.

```gdscript
func create_deck() -> void:
    for i in range(INITIAL_CARDS):
        # Elemento de la carta
        var new_card_element := GameConstants.Elements.NONE
        while new_card_element == GameConstants.Elements.NONE:
            new_card_element = GameConstants.Elements.values().pick_random()

        var new_card = CardScene.Card.new(new_card_element, randi_range(1, 10))
        deck.append(new_card)

    _update_deck_if_needed()
```

### `add_card(card: CardScene.Card) -> void`
Este método añade una `CardScene.Card` específica a la baraja (`deck`) del jugador.
-   La `card` proporcionada se añade al final del array `deck`.
-   Después de añadir la carta, llama a `_update_deck_if_needed()` para emitir la señal `deck_updated` si el jugador es humano, asegurando que cualquier componente de la interfaz de usuario que muestre la baraja se actualice.

### `remove_card(card: CardScene.Card) -> void`
Este método elimina una `CardScene.Card` específica de la baraja (`deck`) del jugador.
-   Utiliza el método `erase` de `Array` para eliminar la instancia exacta de la `card` de la `deck`.
-   Al igual que `add_card`, invoca a `_update_deck_if_needed()` para asegurar que la interfaz de usuario de los jugadores humanos refleje el cambio en la baraja.

### `play_card(card: CardScene.Card) -> void`
Este método simula la acción de un jugador al jugar una carta de su baraja.
-   Primero verifica si la `card` proporcionada realmente existe en la `deck` del jugador.
-   Si la carta se encuentra en la baraja, se elimina de ella utilizando `erase`.
-   Inmediatamente después de modificar la baraja, se llama a `_update_deck_if_needed()` para notificar a la interfaz de usuario (si aplica).
-   Una vez jugada la carta, se evalúa una condición crítica de fin de juego: `if not deck:`. Si la baraja del jugador queda vacía después de jugar la carta, se emite la señal `game_over`, indicando que este jugador ha perdido la partida debido a la falta de cartas.

```gdscript
func play_card(card: CardScene.Card) -> void:
    if card in deck:
        deck.erase(card)
        _update_deck_if_needed()

    if not deck: game_over.emit(self)
```

### `_update_deck_if_needed() -> void`
Este método auxiliar, de naturaleza privada (indicado por el guion bajo inicial), es responsable de emitir la señal `deck_updated`.
-   Su lógica condicional `if not is_bot:` asegura que la señal solo se emita si el jugador no es un bot, es decir, si es un jugador humano. Esto es una optimización para evitar actualizaciones innecesarias de la interfaz de usuario para jugadores controlados por IA.
-   Cuando se emite, la señal `deck_updated` lleva consigo el array `deck` actual del jugador, permitiendo que elementos de la interfaz de usuario (como la visualización de la mano del jugador) se actualicen con el nuevo estado de la baraja.

### `apply_damage(damage: int) -> void`
Este método aplica una cantidad específica de `damage` a la salud (`health`) del jugador.
-   Reduce la `health` del jugador en la cantidad especificada por `damage`.
-   Incluye una comprobación `if health < 0:` para asegurar que la salud del jugador nunca descienda por debajo de cero, fijándola en 0 si el daño recibido excede la salud actual.
-   Si la `health` del jugador alcanza 0 o menos después de recibir daño, se emite la señal `game_over`, indicando que este jugador ha sido derrotado.

```gdscript
func apply_damage(damage: int) -> void:
    health -= damage

    if health < 0:
        health = 0
        game_over.emit(self)
```

## Funciones asociadas a señales

#### `deck_updated(new_deck: Array[CardScene.Card])`
-   **Señal a la que apunta:** Esta es una señal definida y emitida por la propia clase `Player`.
-   **Qué hace:** Se emite cada vez que la baraja (`deck`) de un jugador humano sufre un cambio significativo (por ejemplo, al añadir, remover o jugar una carta). Su propósito fundamental es notificar a los componentes de la interfaz de usuario, como los encargados de mostrar la mano del jugador o el recuento de cartas en la baraja, para que puedan actualizar su representación visual. La señal pasa el array `new_deck` completo, permitiendo una sincronización precisa entre la lógica del juego y la visualización para el jugador.

#### `game_over(player: Player)`
-   **Señal a la que apunta:** Esta es una señal definida y emitida por la propia clase `Player`.
-   **Qué hace:** Esta señal se emite cuando un jugador cumple con una de las condiciones de derrota del juego. Esto puede ocurrir en dos situaciones principales:
    1.  Cuando el jugador utiliza el método `play_card()` y, como resultado, su baraja (`deck`) se queda completamente vacía.
    2.  Cuando el jugador recibe suficiente daño a través del método `apply_damage()`, lo que reduce su `health` a 0 o menos.
    La señal `game_over` incluye una referencia al objeto `player` que ha sido derrotado. Esto permite que otros sistemas del juego, como un gestor de batalla o de rondas, puedan identificar al jugador que ha perdido y ejecutar las acciones pertinentes para finalizar la partida o determinar al ganador.