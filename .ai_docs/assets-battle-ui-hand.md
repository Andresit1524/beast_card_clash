# `Hand`
El script `Hand` es una clase de Godot que hereda de `Path2D` y gestiona la visualización y el comportamiento de un conjunto de cartas, simulando la mano de un jugador en un juego de cartas. Su función principal es organizar y animar las cartas a lo largo de una trayectoria definida, permitiendo transiciones suaves entre diferentes estados como "normal" y "oculto", así como filtrar la visibilidad o interactividad de las cartas según el elemento del jugador.

La `Hand` utiliza nodos `PathFollow2D` como contenedores para las cartas (`Card`), permitiendo que las cartas se posicionen dinámetricamente a lo largo de la `curve` definida por el nodo `Hand`. Esto es crucial para crear el efecto de las cartas distribuidas en un abanico o apiladas de forma ordenada. El script se encarga de añadir y remover cartas de la mano, actualizar sus propiedades visuales (escala, rotación) y su interactividad basándose en las propiedades exportadas del nodo `Hand`.

# Métodos

## Otros métodos

### `set_from_deck(deck: Array[Card]) -> void`
Este método es el encargado de inicializar o actualizar la mano de cartas en pantalla basándose en una baraja (`deck`) real proporcionada.

Su funcionamiento se divide en dos fases:
1.  **Eliminación de cartas no existentes:** Itera sobre todos los hijos actuales del nodo `Hand` (que se espera sean nodos `PathFollow2D` que contienen una carta). Si la carta envuelta por un `PathFollow2D` ya no se encuentra en el `deck` proporcionado, el `PathFollow2D` y su carta hija son liberados de la memoria (`queue_free()`). Esto asegura que solo las cartas que realmente pertenecen a la baraja actual permanezcan en la mano.
    ```gdscript
    for card_pos in get_children():
        var actual_card = card_pos.get_child(0)
        if not actual_card in deck: card_pos.queue_free()
    ```
2.  **Añadir nuevas cartas:** Itera sobre cada `card` en el `deck` proporcionado. Si una `card` no tiene un padre (lo que indica que es nueva en la mano), se crea un nuevo nodo `PathFollow2D`, se añade como hijo del nodo `Hand`, y la `card` se añade como hijo de este `PathFollow2D`. Antes de emparentar la `card`, se le asignan propiedades esenciales como `element`, `value` y se asegura que `hide_card` esté en `false` por defecto (aunque su estado final se determina en `_refresh_cards()`).
    ```gdscript
    for card in deck:
        if card.get_parent() != null: continue

        var new_card_pos := PathFollow2D.new()
        add_child(new_card_pos)

        card.set_properties({
            "element": card.element,
            "value": card.value,
            "hide_card": false,
        })
        new_card_pos.add_child(card)
    ```
Finalmente, el método llama a `_refresh_cards()` para asegurar que todas las cartas se posicionen y actualicen visualmente según los nuevos estados.

### `_refresh_cards() -> void`
Este método privado es el núcleo de la actualización visual y de estado de las cartas en la mano. Se llama automáticamente cuando cambian las propiedades exportadas `hide_cards`, `card_scale`, `current_element`, o después de una actualización del `deck` a través de `set_from_deck()`.

El método realiza las siguientes acciones:
1.  **Preparación del `Tween`:** Crea un `Tween` en modo paralelo (`set_parallel()`) con una transición `TRANS_SINE` para lograr animaciones suaves.
2.  **Aplicar estado oculto:** Llama a `_set_hidden_cards(hide_cards)` para aplicar los cambios de curva, escala y rotación de las cartas si `hide_cards` está activo.
3.  **Restablecer posición de la mano:** Anima la posición del nodo `Hand` a su `_start_position` inicial, que se almacena en `@onready var _start_position := position`. Esto asegura que la mano siempre retorne a su lugar base.
    ```gdscript
    tween.tween_property(self, "position", _start_position, MOVE_TIME)
    ```
4.  **Posicionar y ajustar cartas individuales:** Itera sobre cada `PathFollow2D` (card_pos) hijo del nodo `Hand`.
    *   **Cálculo de posición:** Calcula el `progress_ratio` final para cada `PathFollow2D`, distribuyendo las cartas uniformemente a lo largo de la `curve` de la `Path2D`. La fórmula `float(card_count - i - 1) / max(card_count - 1, 1)` asegura que las cartas se distribuyan desde el inicio al final de la curva.
    *   **Animación de posición:** Anima la propiedad `progress_ratio` de cada `PathFollow2D` a su `final_pos` calculada.
    *   **Desactivación de cartas:** Actualiza la propiedad `disable_card` de cada `Card`. Una carta se desactiva si `hide_cards` es `true` (la mano está oculta) o si `current_element` está definido y el `element` de la carta no coincide con el `current_element`. Esto es clave para las reglas del juego donde ciertas cartas pueden estar deshabilitadas según el contexto.
    ```gdscript
    # Posición y tamaño
    var final_pos = float(card_count - i - 1) / max(card_count - 1, 1) if i < card_count else 0
    tween.tween_property(card_pos, "progress_ratio", final_pos, MOVE_TIME)

    # Desactiva las cartas cuando se oculta la baraja o cuando el elemento no coincide
    card.disable_card = hide_cards or current_element and card.element != current_element
    ```

### `_set_hidden_cards(is_hidden: bool) -> void`
Este método privado controla la transición visual de las cartas entre un estado normal y un estado "oculto" o "escondido".

Las acciones que realiza son:
1.  **Preparación del `Tween`:** Crea un `Tween` en modo paralelo (`set_parallel()`) con una transición `TRANS_SINE` para animaciones suaves.
2.  **Selección de `Curve2D`:** Actualiza la propiedad `curve` del nodo `Hand` (`Path2D`). Si `is_hidden` es `true`, la `curve` se cambia a `curves["hidden"]`; de lo contrario, se usa `curves["normal"]`. Esto permite cambiar completamente la disposición física de las cartas en la mano.
    ```gdscript
    var final_curve := curves["hidden"] if is_hidden else curves["normal"]
    curve = final_curve
    ```
3.  **Ajuste de escala y rotación de cartas:** Itera sobre todas las cartas en la mano (obtenidas a través de `get_cards()`).
    *   **Escala:** Anima la propiedad `scale` de cada `Card` a un `final_scale`. Si `is_hidden` es `true`, la escala se reduce por el factor `HIDE_SCALE`; de lo contrario, se usa la `card_scale` base.
    *   **Rotación:** Anima la propiedad `rotation` de cada `Card`. Si `is_hidden` es `true`, la carta rota `PI / 2` (90 grados); de lo contrario, vuelve a `0.0` grados. Esta rotación es aplicada directamente a la `Card` para un efecto visual distintivo cuando está oculta.
    ```gdscript
    var base_scale := Vector2(card_scale, card_scale)
    var final_scale := base_scale if not is_hidden else base_scale * HIDE_SCALE

    tween.tween_property(card, "scale", final_scale, MOVE_TIME)

    # Rotamos al padre para que los comportamientos se mantengan correctos
    tween.tween_property(card, "rotation", PI / 2 if is_hidden else 0.0, MOVE_TIME)
    ```

### `get_cards() -> Array`
Este método de utilidad devuelve un `Array` de todos los nodos `Card` que están actualmente en la mano. Recorre la jerarquía de los hijos del nodo `Hand`.

La estructura esperada es:
-   `Hand` (nodo actual, `Path2D`)
    -   `PathFollow2D` (contenedor de posición)
        -   `Card` (la carta real)
    -   ... (otros `PathFollow2D` con sus `Card` correspondientes)

El método itera sobre cada `PathFollow2D` (`card_pos`) y obtiene su primer hijo, que se asume es un nodo `Card`, añadiéndolo a la lista `cards` que luego se devuelve.
```gdscript
for card_pos in get_children():
    cards.append(card_pos.get_child(0))
```