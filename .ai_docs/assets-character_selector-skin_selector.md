# `skin_selection_screen`
Este script gestiona la lógica y las interacciones de la pantalla de selección de skins de personaje, que permite a los jugadores elegir la apariencia de su "Bestia". Se encarga de inicializar la interfaz de usuario, asignar skins visuales a los personajes seleccionables, manejar la selección del jugador y preparar los datos necesarios para la siguiente fase del juego, el selector de equipo.

El script asume la existencia de nodos de personaje que emiten una señal cuando son seleccionados, y se integra con sistemas globales del proyecto como `GameConstants`, `PlayerStats` y `SceneManager` para manejar la persistencia de datos y las transiciones de escena.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez cuando el nodo y todos sus hijos están listos. Su función principal es inicializar la pantalla de selección de skins:

1.  **Iteración de personajes:** Recorre todos los nodos hijos del nodo `characters_list_node`. Se espera que cada uno de estos hijos represente un personaje seleccionable en la interfaz.

    ```gdscript
    var characters = characters_list_node.get_children()
    for i in characters.size():
        var character = characters[i]
        # ...
    ```

2.  **Obtención de Mesh del personaje:** Para cada personaje, intenta obtener su malla 3D, asumiendo que es el segundo hijo del nodo del personaje (`character.get_child(1)`). Esta malla es utilizada para aplicar la skin visual.

    ```gdscript
    var character_mesh: MeshInstance3D = character.get_child(1)
    ```

3.  **Conexión de señal:** Conecta la señal `skin_selected` emitida por cada nodo de personaje al método local `_change_skin`. Esto permite que el script reaccione cuando el jugador selecciona un personaje.

    ```gdscript
    character.skin_selected.connect(_change_skin)
    ```

4.  **Asignación de material inicial:** Asigna un material del array `skins` a la propiedad `material_override` de la malla de cada personaje. La asignación se realiza en función del índice `i`, lo que implica que el orden de los materiales en el array `skins` debe corresponder al orden de los personajes en `characters_list_node`.

    ```gdscript
    character_mesh.material_override = skins[i]
    ```

## Otros métodos

### `_change_skin(skin_index: int)`
Este método es llamado cuando un jugador selecciona una skin de personaje, recibiendo el índice de la skin seleccionada.

1.  **Actualización de la skin de previsualización:** Modifica el `material_override` de `current_skin_mesh` con el material correspondiente del array `skins` según `skin_index`. Esto actualiza visualmente la malla que muestra la skin actualmente seleccionada al jugador.

    ```gdscript
    current_skin_mesh.material_override = skins[skin_index]
    ```

2.  **Actualización de la skin actual:** Asigna a la variable `current_skin` el identificador de la skin seleccionada. Este identificador se obtiene del diccionario `GameConstants.SKINS`, específicamente de las skins asociadas a `GameConstants.Species.BEAR` en el índice `skin_index`.
    > **Nota**
    > Según el comentario en el código, esta implementación está temporalmente limitada a skins de "oso".

    ```gdscript
    current_skin = GameConstants.SKINS[GameConstants.Species.BEAR][skin_index]
    ```

3.  **Registro de depuración:** Imprime un mensaje en la consola de depuración indicando qué skin fue seleccionada.

    ```gdscript
    print_debug("Skin %d seleccionada" % skin_index)
    ```

## Funciones asociadas a señales

#### `_on_next_button_pressed()`
Esta función se asume que es el callback de una señal emitida por un botón de "siguiente" en la interfaz. Se encarga de procesar la selección del jugador y realizar la transición a la siguiente escena del juego.

1.  **Establecimiento de especie del jugador:** Establece la especie del jugador en el singleton `PlayerStats` a `GameConstants.Species.BEAR`.
    > **Advertencia**
    > El código incluye una advertencia explícita (`push_warning`) indicando que, por ahora, solo se trabaja con skins de oso, lo que refuerza la limitación mencionada anteriormente. Esto debe ser considerado por otros desarrolladores.

    ```gdscript
    PlayerStats.species = GameConstants.Species.BEAR
    push_warning("Por ahora solo se trabajan las skins de oso")
    ```

2.  **Establecimiento de skin del jugador:** Asigna el valor de `current_skin` (la skin seleccionada por el jugador) a la propiedad `skin` del singleton `PlayerStats`.

    ```gdscript
    PlayerStats.skin = current_skin
    ```

3.  **Transición de escena:** Utiliza el singleton `SceneManager` para cambiar la escena actual a "team_selector", llevando al jugador a la siguiente fase de configuración del equipo.

    ```gdscript
    SceneManager.change_to_scene("team_selector")
    ```