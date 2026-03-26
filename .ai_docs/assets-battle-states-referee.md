# `BattleReferee`
El script `BattleReferee` es una clase personalizada que hereda de `BattleState`, lo que indica su rol dentro de una máquina de estados para la gestión de batallas. Su función principal es arbitrar el final de cada ronda de combate, decidiendo los ganadores basándose en las elecciones de cartas de los jugadores, aplicando el daño correspondiente y preparando el campo de batalla para la siguiente fase. Actúa como el motor lógico que interpreta las jugadas y actualiza el estado del juego en consecuencia.

# Métodos

## Otros métodos

### `start() -> void`
Este método es el punto de entrada para el procesamiento de una nueva ronda de batalla. Se invoca cuando el estado de la batalla cambia a `BattleReferee`, indicando que es el momento de evaluar los resultados de las elecciones de cartas de los jugadores.

El flujo de este método es el siguiente:

1.  **Espera inicial:** El método comienza con una espera asíncrona (`await`) utilizando `get_tree().create_timer(manager.WAIT_TIME).timeout`. Esto introduce un breve retraso antes de que comience la lógica de comparación de la ronda, permitiendo, por ejemplo, que las animaciones o transiciones visuales de las elecciones de los jugadores se muestren antes de que se revelen los resultados. `manager.WAIT_TIME` es una constante definida en el gestor de batallas (`manager`) que determina la duración de esta espera.

2.  **Creación de pares de enfrentamiento:** Se genera una lista `pairs` que contiene todas las combinaciones únicas de dos jugadores para comparar sus cartas. Se itera sobre todos los jugadores (`manager.players`) para crear estos pares, asegurándose de que:
    *   Un jugador no se compare consigo mismo (`if player == rival: continue`).
    *   Los pares no se dupliquen (ej. `[player1, player2]` y `[player2, player1]` son considerados el mismo enfrentamiento, se omite el segundo).

    ```gdscript
    var pairs := []
    for player in manager.players:
        for rival in manager.players:
            # Omite a sí mismo
            if player == rival: continue

            # Omite duplicados
            if [player, rival] in pairs or [rival, player] in pairs: continue
            pairs.append([player, rival])
    ```

3.  **Comparación y aplicación de daño:** Por cada par de jugadores en la lista `pairs`, se invoca el método privado `_compare_players(player1, player2)` para determinar el ganador.
    *   Si el resultado es `1`, `player1` gana, y `player2.apply_damage(1)` es llamado para infligir daño al segundo jugador.
    *   Si el resultado es `-1`, `player2` gana, y `player1.apply_damage(1)` es llamado.
    *   Si el resultado es `0`, hay un empate y no se aplica daño a ninguno.

4.  **Reseteo de elecciones:** Después de procesar todos los enfrentamientos, las elecciones de cartas de cada jugador se resetean. Sus propiedades `current_element` y `current_value` se establecen a `GameConstants.Elements.NONE` y `0` respectivamente, preparándolos para la siguiente ronda.

5.  **Actualización de la interfaz de usuario:** Se llama a `manager.battle_ui.refresh_player_stats(manager.players)` para actualizar visualmente la interfaz de usuario con los nuevos puntos de vida o estado de los jugadores tras la aplicación del daño.

6.  **Emisión de señal:** Finalmente, se emite la señal `manager.round_handled.emit()`. Esta señal notifica al `BattleManager` (o cualquier otro componente que la esté escuchando) que la ronda actual ha sido completamente procesada, permitiendo que el gestor de la batalla decida el siguiente estado del juego (ej. pasar a la fase de elección de cartas, o terminar la partida si hay un ganador).

### `_compare_players(player1: Player, player2: Player) -> int`
Este método privado es el corazón de la lógica de arbitraje. Recibe dos objetos `Player` y determina el resultado de su enfrentamiento basándose en las cartas (`current_element` y `current_value`) que han elegido para la ronda. Retorna un entero:
*   `1` si `player1` gana.
*   `-1` si `player2` gana.
*   `0` si hay un empate.

La lógica de comparación se estructura de la siguiente manera:

1.  **Verificación de cartas jugadas:** Si alguno de los jugadores no ha seleccionado una carta (su `current_element` es `GameConstants.Elements.NONE` o equivalente a `false` en una evaluación booleana), el enfrentamiento resulta en un empate inmediato, y se retorna `0`.

    ```gdscript
    if not player1.current_element or not player2.current_element: return 0
    ```
    > [!NOTE]
    > Se indica que esta regla "puede cambiar", lo que sugiere que en el futuro podría haber penalizaciones o ventajas por no jugar una carta.

2.  **Elementos iguales:** Si ambos jugadores han elegido cartas del mismo elemento (`player1.current_element == player2.current_element`), el desempate se resuelve comparando los valores numéricos de sus cartas (`current_value`).
    *   El jugador con el valor más alto gana.
    *   Si los valores son iguales, el enfrentamiento es un empate.

    ```gdscript
    if player1.current_element == player2.current_element:
        match player1.current_value:
            var _p when player1.current_value > player2.current_value: return 1
            var _p when player1.current_value < player2.current_value: return -1
            _: return 0
    ```

3.  **Elementos diferentes:** Si los elementos de las cartas son diferentes, el ganador se determina siguiendo un conjunto predefinido de reglas de "piedra, papel o tijera" elemental. Estas reglas están detalladas en un diagrama externo (`res://.docs/ganadores entre elementos.png`). El código implementa esta lógica utilizando `match` anidados: primero por el elemento de `player1` y luego por el elemento de `player2`.

    *   **Ejemplo para `GameConstants.Elements.AIR`:**
        ```gdscript
        GameConstants.Elements.AIR:
            match player2.current_element:
                GameConstants.Elements.EARTH: return 1  # Aire gana a Tierra
                GameConstants.Elements.ENERGY: return -1 # Energía gana a Aire
                GameConstants.Elements.FIRE: return -1  # Fuego gana a Aire
                GameConstants.Elements.WATER: return 1  # Aire gana a Agua
        ```
    Este patrón se repite para todos los elementos (`EARTH`, `ENERGY`, `FIRE`, `WATER`).

4.  **Manejo de casos no definidos:** Si, por alguna razón, los elementos de los jugadores no encajan en ninguna de las combinaciones predefinidas (lo cual, según el comentario en el código, no debería ocurrir), se emite una advertencia (`push_warning`) indicando que el enfrentamiento no pudo ser definido y se retorna `0` (empate) como medida de seguridad.

    ```gdscript
    push_warning(
        "[BattleReferee] Enfrentamiento entre %s y %s no definible"
        % [player1.player_name, player2.player_name]
    )
    return 0
    ```