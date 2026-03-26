# `BattleTurn`
`BattleTurn` es una clase de estado que extiende de `BattleState`, diseñada para orquestar y gestionar el turno del jugador humano dentro del sistema de batalla de **Beast Card Clash**. Su responsabilidad principal es iniciar el turno, guiar al jugador a través de las acciones clave como lanzar el dado y seleccionar un destino, y finalmente delegar el control para la transición al siguiente estado de la batalla una vez que el turno del jugador ha concluido. Este script centraliza la lógica para habilitar las interacciones del jugador y responder a sus decisiones durante su fase activa en el combate.

# Métodos

## Métodos de Godot

### `start() -> void`
Este método es el punto de entrada para el estado `BattleTurn` y se ejecuta cada vez que este estado es activado por el `manager` de la batalla. Contiene la secuencia completa de eventos que componen el turno de un jugador:

1.  **Activación del dado:**
    ```gdscript
    manager.battle_world.enable_dice(true)
    ```
    Se le indica al componente `battle_world` (gestionado por el `manager`) que habilite la interfaz del dado, permitiendo al jugador interactuar con él para lanzarlo.

2.  **Espera al lanzamiento del dado:**
    ```gdscript
    await manager.battle_world.dice_thrown
    var current_dice_value := manager.current_dice_value
    ```
    El método pausa su ejecución hasta que el dado es lanzado. Esto se logra esperando la señal `dice_thrown` emitida por `manager.battle_world`. Una vez que el dado ha sido lanzado y la señal emitida, se recupera el valor resultante del dado a través de `manager.current_dice_value`.

3.  **Cálculo de posiciones disponibles:**
    ```gdscript
    var current_pos = manager.player.current_rock_index
    var available_pos := [
        posmod(current_pos - current_dice_value, manager.get_rocks().size()),
        posmod(current_pos + current_dice_value, manager.get_rocks().size()),
    ]
    ```
    Utilizando el valor obtenido del dado, se calculan las dos posibles "rocas" (posiciones en el tablero de batalla) a las que el jugador puede moverse. Se toman en cuenta la posición actual del jugador (`manager.player.current_rock_index`) y el tamaño total del tablero (`manager.get_rocks().size()`) para asegurar que los movimientos sean cíclicos y válidos dentro de los límites del tablero usando `posmod`.

4.  **Habilitación de selección de rocas:**
    ```gdscript
    manager.battle_world.enable_rocks(available_pos)
    ```
    Una vez calculadas las posiciones a las que el jugador puede moverse, se le indica a `manager.battle_world` que resalte y active estas rocas específicas, esperando que el jugador elija una de ellas.
    > [!Note] Comportamiento delegado
    > La lógica de lo que ocurre *después* de que el jugador elige una roca (por ejemplo, el movimiento del jugador, la resolución de un duelo, etc.) no reside en este script `BattleTurn`. El comentario "El resto del juego, prácticamente, corre por cuenta de reacciones en el manager" indica que el `manager` es quien se encarga de procesar la selección del jugador y sus implicaciones. `BattleTurn` simplemente prepara el escenario para la interacción del jugador.

5.  **Espera a la finalización del turno del jugador:**
    ```gdscript
    await manager.player_turn_ended
    ```
    El método `start()` nuevamente pausa su ejecución, esta vez esperando la señal `player_turn_ended` emitida por el `manager`. Esta señal se dispara cuando el jugador ha completado todas sus acciones para el turno (por ejemplo, ha movido su personaje y/o realizado una acción en la nueva roca).

6.  **Transición al siguiente estado:**
    ```gdscript
    manager.switch_next_turn_state()
    ```
    Una vez que el turno del jugador ha finalizado, se invoca a `manager.switch_next_turn_state()` para que el `manager` cambie al siguiente estado de la máquina de estados de la batalla (por ejemplo, el turno del oponente, una fase de resolución, etc.). Esto asegura una progresión fluida a través de las diferentes etapas de un duelo.