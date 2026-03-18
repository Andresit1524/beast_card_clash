# `Hand`
Este script define la clase `Hand`, que extiende `Path2D` y es responsable de gestionar la visualización y el comportamiento de la mano de cartas del jugador en el juego. Su función principal es organizar dinámicamente las cartas a lo largo de un camino 2D predefinido, permitiendo animaciones de movimiento, escalado y ocultamiento. Además, es capaz de inicializar la mano a partir de una baraja de cartas y de aplicar reglas de juego, como deshabilitar cartas que no coinciden con el elemento "roca" actual del jugador.

La clase `Hand` interactúa con el sistema de cartas (`CardScene.Card`) y con constantes globales (`GameConstants.Elements`, `Player.INITIAL_CARDS`), siendo un componente clave para la interfaz de usuario del juego y las mecánicas de estrategia elemental.

# Métodos

## Otros métodos

### `set_from_deck(deck: Array[CardScene.Card]) -> void`
Este método inicializa o reinicializa la mano de cartas del jugador a partir de una `Array` de objetos `CardScene.Card` que representan una baraja. Se encarga de la creación visual de las cartas en la escena.

**Funcionamiento:**
1.  **Limpieza:** Elimina todas las cartas que ya existen en la mano para asegurar una base limpia.
    ```gdscript
    for card in get_children():
        card.queue_free()
    ```
2.  **Instanciación:** Itera sobre la `deck` proporcionada (o usa un tamaño por defecto si la baraja es nula) y por cada carta:
    *   Crea un nuevo nodo `PathFollow2D`. Este nodo se encarga de posicionar la carta a lo largo del `Path2D` de la mano.
    *   Instancia una nueva `CardScene` (la escena de la carta individual) y la añade como hija del `PathFollow2D`.
    *   Establece las propiedades de la nueva carta (`element`, `value`, `hide_card`) basándose en los datos de la baraja o en valores por defecto.
3.  **Actualización:** Finalmente, llama a `_refresh_cards()` para aplicar el escalado, posicionamiento y estado de visibilidad iniciales a las cartas recién creadas.

**Interacción:**
*   Este método es fundamental para el `BattleManager` (según los comentarios del código), ya que permite configurar la mano del jugador al inicio de una ronda o cuando se necesita repoblar la mano.
*   Requiere que `card_scene` (definida como `@export var card_scene: PackedScene`) esté correctamente configurada en el editor para instanciar la escena de la carta.
*   Utiliza la constante `Player.INITIAL_CARDS` si la `deck` está vacía, lo que sugiere una dependencia de un script o clase `Player` que define esta constante.

### `_refresh_cards() -> void`
Es un método interno (`_` prefijo) invocado por los *setters* de las propiedades `hide_cards`, `card_scale`, `current_rock`, y por el método `set_from_deck()`. Su propósito es actualizar la posición, escala y el estado de habilitación/deshabilitación de todas las cartas en la mano.

**Funcionamiento:**
1.  **Obtención de Cartas:** Recupera todos los nodos hijos de la `Hand`, que se espera que sean instancias de `PathFollow2D` (cada una conteniendo una `CardScene` como su hijo).
2.  **Animación (Tween):** Crea un `Tween` para animar suavemente los cambios de propiedades, como la posición de la mano o el `progress_ratio` de las cartas individuales.
    ```gdscript
    var tween := create_tween()
    tween.set_parallel().set_trans(Tween.TRANS_SINE)
    ```
3.  **Ocultar/Mostrar Mano:**
    *   Si `hide_cards` es `true`, la mano se anima para moverse hacia abajo por `HIDE_OFFSET` (300 unidades en el eje Y), ocultándola de la vista, y el método finaliza.
    *   Si `hide_cards` es `false`, la mano se anima para regresar a su `_start_position` (su posición original al cargar la escena).
4.  **Posicionamiento y Escala de Cartas:**
    *   Itera sobre cada `PathFollow2D` (`card_pos`) y su `Card` hija.
    *   Calcula un `final_pos` para el `progress_ratio` de cada `PathFollow2D`, distribuyendo las cartas uniformemente a lo largo del `Path2D`. La primera carta se posiciona en el final del path y la última en el inicio (o viceversa dependiendo del `Path2D` configurado).
    *   Aplica el `card_scale` actual a la escala `Vector2` de cada carta.
    ```gdscript
    var final_pos = float(card_count - i - 1) / max(card_count - 1, 1) if i < card_count else 0
    tween.tween_property(card_pos, "progress_ratio", final_pos, MOVE_TIME)
    card.scale = Vector2(card_scale, card_scale)
    ```
5.  **Deshabilitación por Elemento:** Si `current_rock` tiene un elemento diferente de `NONE`, desactiva las cartas cuyo `element` no coincida con `current_rock`. Esto sugiere una mecánica de juego donde solo las cartas de un cierto elemento pueden ser jugadas en un momento dado. Si `current_rock` es `NONE`, todas las cartas se habilitan.
    ```gdscript
    if current_rock != GameConstants.Elements.NONE:
        card.disable_card = card.element != current_rock
    else:
        card.disable_card = false
    ```

**Interacción:**
*   Este método es el núcleo de la actualización visual de la mano. Cualquier cambio en las propiedades `hide_cards`, `card_scale` o `current_rock` en el editor o mediante código activa este método, asegurando que la visualización de la mano se actualice automáticamente.
*   Depende de la correcta configuración del `Path2D` en el editor para definir la curva a lo largo de la cual se distribuyen las cartas.
*   Interactúa con la propiedad `disable_card` de la `CardScene`, lo que implica que la `CardScene` debe implementar esta propiedad para manejar su estado visual o interactivo.
*   Utiliza `GameConstants.Elements` para comparar los elementos, lo que indica la existencia de una enumeración global de elementos.

### `get_cards() -> Array`
Este método proporciona un listado de todas las instancias de cartas (`CardScene`) que están actualmente en la mano.

**Funcionamiento:**
1.  **Iteración:** Recorre todos los hijos del nodo `Hand`.
2.  **Extracción de Cartas:** Asumiendo que cada hijo es un `PathFollow2D` que a su vez tiene como primer hijo la `CardScene` real, extrae estas instancias de `CardScene` y las añade a un `Array`.
    ```gdscript
    # ? La estructura de la baraja de cartas en el árbol de escenas es:
    # ? - Hand (nodo actual)
    # ?     - PathFollow2D (Posición)
    # ?         - Card (Carta)
    # ?     - ...
    for card_pos in get_children():
        cards.append(card_pos.get_child(0))
    ```
3.  **Retorno:** Devuelve el `Array` con todas las referencias a las cartas.

**Interacción:**
*   Este método es útil para cualquier otro script que necesite acceder directamente a las cartas individuales en la mano para, por ejemplo, aplicar efectos, verificar su estado o interactuar con ellas.