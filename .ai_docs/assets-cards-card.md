```Markdown
# `CardScene`
Este script de Godot define el comportamiento visual e interactivo de una carta coleccionable en el juego **Beast Card Clash**. Extiende `TextureButton` para proporcionar una base interactiva, y su principal responsabilidad es gestionar la representación gráfica y el estado de una carta.

La `CardScene` permite configurar y mostrar una carta con las siguientes propiedades exportadas:
-   `element`: Define el tipo elemental de la carta, utilizando los valores de `GameConstants.Elements`. Su `setter` invoca a `_update_sprite()` para reflejar el cambio visual.
-   `value`: Representa el valor numérico de la carta, dentro del rango `1` a `GameConstants.MAX_CARD_VALUE`. Su `setter` también invoca a `_update_sprite()` para actualizar el sprite de la carta.
-   `hide_card`: Un booleano que controla si la carta debe mostrarse boca arriba o boca abajo (como un reverso genérico). Su `setter` detecta cambios de valor e invoca a la animación `_flip_card()` para el cambio visual.
-   `disable_card`: Un booleano que, cuando es `true`, desactiva la interactividad de la carta y la oscurece visualmente. Su `setter` invoca a `_update_sprite()` para aplicar los cambios visuales.
-   `cards_list`: Un recurso de tipo `CardsList` que debe contener las texturas disponibles para todas las combinaciones de elementos y valores de cartas, así como el reverso genérico (`placeholder`). Este recurso es esencial para que la carta pueda cargar sus sprites.

Además de la gestión visual a través de la propiedad `texture_normal` heredada de `TextureButton`, el script implementa varias animaciones para mejorar la experiencia del jugador y proporcionar retroalimentación visual:
-   Un efecto de "ondulación" sutil y continuo, gestionado por `_physics_process`, que hace que la carta se mueva ligeramente de arriba abajo, añadiendo dinamismo.
-   Animaciones de "hover" (`_hover_card()`) cuando el cursor del ratón entra o sale del área de la carta, que implican cambios de color (`modulate`), tamaño y posición, destacando la carta interactiva.
-   Una animación de "volteo" (`_flip_card()`) que simula que la carta gira sobre su eje Y, utilizada para ocultar o revelar su cara.

La `CardScene` emite la señal `card_selected(card: Card)` cuando es presionada, proporcionando una versión abstracta de la carta (`Card` de la clase interna) para que la lógica del juego pueda reaccionar sin acoplarse a la representación visual. También incluye la clase interna `Card`, una estructura de datos ligera y autocontenida para encapsular el elemento y valor de una carta, facilitando la interacción con otros sistemas del juego.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se llama una vez que el nodo `CardScene` entra en el árbol de la escena.
Sus funciones principales son:
-   **Centrar el pivote:** Establece `pivot_offset` al centro de la `size` actual de la carta. Esto es crucial para que las transformaciones (como la escala en `_flip_card` o el tamaño en `_hover_card`) se realicen desde el centro del botón y no desde su esquina superior izquierda.
-   **Actualizar sprite inicial:** Llama a `_update_sprite()` para asegurar que la carta muestre su textura y color y configuración correctos desde el momento en que aparece en pantalla, basándose en sus propiedades iniciales.

```gdscript
func _ready() -> void:
	# Centra el pivote
	pivot_offset = size / 2
	_update_sprite()
```

### `_physics_process(delta: float)`
Este método es invocado en cada paso del motor físico, utilizando un `delta` que representa el tiempo transcurrido desde la última actualización. Su propósito es implementar el efecto visual de "ondulación" para la carta.
-   **Actualización del tiempo:** Incrementa `elapsed_time` con el valor de `delta`. `elapsed_time` se inicializa con un valor aleatorio (`randf() * TAU`) para asegurar que las ondulatorias de múltiples cartas no estén perfectamente sincronizadas.
-   **Actualización de posición:** Calcula un desplazamiento vertical utilizando `_get_ondulation_offset()` y lo añade a la `_start_position` (la posición inicial de la carta). Esto hace que la carta se mueva suavemente hacia arriba y abajo.
Este proceso es temporalmente desactivado en `_hover_card` para evitar conflictos durante la animación de "hover".

```gdscript
func _physics_process(delta: float) -> void:
	# Actualiza el tiempo y posición de la carta
	elapsed_time += delta
	position = _start_position + _get_ondulation_offset()
```

## Otros métodos

### `set_properties(values: Dictionary)`
Este método proporciona una forma conveniente de establecer múltiples propiedades de la carta simultáneamente.
-   **Asignación por diccionario:** Recorre un `Dictionary` llamado `values`. Cada clave en el diccionario se espera que sea el nombre de una propiedad de la `CardScene` (por ejemplo, "element", "value", "hide_card").
-   **Validación:** Verifica si la propiedad existe en la instancia de la clase. Si no se encuentra, se imprime un `push_error` en la consola de Godot para facilitar la depuración.
-   **Actualización visual:** Después de intentar establecer todas las propiedades, se llama a `_update_sprite()` para asegurar que la carta actualice su representación visual de acuerdo con los nuevos valores.

```gdscript
func set_properties(values: Dictionary) -> void:
	for property in values:
		var new_value = values[property]

		if not property in self:
			push_error("Propiedad no encontrada: %s" % property)
			continue

		set(property, new_value)

	_update_sprite()
```

### `_update_sprite()`
Un método privado crucial para la gestión visual de la carta. Se encarga de determinar qué textura mostrar y qué coloración aplicar.
-   **Pre-verificación:** Retorna tempranamente si el recurso `cards_list` no está asignado, ya que no se podrían cargar las texturas.
-   **Modulación por estado:** Modifica el color `modulate` de la carta. Si `disable_card` es `true`, la carta se oscurece (`Color.DIM_GRAY`). De lo contrario, se muestra en su color original (`Color.WHITE`).
-   **Carta oculta:** Si `hide_card` es `true`, establece `texture_normal` al `placeholder` (reverso de la carta) definido en `cards_list`.
-   **Carta visible:** Si la carta no está oculta, obtiene la textura correcta de `cards_list` utilizando el `element` y `value` actuales de la carta.
Este método es invocado por los `setter` de las propiedades `element`, `value`, `disable_card`, `hide_card` (indirectamente a través de `_flip_card`), así como en `_ready()` y `set_properties()`.

### `_hover_card(hover: bool)`
Gestiona la animación de "hover" cuando el cursor del ratón entra o sale del área de la carta.
-   **Pre-verificación:** Si la carta está `disable_card`, el efecto de hover no se aplica y el método retorna.
-   **Tweening:** Crea un `Tween` en paralelo con una transición `Tween.TRANS_SINE` para animar suavemente las propiedades. La duración de la animación está controlada por la constante `HOVER_TIME` (0.2 segundos).
-   **Efecto de entrada (hover = true):**
    -   La carta se atenúa a `Color.GRAY`.
    -   Su `size` aumenta verticalmente (su altura se multiplica por 1.5).
    -   Si la carta no está oculta (`hide_card`), se desactiva `_physics_process` y la carta se mueve ligeramente hacia arriba desde su `_start_position`.
-   **Efecto de salida (hover = false):**
    -   La carta vuelve a `Color.WHITE`.
    -   Su `size` se restablece a `_start_size`.
    -   Si la carta no está oculta, su `position` se restablece a `_start_position`. Se utiliza un `tween_callback` para re-activar `_physics_process` una vez que la animación ha terminado, evitando saltos visuales.

### `_flip_card()`
Este método anima el efecto de "volteo" de la carta, que se utiliza para cambiar entre la cara visible y el reverso.
-   **Pre-verificación:** Retorna si `_start_scale` no está inicializada, evitando errores.
-   **Tweening:** Crea un `Tween` no paralelo con una transición `Tween.TRANS_SINE`. La duración de cada fase del volteo está definida por `ROTATION_TIME` (0.15 segundos).
-   **Animación de volteo:**
    1.  La propiedad `scale.x` se anima de su valor actual a `0`, haciendo que la carta se "estreche" hasta desaparecer en el eje X.
    2.  Cuando `scale.x` llega a `0`, se invoca a `_update_sprite()` a través de un `tween_callback`. En este punto, `_update_sprite()` leerá la propiedad `hide_card` (cuyo setter ha disparado este método) y cambiará la textura de la carta (cara a reverso o viceversa).
    3.  La propiedad `scale.x` se anima de `0` de vuelta a su `current_scale.x` original, haciendo que la carta "vuelva a crecer" y revele la nueva textura.
Este proceso simula una rotación fluida alrededor del eje Y de la carta.

```gdscript
func _flip_card() -> void:
	if not _start_scale: return

	# Este tween no debe ser paralelo
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var current_scale = scale

	tween.tween_property(self, "scale", Vector2(0, scale.y), ROTATION_TIME)
	tween.tween_callback(_update_sprite)
	tween.tween_property(self, "scale", current_scale, ROTATION_TIME)
```

### `_get_ondulation_offset() -> Vector2`
Una función auxiliar privada que calcula el vector de desplazamiento vertical para la animación de ondulación.
-   Utiliza la función seno (`sin`) aplicada a `elapsed_time` multiplicado por `ONDULAION_SPEED` (3.5).
-   El resultado de `sin` (que oscila entre -1 y 1) se multiplica por `ONDULAION_STRENGHT` (2) para determinar la amplitud del movimiento.
-   Devuelve un `Vector2` donde el componente X es `0` (solo hay movimiento vertical) y el componente Y es el desplazamiento calculado, creando un movimiento de onda suave.

### `get_abstract_card() -> Card`
Este método crea y devuelve una nueva instancia de la clase interna `Card`.
-   **Encapsulación de datos:** Recopila el `element` y `value` actuales de la `CardScene`.
-   **Abstracción:** Pasa estos datos al constructor de la clase `Card`, devolviendo un objeto que contiene solo la información esencial de la carta, sin la sobrecarga de la representación visual o interactiva del nodo `CardScene`. Esto es útil para pasar datos de la carta a la lógica del juego o a otros componentes que no necesitan interactuar directamente con el nodo visual.

### `Card` (Clase interna)
La clase interna `Card` actúa como una estructura de datos abstracta y ligera para representar la información esencial de una carta: su elemento y su valor. No tiene representación visual ni lógica de interactividad, sirviendo únicamente como un objeto de datos para la lógica del juego.

#### `_init(new_element: GameConstants.Elements, new_value: int)`
El constructor de la clase `Card`. Se utiliza para inicializar una nueva instancia de `Card` con un elemento y un valor específicos.
-   `new_element`: Asigna el tipo elemental de la carta.
-   `new_value`: Asigna el valor numérico de la carta. El `setter` de la propiedad `value` se activará durante esta asignación, realizando la validación del rango.

#### `value`
Esta propiedad almacena el valor numérico de la carta. Incluye un `setter` personalizado que valida el valor de entrada (`v`):
-   Si el `v` valor es menor que `0` o mayor que `10`, el valor de la carta se fuerza a `0`.
-   En cualquier otro caso, `value` se establece al `v` proporcionado.
Esto asegura que el valor numérico de una `Card` abstracta siempre se mantenga dentro de un rango esperado por el juego.

## Funciones asociadas a señales

### `_on_pressed() -> void`
Este método es la función callback para la señal `pressed` del nodo `TextureButton`. Se ejecuta cuando el usuario hace clic o presiona la carta.
-   **Condiciones de interacción:** Primero, verifica si la carta está `disable_card` o `hide_card`. Si alguna de estas condiciones es `true`, el método retorna inmediatamente, impidiendo que la carta sea interactuable cuando no debe serlo.
-   **Depuración:** Imprime un mensaje de depuración que indica qué carta (elemento y valor) fue presionada.
-   **Emisión de señal:** Emite la señal `card_selected`, pasando como argumento una nueva instancia de la clase `Card` (obtenida mediante `get_abstract_card()`) que representa los datos esenciales de la carta. Esto permite que otros nodos en el juego reaccionen a la selección de la carta.

```gdscript
func _on_pressed() -> void:
	if disable_card or hide_card: return

	print_debug("Carta %s-%s presionada" % [element, value])
	card_selected.emit(get_abstract_card())
```

### `_on_mouse_entered() -> void`
Esta función es la función callback para la señal `mouse_entered` heredada de `Control`. Se dispara cuando el cursor del ratón entra en el área interactiva de la carta.
-   **Activación de hover:** Llama al método privado `_hover_card(true)` para iniciar la animación visual de "hover", que resalta la carta.

### `_on_mouse_exited() -> void`
Esta función es la función callback para la señal `mouse_exited` heredada de `Control`. Se dispara cuando el cursor del ratón sale del área interactiva de la carta.
-   **Desactivación de hover:** Llama al método privado `_hover_card(false)` para revertir la animación visual de "hover", devolviendo la carta a su estado normal.
```