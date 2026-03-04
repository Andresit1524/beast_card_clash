# `PlayerCharacterSelection`
Este script actúa como el controlador principal para la pantalla de selección de skins de personajes. Se encarga de inicializar las opciones de skins disponibles, gestionar la interacción del jugador para cambiar la skin visualizada, y preparar los datos de la selección para ser utilizados en escenas posteriores del juego, como el selector de equipo.

El script funciona conectándose a los nodos de personaje disponibles en la escena, asignándoles sus skins iniciales y escuchando las interacciones del jugador (clics) para actualizar la visualización de la skin. Utiliza las propiedades exportadas `current_skin_mesh` para la visualización activa, `characters_list_node` como contenedor de los personajes seleccionables y `skins` como un arreglo de materiales para las distintas apariencias. Cuando el jugador confirma su selección, el script actualiza las estadísticas del jugador (`PlayerStats`) con la skin elegida y transiciona a la siguiente escena usando `SceneManager`.

# Métodos

## Métodos de Godot

### `_ready()`
Este método es parte del ciclo de vida de Godot y se ejecuta una vez cuando el nodo y todos sus hijos han entrado en el árbol de escena. Su función principal es inicializar el sistema de selección de skins:

1.  **Obtención de Personajes:** Recupera todos los nodos hijos del nodo `characters_list_node`, asumiendo que cada hijo representa un personaje seleccionable.
    ```gdscript
    var characters = characters_list_node.get_children()
    ```
2.  **Inicialización por Personaje:** Itera sobre cada uno de estos nodos de personaje para configurarlos:
    *   Obtiene la malla 3D (`MeshInstance3D`) del personaje. Se asume que esta malla es el segundo hijo (índice `1`) del nodo `character` que se va a modificar visualmente.
        ```gdscript
        var character_mesh: MeshInstance3D = character.get_child(1)
        ```
    *   Conecta la señal `skin_selected` emitida por el nodo `character` al método `_change_skin` de este script. Esto permite que el script reaccione cuando un personaje es "seleccionado" (presumiblemente por un clic del jugador) en la interfaz.
        ```gdscript
        character.skin_selected.connect(_change_skin)
        ```
    *   Asigna un material (`Material`) de la colección `skins` a la propiedad `material_override` de la malla del personaje. Cada personaje recibe la skin correspondiente a su índice en el arreglo `skins`.
        ```gdscript
        character_mesh.material_override = skins[i]
        ```

## Otros métodos

### `_change_skin(skin_index: int) -> void`
Este método es responsable de actualizar visualmente la skin del personaje actualmente seleccionada en la pantalla principal y de registrar la elección del jugador. Recibe un `skin_index` entero que corresponde a la skin elegida del arreglo `skins`:

1.  **Actualización Visual Principal:** Cambia la propiedad `material_override` de la malla `current_skin_mesh` (que representa la skin activa en la UI principal) por el material de la colección `skins` en la posición `skin_index`.
    ```gdscript
    current_skin_mesh.material_override = skins[skin_index]
    ```
2.  **Registro de Selección Interna:** Almacena el identificador de la skin seleccionada en la variable `current_skin`. Para esto, accede a una constante global (`GameConstants.SKINS`) y a un tipo de especie específico (`GameConstants.Species.BEAR`), lo que sugiere que las skins están organizadas por especies y que la lógica actual está limitada.
    ```gdscript
    current_skin = GameConstants.SKINS[GameConstants.Species.BEAR][skin_index]
    ```
3.  **Depuración:** Imprime un mensaje de depuración en la consola indicando el índice de la skin seleccionada.
    ```gdscript
    print_debug("Skin %d seleccionada" % skin_index)
    ```
    > [!NOTE]
    > Un comentario directamente en el código (`! Por ahora solo estamos trabajando con las skins de oso`) indica que la implementación actual de la lógica de skins está centrada exclusivamente en la especie "Oso" y podría requerir extensiones futuras para manejar otras especies.

### `_on_next_button_pressed() -> void`
Este método se ejecuta cuando se activa una señal asociada al botón "siguiente" en la interfaz de usuario. Su propósito es finalizar la selección de skin por parte del jugador y preparar los datos necesarios para la siguiente etapa del juego:

1.  **Actualización de Estadísticas del Jugador:** Establece la especie y la skin elegida en el objeto global `PlayerStats`. Actualmente, la especie se fija como `GameConstants.Species.BEAR`, lo que refuerza la limitación actual a las skins de oso.
    ```gdscript
    PlayerStats.species = GameConstants.Species.BEAR
    PlayerStats.skin = current_skin
    ```
2.  **Advertencia de Desarrollo:** Emite una advertencia de Godot, informando sobre la limitación temporal del juego a las skins de oso.
    ```gdscript
    push_warning("Por ahora solo se trabajan las skins de oso")
    ```
3.  **Transición de Escena:** Utiliza el `SceneManager` global para cambiar la escena actual a la escena con el nombre `team_selector`, indicando que el siguiente paso en el flujo del juego es la selección del equipo.
    ```gdscript
    SceneManager.change_to_scene("team_selector")
    ```

## Funciones asociadas a señales

#### `_change_skin(skin_index: int) -> void`
Este método está conectado a la señal `skin_selected` que es emitida por cada uno de los nodos de personaje (`character`) que son hijos de `characters_list_node`. Cuando un personaje en la interfaz es "seleccionado" por el jugador (presumiblemente a través de un clic o interacción táctil), esta señal se emite con el índice de la skin correspondiente. La invocación de `_change_skin` entonces actualiza la skin visualizada en la malla principal del selector y registra la elección interna.

#### `_on_next_button_pressed() -> void`
Este método se activa en respuesta a la señal `pressed` de un nodo de botón en la interfaz de usuario, comúnmente etiquetado como "Siguiente". Su ejecución indica que el jugador ha finalizado su elección de skin y desea avanzar a la siguiente pantalla del juego para configurar su equipo.