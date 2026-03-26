# `BattleLoop`
El script `BattleLoop` extiende `BattleState` y encapsula la lógica para gestionar el turno de un jugador controlado por la inteligencia artificial (IA) o "bot". Su función principal es simular las decisiones que tomaría un jugador durante su turno en la fase de "loop" de la batalla. Esto incluye el lanzamiento de dados, la selección de la roca a la que moverse en el tablero, la elección de la carta a jugar y la actualización consecuente del estado del juego y la interfaz de usuario. Opera como un paso dentro de una máquina de estados de batalla, delegando las acciones complejas a componentes específicos gestionados por el `manager` principal.

# Métodos

## Otros métodos

### `start()`
Este método es el punto de entrada para la ejecución del turno de la IA, presumiblemente llamado cuando `BattleLoop` se convierte en el estado activo de la batalla. Orquesta una secuencia de acciones que simulan la toma de decisiones del bot y la interacción con el entorno de batalla.

Su funcionamiento detallado es el siguiente:

1.  **Espera inicial**: El bot espera un breve periodo de tiempo (`manager.WAIT_TIME`) antes de iniciar sus acciones. Esto proporciona una pausa visual para el jugador humano y simula un tiempo de "pensamiento" o procesamiento del bot.
    ```gdscript
    await get_tree().create_timer(manager.WAIT_TIME).timeout
    ```
2.  **Registro de turno**: Se imprime en consola un mensaje indicando qué jugador (bot) tiene el turno actual, utilizando el nombre del jugador (`manager.current_turn.player_name`).
3.  **Lanzamiento de dado**: Se solicita al componente `battle_world` del `manager` que realice un lanzamiento de dado (`manager.battle_world.throw_dice()`). El script `BattleLoop` espera la emisión de la señal `dice_thrown` de `battle_world` para obtener el resultado del dado, que luego se almacena en `current_dice_value` a través del `manager`.
    ```gdscript
    manager.battle_world.throw_dice()
    await manager.battle_world.dice_thrown
    var current_dice_value := manager.current_dice_value
    ```
4.  **Selección de roca**: Basándose en el valor del dado obtenido (`current_dice_value`) y la posición actual del jugador (`manager.current_turn.current_rock_index`), el bot calcula dos posibles rocas a las que puede moverse. Estas posiciones representan movimientos hacia adelante y hacia atrás en un circuito circular de rocas, utilizando la operación `posmod` para manejar el desbordamiento de índices. Luego, elige aleatoriamente una de estas dos opciones.
    ```gdscript
    var rock_choice: int = [
        posmod(manager.current_turn.current_rock_index - current_dice_value, manager.get_rocks().size()),
        posmod(manager.current_turn.current_rock_index + current_dice_value, manager.get_rocks().size()),
    ].pick_random()
    ```
5.  **Movimiento del jugador**: El bot instruye a su objeto de jugador (`manager.current_turn`) para que se mueva a la posición de la roca elegida (`manager.get_rocks()[rock_choice].position`) y actualiza su índice de roca actual. El método espera a que el movimiento se complete, lo cual es indicado por la señal `moved` emitida por el objeto del jugador.
    ```gdscript
    manager.current_turn.move_to(manager.get_rocks()[rock_choice].position, rock_choice)
    await manager.current_turn.moved
    ```
6.  **Determinación del elemento de la roca**: Se obtiene el elemento asociado a la roca seleccionada (`manager.get_rocks()[rock_choice].element`), lo cual es fundamental para la posterior elección de carta, ya que las cartas suelen estar asociadas a elementos.
7.  **Selección de carta**: El bot filtra su mazo de cartas (`manager.current_turn.deck`) para encontrar aquellas que coincidan con el `rock_choice_element` o que sean cartas "comodín" o sin elemento específico (evaluado por `not rock_choice_element`, lo que probablemente se refiere a un valor como `GameConstants.Elements.NONE`). De las cartas válidas resultantes, selecciona una al azar. Si no hay cartas válidas, `played_card` será `null`.
    ```gdscript
    var card_choices: Array = manager.current_turn.deck.filter(func(v):
        return v.element == rock_choice_element or not rock_choice_element
    )
    var played_card: Card = card_choices.pick_random() if card_choices else null
    ```
8.  **Manejo de turno saltado**: Si el bot no tiene cartas adecuadas para jugar con el elemento de la roca elegida (`if not played_card`), se considera que salta el turno. Se imprime un mensaje informativo, se registran los valores de elemento y poder del turno actual como `NONE` y `0` respectivamente en el jugador (`manager.current_turn.current_element`, `manager.current_turn.current_value`), y se delega el control al siguiente estado del `manager` (`manager.switch_next_turn_state()`) antes de finalizar la ejecución del método.
    ```gdscript
    if not played_card:
        print(
            "[BattleLoop] %s no tiene cartas de %s. Saltando turno."
            % [manager.current_turn.player_name, Utilities.get_enum_name(rock_choice_element, GameConstants.Elements)]
        )
        manager.current_turn.current_element = GameConstants.Elements.NONE
        manager.current_turn.current_value = 0
        manager.switch_next_turn_state()
        return
    ```
9.  **Guardado de valores de carta**: Antes de que la carta sea "liberada" o visualizada por la interfaz de usuario, se guardan su elemento (`card_element`) y su valor (`card_value`) en variables locales para asegurar que estos datos estén disponibles para la lógica del juego.
10. **Ejecución de carta y actualización de UI**:
    *   Se notifica al objeto del jugador (`manager.current_turn`) que se ha jugado una carta específica (`play_card(played_card)`).
    *   Se espera un tiempo más corto (`manager.WAIT_TIME / 2.0`) para permitir animaciones o procesamiento visual de la carta.
    *   Se actualizan las propiedades `current_element` y `current_value` del jugador con los datos de la carta jugada, registrando el impacto de la carta en el turno actual.
    *   Se solicita a la interfaz de usuario de batalla (`manager.battle_ui`) que actualice las estadísticas de todos los jugadores (`manager.players`) para reflejar los cambios.
    ```gdscript
    manager.current_turn.play_card(played_card)
    await get_tree().create_timer(manager.WAIT_TIME / 2.0).timeout
    manager.current_turn.current_element = card_element
    manager.current_turn.current_value = card_value
    manager.battle_ui.refresh_player_stats(manager.players)
    ```
11. **Registro de carta elegida**: Se imprime en consola la carta elegida por el bot, incluyendo su elemento y valor, utilizando la función auxiliar `Utilities.get_enum_name` para obtener el nombre legible del elemento a partir de su ID de enumeración.
12. **Delegación del siguiente estado**: Finalmente, el control del flujo de la batalla se transfiere al `manager` llamando a `manager.switch_next_turn_state()`. Esta acción permite al `manager` decidir el siguiente estado del juego, que podría ser la fase de ataque, el turno del siguiente jugador, o cualquier otra transición de estado definida en la máquina de estados de batalla.