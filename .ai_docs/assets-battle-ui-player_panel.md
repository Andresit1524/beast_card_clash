# `PlayerPanel`
El script `PlayerPanel.gd` define una clase `PlayerPanel` que extiende `PanelContainer`, diseñada para gestionar y mostrar la información de un jugador en la interfaz de usuario durante las batallas del juego. Este componente de UI se encarga de representar visualmente el nombre del jugador, su equipo, su barra de vida y la carta elemental que ha puesto en juego, incluyendo animaciones y efectos visuales para una experiencia dinámica.

La clase expone diversas propiedades que permiten configurar los datos del jugador directamente desde el editor de Godot, como el nombre, el equipo, la vida actual, el elemento y valor de la carta, y si la carta debe estar oculta. Estas propiedades, al ser modificadas, desencadenan automáticamente las funciones de actualización del panel, asegurando que la interfaz refleje siempre el estado más reciente del jugador con transiciones animadas.

# Métodos

## Métodos de Godot

### `_ready()`
Este método es parte del ciclo de vida de Godot y se ejecuta una vez que el nodo y todos sus hijos han entrado en el árbol de escenas. Su propósito en `PlayerPanel` es inicializar la visualización del panel asegurando que la información del jugador y la carta se muestren correctamente desde el inicio.

```gdscript
func _ready():
	refresh_panel()
	update_card()
```

- Llama a `refresh_panel()`: Esto carga y muestra el nombre del jugador, su equipo y su vida inicial.
- Llama a `update_card()`: Esto asegura que la carta configurada (o su estado oculto) se visualice correctamente desde el principio, aplicando también su animación de entrada si es la primera vez que se muestra.

## Otros métodos

### `refresh_panel() -> void`
Este método es responsable de actualizar la información general del jugador mostrada en el panel, incluyendo su nombre, equipo y barra de vida. Utiliza un `Tween` para aplicar transiciones suaves a la barra de vida y efectos visuales cuando la vida disminuye.

```gdscript
func refresh_panel() -> void:
	if (not name_label or not team_texture or not card_texture): return
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Actualiza los datos del jugador
	name_label.text = player_name if player_name else "Sin nombre"
	team_texture.texture = teams_list.get_team(team)

	# Actualiza la barra de vida
	var color := "white" if health > 0 else "red"

	# Si la vida bajo, hace un efecto de destello
	if life_bar.value > health:
		modulate = Color.RED
		tween.tween_property(self, "modulate", Color.WHITE, SOME_TIME)

	tween.tween_property(life_bar, "value", health, SOME_TIME)
	life_label.text = "[color=%s]%s[/color]" % [color, health]
```

- **Validación Inicial:** Comprueba si los nodos `@onready` (`name_label`, `team_texture`, `card_texture`) están inicializados. Esto previene errores si el método es llamado antes de que `_ready` haya completado su ejecución o si los nodos no existen por alguna razón.
- **`Tween` para animaciones:** Se crea un `Tween` para gestionar las animaciones de forma suave.
- **Actualización de `player_name`:** El `name_label` se actualiza con el valor de la propiedad `player_name`. Si `player_name` está vacío, se muestra "Sin nombre".
- **Actualización de `team`:** El `team_texture` obtiene su textura del recurso `teams_list` usando el valor de la propiedad `team`. Esto asume que `teams_list` es un recurso que mapea enumeraciones de equipos a sus respectivas texturas.
- **Actualización de la vida:**
    - Se determina un color para el texto de la vida (`life_label`): "white" si la vida es mayor a 0, y "red" si es 0 (o menos, aunque la propiedad `health` está limitada a un rango de 0-5).
    - **Efecto de daño:** Si la vida actual (`life_bar.value`) es mayor que la nueva vida (`health`), indica que el jugador ha recibido daño. En este caso, el panel se modula a rojo (`Color.RED`) brevemente para crear un efecto de "destello" de daño, y luego se tweenea de vuelta a blanco (`Color.WHITE`) utilizando la constante `SOME_TIME` (0.5 segundos).
    - **Animación de la barra de vida:** El valor de la `life_bar` se tweenea a la nueva `health` a lo largo de `SOME_TIME`, proporcionando una transición visual suave.
    - **Actualización del texto de la vida:** El `life_label` (un `RichTextLabel`) se actualiza para mostrar el valor de `health` con el color determinado, permitiendo un formato de texto enriquecido.

Este método se invoca automáticamente cada vez que las propiedades `player_name`, `team` o `health` son modificadas desde el editor o por código, asegurando que el panel se mantenga sincronizado con los datos del jugador.

### `update_card() -> void`
Este método se encarga de la lógica visual para mostrar u ocultar la carta del jugador, incluyendo una pequeña animación de escalado para una transición más dinámica.

```gdscript
func update_card() -> void:
	if not cards_list: return

	# Actualiza el sprite de la carta
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(card_texture, "scale", Vector2(0, base_card_scale.y), 0.1)
	tween.tween_callback(set_card_sprite)
	tween.tween_property(card_texture, "scale", base_card_scale, 0.1)
```

- **Validación Inicial:** Verifica que `cards_list` (el recurso que contiene los sprites de las cartas) esté asignado. Si no lo está, el método se detiene para evitar errores.
- **`Tween` de animación:** Se crea un `Tween` con una transición `TRANS_SINE` para el efecto de escalado.
- **Animación de reducción:** La `card_texture` se escala rápidamente a un ancho de `0` (manteniendo la altura original) en 0.1 segundos. Esto simula que la carta "desaparece" o gira sobre su eje vertical.
- **Cambio de sprite (callback):** Inmediatamente después de la reducción, se añade un `tween_callback` que llama a `set_card_sprite()`. Esto asegura que el sprite de la carta se actualice *mientras* la carta está en su estado reducido (invisible o casi).
- **Animación de expansión:** Finalmente, la `card_texture` se escala de nuevo a su tamaño base (`base_card_scale`) en 0.1 segundos, haciendo que la nueva carta (o la carta oculta) "aparezca" con el mismo efecto.

Este método se invoca automáticamente cuando las propiedades `element`, `value` o `hide_card` son modificadas, proporcionando una actualización visual reactiva de la carta en el panel.

### `set_card_sprite() -> void`
Esta función auxiliar se encarga específicamente de cambiar la textura de la `card_texture` basándose en el elemento, el valor de la carta o si la carta debe estar oculta. Es llamada por `update_card()` durante su animación.

```gdscript
func set_card_sprite() -> void:
	if not cards_list or not card_texture.texture: return
	card_texture.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder
```

- **Validación Inicial:** Comprueba si `cards_list` está asignado y si `card_texture.texture` es válido. La segunda condición, `not card_texture.texture`, parece un error tipográfico y probablemente debería ser `not card_texture` si se buscaba verificar la existencia del nodo, o no es estrictamente necesaria dado que `card_texture` es un `@onready` y debería estar presente.
- **Asignación de textura:**
    - Si `hide_card` es `false`, la textura de la `card_texture` se establece obteniéndola del recurso `cards_list` utilizando los valores de `element` y `value`. Se asume que `cards_list` tiene un método `get_card()` que devuelve la textura correspondiente.
    - Si `hide_card` es `true`, la textura se establece como `cards_list.placeholder`, lo que probablemente es una textura genérica para representar una carta oculta o la parte trasera de una carta.

Este método es un componente clave en la actualización visual de las cartas, permitiendo una clara separación de la lógica entre la animación y el cambio de contenido de la textura.