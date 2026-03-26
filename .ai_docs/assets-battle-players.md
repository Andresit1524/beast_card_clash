# `Players`
El script `Players` define una clase que extiende `Node3D`, actuando como un contenedor para los nodos de jugador (`Player`) dentro de la escena 3D. Su propósito principal es gestionar la presencia y el ciclo de vida de los jugadores activos, añadiéndolos o eliminándolos de la escena según sea necesario, y notificando a otros componentes del juego sobre estos cambios. Este nodo facilita la centralización de la lógica relacionada con la colección de jugadores, permitiendo que otras partes del juego consulten el estado actual de los jugadores o reaccionen a eventos como la eliminación de un jugador de la partida.

La clase también declara una señal, `players_updated`, que se emite cada vez que la lista de jugadores activos en la escena cambia, proporcionando una interfaz limpia para que otros sistemas reaccionen a estas modificaciones.

# Métodos

## Otros métodos

### `add_players(players_list: Array[Player]) -> void`
Este método es responsable de sincronizar los nodos de `Player` presentes en la escena con una lista proporcionada de objetos `Player`. Su funcionamiento se divide en dos fases principales:

1.  **Eliminación de jugadores obsoletos:** Itera sobre todos los nodos hijos actuales del nodo `Players`. Si un nodo hijo (que se espera sea un `Player`) no se encuentra en la `players_list` proporcionada, se asume que ese jugador ya no debe estar en la escena y se procede a liberarlo de la memoria utilizando `player.free()`.

    ```gdscript
    for player in get_children():
        print("[Players] Jugador eliminado de la escena: %s" % player.player_name)
        if player not in players_list: player.free()
    ```

2.  **Adición de nuevos jugadores:** A continuación, el método itera sobre la `players_list` proporcionada. Para cada `Player` en esta lista, verifica si ya es un nodo hijo de `Players`. Si no lo es, el `Player` se añade como hijo mediante `add_child(player)`. Durante este proceso de adición, se establece una conexión vital: la señal `game_over` del `Player` se conecta al método interno `_on_player_game_over` de este nodo `Players`. Esto asegura que el contenedor `Players` pueda reaccionar automáticamente cuando cualquiera de sus jugadores hijos declare el fin de su partida.

    ```gdscript
    for player in players_list:
        if player in get_children(): continue

        # Nos conectamos a la señal del jugador
        player.game_over.connect(_on_player_game_over)

        add_child(player)
        print("[Players] Jugador añadido a la escena: %s" % player.player_name)
    ```

Este método es la interfaz principal para inicializar o actualizar la colección de jugadores en el juego.

## Funciones asociadas a señales

#### `_on_player_game_over(player: Player) -> void`
Este método actúa como un _callback_ o ranura (slot) para la señal `game_over` emitida por los nodos de `Player`. Cuando un jugador emite su señal `game_over` (indicando que ha perdido o ha sido eliminado del juego), este método se ejecuta con el `Player` que emitió la señal como argumento.

Su función es la siguiente:

1.  **Eliminación segura del jugador:** Verifica si el `player` que ha emitido la señal es todavía un nodo hijo de `Players`. Si lo es, lo pone en cola para ser liberado de la memoria de forma segura utilizando `player.queue_free()`. Esto previene errores comunes que pueden surgir al intentar liberar nodos que ya no están en el árbol de la escena o que están en medio de un proceso.

    ```gdscript
    func _on_player_game_over(player: Player) -> void:
        if player in get_children(): player.queue_free()

        print("[Players] Jugador eliminado de la escena: %s" % player.player_name)
    ```

2.  **Notificación de actualización:** Una vez que el jugador ha sido marcado para su eliminación, el método emite la señal `players_updated`, pasando una nueva `Array` que contiene todos los nodos hijos restantes de `Players`. Esto permite que otros sistemas en el juego (como la interfaz de usuario, la lógica de la ronda o el controlador del juego) sean informados instantáneamente sobre el cambio en la lista de jugadores activos y puedan reaccionar consecuentemente, por ejemplo, actualizando un marcador o verificando las condiciones de victoria/derrota.

    ```gdscript
    players_updated.emit(get_children())
    ```