# `PlayerCardPanel`
Este script, que extiende `PanelContainer`, es un componente de interfaz de usuario diseñado para mostrar dinámicamente la información de un jugador y la carta que tiene en juego dentro de "Beast Card Clash". Actúa como un visualizador modular que se actualiza automáticamente cada vez que sus propiedades principales son modificadas.

Su funcionalidad principal reside en recibir datos a través de sus propiedades `@export` (como el nombre del jugador, equipo, elemento y valor de la carta) y utilizar recursos externos (`CardsList` y `TeamsList`) para renderizar las texturas correspondientes en la interfaz. También incluye la capacidad de ocultar la carta, mostrando un *placeholder* en su lugar.

Este panel se integra con el resto del proyecto al consumir los enums `GameConstants.Teams` y `GameConstants.Elements` para asegurar la consistencia de los datos del juego, y al depender de recursos tipo `Resource` (`CardsList` y `TeamsList`) para la gestión de las *sprites* de cartas y equipos, permitiendo una fácil expansión y mantenimiento de los activos visuales.

# Métodos

## Métodos de Godot

### `_ready()`
Este método es parte del ciclo de vida de los nodos en Godot y se llama una vez que el nodo `PlayerCardPanel` y todos sus hijos han sido inicializados y han entrado en el árbol de escenas. Su propósito principal en este script es asegurar que el panel se inicialice correctamente con los valores de sus propiedades de exportación en el momento en que se carga la escena.

```gdscript
func _ready():
	refresh_panel()
```

Al llamar a `refresh_panel()` en este punto, se garantiza que la interfaz de usuario se renderice con los datos actuales del jugador y la carta desde el primer momento en que el panel es visible.

## Otros métodos

### `refresh_panel() -> void`
Este es el método central del script, encargado de actualizar todos los elementos visuales del panel (`name_label`, `team_texture`, `card_texture`) basándose en los valores actuales de las propiedades `@export` del nodo.

```gdscript
func refresh_panel() -> void:
	if (not name_label or not team_texture or not card_texture): return

	name_label.text = player_name if player_name else "Sin nombre"
	team_texture.texture = teams_list.get_team(team)
	card_texture.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder
```

El funcionamiento detallado es el siguiente:
1.  **Verificación de Nodos:** Al inicio, el método verifica si las referencias a los nodos hijos (`name_label`, `team_texture`, `card_texture`) ya están disponibles. Esto es una medida de seguridad para evitar errores `null` si el método se llama antes de que `@onready` haya terminado de inicializar las variables (aunque en la práctica, las llamadas desde los `setters` y `_ready` deberían garantizar que ya estén listos).
    ```gdscript
    if (not name_label or not team_texture or not card_texture): return
    ```
2.  **Actualización del Nombre del Jugador:** Establece el texto del `name_label` utilizando el valor de la propiedad `player_name`. Si `player_name` está vacío (o es `null`), se mostrará el texto "Sin nombre" por defecto.
    ```gdscript
    name_label.text = player_name if player_name else "Sin nombre"
    ```
    > [!NOTE]
    > La lógica `player_name if player_name else "Sin nombre"` garantiza que siempre haya un texto visible en el panel, incluso si no se ha asignado un nombre al jugador.

3.  **Actualización de la Textura del Equipo:** Asigna la textura correspondiente al `team_texture` utilizando el recurso `teams_list`. Este recurso tiene un método `get_team()` que, dado un enum `GameConstants.Teams`, devuelve la `Texture2D` asociada.
    ```gdscript
    team_texture.texture = teams_list.get_team(team)
    ```
4.  **Actualización de la Textura de la Carta:** Determina qué textura mostrar para la carta.
    *   Si la propiedad `hide_card` es `true`, se utiliza la textura `placeholder` del recurso `cards_list`, lo que simula una carta oculta o "boca abajo".
    *   Si `hide_card` es `false`, se recupera la textura de la carta real llamando al método `get_card()` de `cards_list`, pasando el `element` (un enum de `GameConstants.Elements`) y el `value` de la carta.
    ```gdscript
    card_texture.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder
    ```

Este método es invocado automáticamente cada vez que una de las propiedades `@export` siguientes (`player_name`, `team`, `element`, `value`, `hide_card`) es modificada, lo que asegura que el panel refleje siempre el estado más reciente del jugador y la carta sin necesidad de llamadas manuales desde otros scripts.