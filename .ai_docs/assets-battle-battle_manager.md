# `BattleManager`
El script `BattleManager.gd` define la clase `BattleManager`, que extiende `StateMachine` y sirve como el centro de control principal para la lógica de una partida en *Beast Card Clash*. Su propósito fundamental es gestionar el flujo del juego, los datos de los jugadores, la interacción entre los componentes de la interfaz de usuario (`BattleUI`) y el mundo del juego (`BattleWorld`), y la transición entre los diferentes estados de la batalla.

Actúa como un coordinador, centralizando las referencias a objetos clave como la interfaz de usuario, el entorno 3D y las instancias de jugadores, facilitando así la comunicación y la orquestación de las acciones durante los turnos, rondas y eventos específicos de la batalla. Al heredar de `StateMachine`, `BattleManager` delega la lógica de los distintos momentos de la partida (inicio, turno de jugador, turno de bot, resolución de ronda) a estados individuales (`BattleState` y sus derivados), permitiendo un flujo de juego claro y modular.

## Métodos

### Métodos de Godot

### `_ready()`
Este método se llama una vez que el nodo y todos sus hijos han entrado en la "escena activa" (scene tree). En `BattleManager`, su función es crucial para la inicialización y el establecimiento de conexiones entre los componentes del juego:

1.  **Inyección de Dependencias para Estados:** Antes de iniciar la máquina de estados, el método itera sobre todos sus nodos hijos. Si un hijo es una instancia de `BattleState` (la clase base para los estados del juego), se le inyecta una referencia al propio `BattleManager` (`self`). Esto asegura que cada estado tenga acceso al manager para coordinar acciones y cambiar entre estados, una práctica común para un **patrón de máquina de estados robusto**.

    ```gdscript
    for child in get_children():
        if child is BattleState:
            child.manager = self
    ```

2.  **Inicialización de la Máquina de Estados:** Después de preparar los estados, se llama a `super()`. Esto invoca el método `_ready` de la clase base `StateMachine`, lo que generalmente inicia el primer estado de la máquina.

3.  **Conexión de Señales:** Establece las conexiones esenciales entre el `BattleManager` y los componentes de `BattleWorld` y `BattleUI`. Estas conexiones son fundamentales para que el manager reaccione a eventos generados por la interacción del jugador o por la lógica del mundo del juego:
    *   `battle_world.rock_selected` se conecta a `_on_rock_selected`, permitiendo al manager reaccionar cuando una roca es elegida.
    *   `battle_ui.card_selected` se conecta a `_on_card_selected`, para manejar la selección de cartas por el jugador.
    *   `battle_world.dice_thrown` se conecta a `set_dice_value`, para registrar el resultado de un lanzamiento de dado.
    *   `battle_world.players_ready` se conecta a `setup_ui`, para configurar la interfaz una vez que los jugadores estén listos en el mundo.

### Otros métodos

### `setup_player() -> void`
Este método se encarga de instanciar y configurar al jugador humano al inicio de la partida. Su función es preparar la entidad del jugador con sus atributos básicos y asociarlo con la interfaz de usuario:

*   **Instanciación:** Crea una nueva instancia del jugador a partir de la `player_scene` exportada.
*   **Configuración de Atributos:** Asigna el nombre y el equipo del jugador, utilizando los datos guardados en `PlayerStats` (que se asume es un `Singleton` o un recurso global). También marca al jugador como `is_bot = false`.
*   **Creación de Mazo:** Llama a `player.create_deck()` para generar el mazo inicial de cartas del jugador.
*   **Registro del Jugador:** Añade la instancia del jugador a la lista global `players` gestionada por el `BattleManager`.
*   **Conexión UI:** Conecta la señal `deck_updated` del jugador al método `battle_ui.set_hand_from_deck`. Esto asegura que la interfaz de la mano del jugador se actualice automáticamente cada vez que el mazo del jugador sufra cambios (ej. al robar una carta).

### `setup_bots() -> void`
Prepara e inicializa a los oponentes controlados por la IA (bots) para la partida. Este proceso incluye la creación de un número aleatorio de bots y su configuración inicial:

*   **Conteo de Bots:** Genera un número aleatorio de bots entre 1 y `MAX_PLAYERS - 1` (para asegurar que siempre haya al menos un jugador humano y hasta 3 bots, sumando un máximo de 4 participantes).
*   **Instanciación y Configuración:** En un bucle, crea cada instancia de bot utilizando `player_scene`, le asigna un mazo con `create_deck()`, y llama a `randomize()` para darle propiedades aleatorias (nombre, equipo, etc.).
*   **Registro de Bots:** Añade cada bot a la lista `players`.
*   **Mezcla de Jugadores:** Una vez que todos los jugadores (humano y bots) están en la lista, se utiliza `players.shuffle()` para mezclar el orden, asegurando que el primer turno sea asignado aleatoriamente.
*   **Asignación de Primer Turno:** Establece el `current_turn` al primer jugador de la lista mezclada.

### `setup_ui() -> void`
Este método se encarga de la configuración inicial de la interfaz de usuario de batalla (`BattleUI`) una vez que los jugadores han sido establecidos en el mundo:

*   **Actualización de Estadísticas:** Llama a `battle_ui.refresh_player_stats(players)` para mostrar las estadísticas de todos los jugadores en la interfaz.
*   **Configuración de Mano Inicial:** Llama a `battle_ui.set_hand_from_deck(player.deck)` para mostrar las cartas iniciales en la mano del jugador humano.
*   **Desactivación Inicial de Mano:** Deshabilita la interacción con la mano del jugador (`battle_ui.enable_hand(false)`), indicando que no es el momento de seleccionar cartas.
*   **Desactivación de UI de Fin de Partida:** Se asegura de que la interfaz de fin de partida no esté visible al inicio (`battle_ui.set_end_ui(false)`).

### `setup_world() -> void`
Prepara el entorno del `BattleWorld` al inicio de la partida, controlando qué elementos están activos o visibles:

*   **Desactivación de Rocas:** Llama a `battle_world.disable_rocks()` para deshabilitar la interacción con las rocas del escenario, ya que la selección de rocas se habilita en momentos específicos del turno.
*   **Desactivación de Dados:** Deshabilita la interacción con el dado (`battle_world.enable_dice(false)`).
*   **Asignación de Jugadores al Mundo:** Proporciona la lista de `players` al `battle_world`, lo que permite que el mundo del juego pueda referenciar a los personajes presentes.

### `set_dice_value(value: int) -> void`
Este método es una función auxiliar simple que se utiliza para almacenar el valor resultante de un lanzamiento de dado.

*   **Almacenamiento:** Actualiza la variable `current_dice_value` con el `value` pasado como argumento. Esta variable será utilizada posteriormente por la lógica de los estados para determinar el progreso en el tablero o los efectos del dado.

### `switch_next_turn_state() -> void`
Es un método central para la progresión de los turnos y rondas en la partida. Su responsabilidad es determinar qué jugador tiene el siguiente turno y, en función de eso, cambiar el estado de la máquina de estados:

*   **Determinación del Siguiente Turno:** Calcula la posición del siguiente jugador en la lista `players` de forma circular (`(players.find(current_turn) + 1) % players.size()`).
*   **Fin de Ronda:** Si la `next_turn_pos` vuelve a ser `0` (indicando que todos los jugadores han tenido su turno y es el turno del primer jugador de la lista de nuevo), se considera que la ronda ha finalizado. En este caso:
    *   Se cambia el estado a `BattleReferee`, que se encarga de procesar y resolver los efectos de la ronda.
    *   Se espera a que la señal `round_handled` sea emitida por el `BattleReferee` antes de continuar con la lógica (posiblemente un cambio de estado posterior, aunque aquí no se explicita).
    ```gdscript
    if next_turn_pos == 0:
        change_to_state(BattleReferee)
        print("[BattleManager] Fin de la ronda")

        await round_handled
    ```
*   **Turno de Jugador Humano:** Si el siguiente jugador no es un bot (`not players[next_turn_pos].is_bot`), se establece como `current_turn` y se cambia el estado a `BattleTurn`, que maneja la lógica para la interacción del jugador humano.
*   **Turno de Bot:** En cualquier otro caso (el siguiente jugador es un bot), se establece como `current_turn` y se cambia el estado a `BattleLoop`, que gestiona la lógica para el turno de un oponente de la IA.

Este método es vital para mantener el ciclo de turnos y rondas y para la integración con la `StateMachine`.

### `get_rocks()`
Método de acceso simple que devuelve la lista de rocas disponibles en el `BattleWorld`.

*   **Delegación:** Simplemente retorna `battle_world.rocks_list`, permitiendo que otros componentes del sistema (especialmente los estados de la máquina de estados) puedan obtener la referencia a las rocas sin tener que acceder directamente a `battle_world`.

## Funciones asociadas a señales

#### `_on_rock_selected(selected_rock: Rock) -> void`
Esta función es un *slot* que se ejecuta cuando el jugador humano selecciona una roca en el `BattleWorld`. Está conectada a la señal `battle_world.rock_selected`.

**Funcionamiento:**
1.  **Desactivar Interacción:** Primero, deshabilita la interacción con todas las rocas del mundo (`battle_world.disable_rocks()`) para evitar selecciones múltiples o interferencias.
2.  **Movimiento del Jugador:** Mueve al `player` (humano) a la posición de la `selected_rock` y le pasa el índice de la roca.
3.  **Esperar Movimiento:** Utiliza `await player.moved` para pausar la ejecución hasta que el jugador haya completado su movimiento, asegurando que las siguientes acciones se realicen después de que el jugador esté en su nueva posición.
4.  **Verificación de Cartas:** Filtra el mazo del jugador (`player.deck`) para encontrar cartas que coincidan con el `element` de la roca seleccionada, o cualquier carta si la roca no tiene un elemento específico.
5.  **Turno Saltado:** Si no hay `card_choices` disponibles (el jugador no tiene cartas jugables para esa roca), el turno se salta llamando a `switch_next_turn_state()`.
6.  **Mostrar Mano:** Si hay cartas jugables, la interfaz de la mano del jugador (`battle_ui`) se actualiza para resaltar las cartas del elemento correspondiente a la roca (`battle_ui.set_hand_element`) y se habilita para que el jugador pueda seleccionar una carta (`battle_ui.enable_hand(true)`).

Este método es fundamental para la fase de movimiento y selección de cartas del turno del jugador humano.

#### `_on_card_selected(selected_card: Card) -> void`
Esta función es un *slot* que se activa cuando el jugador humano selecciona una carta de su mano a través de la interfaz de usuario. Está conectada a la señal `battle_ui.card_selected`.

**Funcionamiento:**
1.  **Registro de Carta:** Imprime en la consola el elemento y valor de la `selected_card` para seguimiento.
2.  **Actualización del Jugador:**
    *   Llama a `player.play_card(selected_card)` para ejecutar la lógica asociada a jugar la carta desde el mazo del jugador.
    *   Actualiza las propiedades `current_element` y `current_value` del `player` con los datos de la carta jugada.
3.  **Desactivar Mano:** Deshabilita la interacción con la mano del jugador en la interfaz (`battle_ui.enable_hand(false)`) una vez que la carta ha sido seleccionada y jugada.
4.  **Actualizar Estadísticas UI:** Refresca la visualización de las estadísticas de todos los jugadores (`battle_ui.refresh_player_stats(players)`) para reflejar cualquier cambio producido por la carta jugada (ej. pérdida de una carta del mazo).
5.  **Notificar Fin de Turno:** Emite la señal `player_turn_ended()`. Esta señal es clave para la máquina de estados, ya que indica que la fase de acción del jugador humano ha concluido y el `BattleManager` puede proceder a la siguiente fase o al siguiente turno.

Este método coordina la acción más importante del turno del jugador: la selección y juego de una carta.