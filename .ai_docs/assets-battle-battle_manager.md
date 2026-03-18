# `BattleManager`
El script `BattleManager`, que extiende `Node`, es el orquestador central para la lógica y configuración inicial de una instancia de batalla en **Beast Card Clash**. Su propósito es actuar como un puente clave entre los datos fundamentales del juego (jugadores, dado, interfaz de usuario) y la máquina de estados de la batalla, asegurando una experiencia de juego coherente.

Las responsabilidades principales de `BattleManager` incluyen la inicialización del jugador humano y de los oponentes controlados por la IA (bots), la gestión de sus mazos de cartas, y la configuración del estado inicial de la interfaz de usuario de la batalla. Además, establece conexiones para actualizaciones en tiempo real y gestiona una `StateMachine` para controlar las fases y transiciones lógicas del juego de estrategia por turnos. Este script se posiciona como el centro principal para todos los datos e interacciones específicas de la batalla, sentando las bases para el desarrollo de la experiencia estratégica del juego de cartas.

## Propiedades y Componentes Clave

*   **`MAX_PLAYERS: int = 4`**: Una constante que define el número máximo de jugadores (incluyendo al humano y los bots) que pueden participar en una única batalla.

*   **`battle_ui: BattleUI`**: Una referencia exportada al nodo o script que gestiona la interfaz de usuario específica de la batalla. Es crucial para mostrar la información del juego al jugador y para recibir entradas de la UI.

*   **`dice: Dice`**: Una referencia exportada al nodo o script que representa el dado del juego. Es un elemento interactivo que probablemente influye en las decisiones o resultados del turno.

*   **`state_machine: StateMachine`**: Una referencia a un nodo `StateMachine` en el árbol de escenas, obtenida al cargar el nodo (usando `%StateMachine`). Esta máquina de estados es fundamental para controlar el flujo y las diferentes fases de la batalla (ej. turno del jugador, turno de la IA, fase de resolución, etc.).

*   **`player: Player`**: Una instancia del objeto `Player` que representa al jugador humano. Contiene su mazo, mano, estadísticas y otras propiedades relacionadas.

*   **`players: Array[Player]`**: Un array que almacena instancias de `Player` para todos los participantes en la batalla, incluyendo tanto al jugador humano como a todos los bots.

*   **`rocks: Array[RockScene.Rock]`**: Un array declarado para almacenar objetos de tipo `RockScene.Rock`. Aunque no se utiliza explícitamente en el fragmento de código proporcionado, su presencia sugiere la existencia de elementos de escenario (rocas) que podrían ser interactivos, destructibles o tener propiedades que afectan el juego.

# Métodos

## Otros métodos

### `setup_player() -> void`
Este método es responsable de inicializar al jugador humano al comienzo de la batalla.

1.  **Creación del Jugador**: Instancia un nuevo objeto `Player` utilizando el nombre y equipo definidos en la clase estática `PlayerStats`, y lo configura como no-bot (`false`).
    ```gdscript
    player = Player.new(PlayerStats.player_name, PlayerStats.team, false)
    ```
2.  **Creación del Mazo**: Llama al método `create_deck()` en el objeto `player` recién creado. Se espera que este método se encargue de poblar el mazo inicial del jugador con las cartas correspondientes.
3.  **Registro en el Juego**: Añade la instancia del jugador humano al array `players`, que es la lista central de todos los participantes activos en la batalla.
    ```gdscript
    players.append(player)
    ```
4.  **Configuración Temporal**: Incluye una llamada a `player.randomize()`.
    > [!NOTE] Comportamiento Temporal
    > La llamada a `player.randomize()` es una funcionalidad provisional, probablemente utilizada para pruebas o para inicializar rápidamente aspectos del jugador durante el desarrollo sin una configuración completa. Este método es susceptible de ser eliminado o reemplazado por una lógica de inicialización más robusta en futuras versiones del juego.
5.  **Conexión de UI**: Establece una conexión de señal crítica: cuando la señal `deck_updated` del `player` se emite (lo que indica un cambio en el mazo del jugador), el método `set_hand_from_deck` del `battle_ui` es llamado. Esto asegura que la interfaz de usuario de la batalla actualice automáticamente la mano del jugador para reflejar el estado actual de su mazo.
    ```gdscript
    player.deck_updated.connect(battle_ui.set_hand_from_deck)
    ```

### `setup_bots() -> void`
Este método se encarga de generar e inicializar los oponentes controlados por la IA (bots) para la batalla actual.

1.  **Determinación del Número de Bots**: Calcula un número aleatorio de bots a crear, que varía entre 1 y `MAX_PLAYERS - 1`. Esto permite una diversidad en el número de oponentes en cada batalla.
    ```gdscript
    var bots_count := randi_range(1, MAX_PLAYERS - 1)
    ```
2.  **Creación e Inicialización de Bots**: Itera para crear cada bot:
    *   Instancia un nuevo objeto `Player` para el bot.
    *   Llama a `create_deck()` en el bot para establecer su colección inicial de cartas.
    *   Añade la instancia del `new_bot` al array `players`, integrándolo en la lista de participantes de la batalla.
    *   Imprime un mensaje de depuración indicando la creación del bot y su nombre generado automáticamente.
    *   **Configuración Temporal**: Llama a `new_bot.randomize()`.
        > [!NOTE] Comportamiento Temporal
        > Al igual que con el jugador humano, la llamada a `new_bot.randomize()` es una funcionalidad provisional. Se utiliza probablemente para inicializar rápidamente los estados o características de los bots con fines de prueba o desarrollo, y podría ser eliminada o reemplazada en el futuro.
    ```gdscript
    for i in range(bots_count):
        var new_bot := Player.new()
        new_bot.create_deck()
        players.append(new_bot)
        print_debug("[BattleManager] Nuevo bot creado: %s!" % new_bot.player_name)
        # ! Temporal
        new_bot.randomize()
    ```
3.  **Confirmación de Bots**: Después de crear todos los bots, imprime un mensaje de depuración final mostrando la cantidad de jugadores bot que se han generado para esta partida.
    ```gdscript
    print_debug("[BattleManager] %s jugadores en juego" % bots_count)
    ```

### `setup_ui() -> void`
Este método configura el estado inicial de varios elementos de la interfaz de usuario relacionados con la batalla.

1.  **Deshabilitar Dado**: Establece la propiedad `clickable` del objeto `dice` a `false`. Esto asegura que el dado no sea interactivo o no pueda ser utilizado hasta que el estado del juego lo permita.
    ```gdscript
    dice.clickable = false
    ```
2.  **Actualizar Estadísticas de Jugadores**: Llama al método `refresh_player_stats` en el `battle_ui`, pasándole el array `players`. Esto instruye a la UI para que muestre las estadísticas iniciales de todos los participantes en la batalla.
    ```gdscript
    battle_ui.refresh_player_stats(players)
    ```
3.  **Mostrar Mano Inicial del Jugador**: Llama al método `set_hand_from_deck` en el `battle_ui`, proporcionándole el mazo actual del jugador humano (`player.deck`). Esto asegura que la mano inicial del jugador se muestre correctamente en la interfaz. Esta llamada complementa la conexión de señal establecida en `setup_player()` para las actualizaciones continuas.
    ```gdscript
    battle_ui.set_hand_from_deck(player.deck)
    ```