# `Dice`
Este script define la clase `Dice`, que representa un dado 3D interactivo en el juego. Hereda de `Node3D`, lo que le permite tener una posición, rotación y escala en el espacio 3D. Su función principal es gestionar la visualización del número actual del dado, permitir que el jugador lo "lance" mediante un clic (con una animación de mezcla y lanzamiento), y emitir una señal cuando el lanzamiento ha finalizado, indicando el número resultante.

El dado combina elementos visuales (rotación para mostrar el número correcto, animación de lanzamiento) con interactividad (detección de clics). Está diseñado para ser un componente visual y funcional que notifica a otros sistemas del juego sobre el resultado de un lanzamiento, permitiendo que la lógica del juego maneje las consecuencias del número obtenido.

## Métodos

### Métodos de Godot

### `_ready()`
Este método se ejecuta una vez cuando el nodo y todos sus hijos han entrado en el árbol de escena y están listos para ser usados.
Su propósito es inicializar el estado visual y posicional del dado:
1.  **Establecer rotación inicial:** Ajusta la rotación del dado (`quaternion`) para que muestre el `number` configurado inicialmente en el editor o mediante código. Esto se hace usando el diccionario `ROTATIONS`.
    ```gdscript
    quaternion = ROTATIONS[number]
    ```
2.  **Guardar posición inicial:** Almacena la posición actual del dado en la variable `_start_position`. Esta posición se utiliza más tarde en la animación de lanzamiento para asegurar que el dado regrese a su lugar original.
    ```gdscript
    _start_position = position
    ```

### Otros métodos

### `shuffle_dice()`
`func shuffle_dice() -> void`

Este método es el encargado de iniciar el proceso de "lanzamiento" o "mezcla" visual del dado. Implica una animación que simula un lanzamiento al aire, una serie de rotaciones aleatorias y un eventual "aterrizaje" con un nuevo número.

Los pasos que sigue son:
1.  **Creación de `Tween`:** Inicializa una nueva instancia de `Tween` con una transición `TRANS_QUAD` para controlar las animaciones suaves de propiedades.
    ```gdscript
    var tween := create_tween().set_trans(Tween.TRANS_QUAD)
    ```
2.  **Determinación del nuevo número:** Se genera un número aleatorio entre 1 y 6, que será el resultado final del lanzamiento.
    ```gdscript
    var new_number := randi_range(1, 6)
    ```
3.  **Rotación inicial/pre-lanzamiento:** Se llama a `rotate_dice()` para iniciar una rotación visual del dado.
    ```gdscript
    rotate_dice(ROTATIONS[new_number - 1])
    ```
    > [!WARNING]
    > Existe un potencial problema de `Index Out Of Bounds` en esta línea: `ROTATIONS[new_number - 1]`. Si `new_number` es 1, `new_number - 1` sería 0. El diccionario `ROTATIONS` está inicializado con claves de 1 a 6. Acceder a `ROTATIONS[0]` resultaría en un error. Se recomienda revisar si la intención era usar `ROTATIONS[new_number]` o si el índice 0 se manejaría de alguna otra manera (por ejemplo, si el rango de `randi_range` fuera 0-5 y `ROTATIONS` también).

4.  **Animación de elevación:** El dado se eleva a la `THROW_HEIGHT` (8 unidades hacia arriba) durante la primera mitad de `ROTATION_TIME` con una curva de ease-out. Durante esta fase, el dado se hace no clicable para evitar interacciones duplicadas.
    ```gdscript
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "position", Vector3.UP * THROW_HEIGHT, ROTATION_TIME / 2.0)
    clickable = false
    ```
5.  **Animación de descenso:** El dado regresa a su posición original (`_start_position`) durante la segunda mitad de `ROTATION_TIME` con una curva de ease-in.
    ```gdscript
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position", _start_position, ROTATION_TIME / 2.0)
    ```
6.  **Acciones al finalizar la animación:** Una vez que la animación de descenso termina, se ejecuta una función de `callback`:
    *   Se emite la señal `thrown_dice` con el `new_number` resultante, notificando a otros componentes del juego sobre el resultado del lanzamiento.
    *   Se vuelve a habilitar la capacidad de hacer clic en el dado.
    ```gdscript
    tween.tween_callback(func():
        thrown_dice.emit(new_number)
        clickable = true
    )
    ```

### `rotate_dice(target_rotation: Quaternion)`
`func rotate_dice(target_rotation: Quaternion)`

Este método se encarga de animar la rotación visual del dado, simulando un "giro" o "mezcla" antes de asentarse en una rotación final.

Los pasos que sigue son:
1.  **Creación de `Tween`:** Se crea un nuevo `Tween` para gestionar la secuencia de rotaciones.
    ```gdscript
    var tween := create_tween()
    ```
2.  **Rotaciones aleatorias (Tumbling):** El dado realiza una serie de pequeñas rotaciones aleatorias. Esto se repite un número de veces calculado como `ROTATION_TIME / TWIST_TIME`. Cada rotación es hacia una cara aleatoria del dado y dura `TWIST_TIME`. Este efecto visual contribuye a la sensación de un dado que está "rodando" o "mezclándose".
    ```gdscript
    for i in range(ROTATION_TIME / TWIST_TIME):
        tween.tween_property(self, "quaternion", ROTATIONS[randi() % 6 + 1], TWIST_TIME)
    ```
3.  **Rotación final:** Después de las rotaciones aleatorias, el dado gira suavemente hacia la `target_rotation` especificada, también con una duración de `TWIST_TIME`. Esta es la rotación que visualmente muestra el número deseado hacia arriba.
    ```gdscript
    tween.tween_property(self, "quaternion", target_rotation, TWIST_TIME)
    ```

## Funciones asociadas a señales

#### `_on_static_body_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int)`
Este método es una función de *callback* que se ejecuta cuando el nodo `StaticBody3D` (llamado `hitbox`) detecta un evento de entrada. Está conectado a la señal `input_event` del `StaticBody3D`.

Su funcionalidad es la siguiente:
1.  **Filtrado de eventos:** Verifica si el evento de entrada es un clic del botón izquierdo del ratón (`MOUSE_BUTTON_LEFT`). Si el evento no cumple con estas condiciones (por ejemplo, es un movimiento del ratón, un clic derecho, o un evento de teclado), la función termina sin hacer nada.
    ```gdscript
    if not (
        event is InputEventMouseButton
        and event.is_pressed()
        and event.button_index == MOUSE_BUTTON_LEFT
    ): return
    ```
2.  **Lanzar el dado:** Si se detecta un clic del botón izquierdo del ratón, se llama al método `shuffle_dice()` para iniciar la animación de lanzamiento del dado.
    ```gdscript
    shuffle_dice()
    ```