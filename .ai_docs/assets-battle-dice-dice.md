# `Dice`
Este script, que extiende `Node3D`, representa un dado 3D interactivo en el juego. Su función principal es gestionar la visualización del dado, permitir que los jugadores lo "lancen" mediante un clic y determinar el resultado de ese lanzamiento. Incorpora animaciones para simular el tiro del dado y una lógica para orientar el dado a un número específico, además de proporcionar retroalimentación visual sobre su estado interactivo. Está diseñado para ser un componente autocontenido para la funcionalidad de un dado en una escena 3D.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se llama una vez cuando el nodo `Dice` y todos sus hijos entran en el árbol de la escena.
Es responsable de la inicialización del estado visual y funcional del dado:

*   **Orientación Inicial**: Ajusta la orientación inicial del dado (`quaternion`) para que muestre el valor de la propiedad `number` exportada. Esto se logra consultando el diccionario `ROTATIONS`.
    ```gdscript
    quaternion = ROTATIONS[number]
    ```
*   **Posición de Inicio**: Almacena la `position` actual del dado en la variable privada `_start_position`. Esta posición se usa más tarde en el método `throw_dice()` como el punto de aterrizaje después de un lanzamiento.
    ```gdscript
    _start_position = position
    ```
*   **Conexión de Señal**: Conecta la señal `input_event` del nodo `static_body` (un `StaticBody3D` usado como hitbox) al método `_on_static_body_input_event`. Esta conexión permite al dado detectar clics del ratón.
    ```gdscript
    static_body.input_event.connect(_on_static_body_input_event)
    ```
*   **Clickability Inicial**: Establece la propiedad `input_ray_pickable` del `static_body` según el valor inicial de la propiedad `clickable` del dado. Esto controla si el dado puede ser detectado por rayos de entrada desde el principio.
    ```gdscript
    static_body.input_ray_pickable = clickable
    ```

## Otros métodos

### `_enable_dice(is_enabled: bool)`
Este método controla el estado interactivo y la retroalimentación visual del dado, haciéndolo clicable o no clicable y modificando su apariencia en consecuencia.

*   **Parámetros**:
    *   `is_enabled`: Un booleano que indica si el dado debe estar habilitado (clicable y con contorno) o deshabilitado.

*   **Funcionamiento**:
    1.  **Interactividad**: Modifica la propiedad `input_ray_pickable` del nodo `static_body`. Si `is_enabled` es `true`, el dado puede ser detectado por rayos de entrada (y por lo tanto clicado); si es `false`, no lo será.
        ```gdscript
        static_body.input_ray_pickable = is_enabled
        ```
    2.  **Retroalimentación Visual**: Ajusta los parámetros del *shader* de la malla `cube` para cambiar su apariencia:
        *   `thickness`: Establece el grosor del contorno. Si el dado está habilitado, el grosor será `OUTLINE_THICKNESS`; de lo contrario, será `0.0` (sin contorno).
        *   `color`: Establece el color del contorno y/o del propio dado (dependiendo del *shader*). Si el dado está habilitado, se usa `Color.CYAN` con una `COLOR_OPACITY`; si está deshabilitado, se usa `Color.TRANSPARENT`.
        ```gdscript
        cube.set_instance_shader_parameter("thickness", OUTLINE_THICKNESS if is_enabled else 0.0)
        cube.set_instance_shader_parameter("color", Color(Color.CYAN, COLOR_OPACITY) if is_enabled else Color.TRANSPARENT)
        ```

*   **Uso**: Es llamado principalmente por el *setter* de la propiedad `clickable` para actualizar el estado del dado.

### `throw_dice()`
Este método simula el lanzamiento del dado, incluyendo la animación de ascenso y descenso, la determinación de un nuevo número aleatorio y la emisión de una señal cuando el dado aterriza.

*   **Funcionamiento**:
    1.  **Tween**: Crea un objeto `Tween` configurado con una transición `Tween.TRANS_QUAD` para animaciones suaves.
    2.  **Número Aleatorio**: Genera un nuevo número aleatorio entre 1 y 6 para el resultado del dado.
        ```gdscript
        var new_number := randi_range(1, 6)
        ```
    3.  **Rotación Interna**: Llama a `_rotate_dice(ROTATIONS[new_number])` para iniciar la rotación del dado hacia su nueva cara.
    4.  **Animación de Ascenso**: El dado se mueve hacia arriba (hasta `Vector3.UP * THROW_HEIGHT`) usando el `Tween` con una atenuación `Tween.EASE_OUT`. Durante esta fase, la propiedad `clickable` se establece en `false` para evitar clics adicionales mientras el dado está en movimiento.
        ```gdscript
        tween.set_ease(Tween.EASE_OUT)
        tween.tween_property(self, "position", Vector3.UP * THROW_HEIGHT, ROTATION_TIME / 2.0)
        clickable = false
        ```
    5.  **Animación de Descenso**: Después del ascenso, el dado regresa a su `_start_position` (su posición inicial) con una atenuación `Tween.EASE_IN`.
        ```gdscript
        tween.set_ease(Tween.EASE_IN)
        tween.tween_property(self, "position", _start_position, ROTATION_TIME / 2.0)
        ```
    6.  **Callback Final**: Una vez completada la animación de descenso, se ejecuta un *callback*:
        *   Imprime el número lanzado en la consola para depuración.
        *   Emite la señal `thrown_dice` con el `new_number` como argumento, notificando a otros componentes que el dado ha sido lanzado y cuál es su resultado.
        ```gdscript
        tween.tween_callback(func():
            print("[Dice] Dado lanzado: %s" % new_number)
            thrown_dice.emit(new_number)
        )
        ```

*   **Interacción**: Este método es el punto central para la mecánica de lanzamiento del dado, y es llamado en respuesta a la interacción del jugador o a la lógica del juego.

### `_rotate_dice(target_rotation: Quaternion)`
Este método gestiona la animación de rotación del dado, incluyendo una serie de "giros" intermedios para simular un movimiento dinámico antes de asentarse en la rotación final.

*   **Parámetros**:
    *   `target_rotation`: Un `Quaternion` que representa la orientación final deseada para el dado (correspondiente a una de las caras).

*   **Funcionamiento**:
    1.  **Tween**: Crea un objeto `Tween` para orquestar las animaciones de rotación.
    2.  **Giros Intermedios**: El dado realiza una serie de rotaciones rápidas y aleatorias. Esto se logra mediante un bucle que dura `ROTATION_TIME / TWIST_TIME` iteraciones. En cada iteración, el `quaternion` del dado se *tweens* a una rotación aleatoria de `ROTATIONS` durante un `TWIST_TIME` muy corto. Este efecto crea la ilusión de que el dado está "girando" antes de detenerse.
        ```gdscript
        for i in range(ROTATION_TIME / TWIST_TIME):
            tween.tween_property(self, "quaternion", ROTATIONS[randi() % 6 + 1], TWIST_TIME)
        ```
        > [!NOTE] Explicación de `ROTATIONS`
        > La variable `ROTATIONS` es un diccionario `onready` que mapea cada número de cara del dado (del 1 al 6) a su `Quaternion` correspondiente, lo que permite orientar el `Node3D` para que esa cara quede mirando hacia arriba.
        > ```gdscript
        > @onready var ROTATIONS := {
        > 	1: Basis(Vector3.DOWN, Vector3.RIGHT, Vector3.BACK).get_rotation_quaternion(),
        > 	2: Quaternion.IDENTITY,
        > 	3: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN).get_rotation_quaternion(),
        > 	4: Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP).get_rotation_quaternion(),
        > 	5: Basis(Vector3.RIGHT, Vector3.DOWN, Vector3.FORWARD).get_rotation_quaternion(),
        > 	6: Basis(Vector3.UP, Vector3.LEFT, Vector3.BACK).get_rotation_quaternion(),
        > }
        > ```
    3.  **Rotación Final**: Después de los giros intermedios, el `Tween` anima el `quaternion` del dado a la `target_rotation` final, también durante `TWIST_TIME`. Esto asegura que el dado se asiente limpiamente en la cara deseada.
        ```gdscript
        tween.tween_property(self, "quaternion", target_rotation, TWIST_TIME)
        ```

*   **Uso**: Es llamado tanto por el *setter* de la propiedad `number` (para cambiar el número del dado y su rotación directamente) como por el método `throw_dice()` (para animar el dado a su resultado después de un lanzamiento).

## Funciones asociadas a señales

#### `_on_static_body_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int)`
Este método es el *callback* asociado a la señal `input_event` del nodo `static_body`. Su propósito es detectar si el jugador ha hecho clic en el dado con el botón izquierdo del ratón.

*   **Señal**: `static_body.input_event`
*   **Funcionamiento**:
    1.  **Filtrado de Eventos**: El método primero verifica si el evento de entrada (`event`) cumple con las siguientes condiciones:
        *   Es una instancia de `InputEventMouseButton`.
        *   El botón del ratón ha sido presionado (`event.is_pressed()`).
        *   El botón presionado es el botón izquierdo del ratón (`event.button_index == MOUSE_BUTTON_LEFT`).
        ```gdscript
        if not (
            event is InputEventMouseButton
            and event.is_pressed()
            and event.button_index == MOUSE_BUTTON_LEFT
        ): return
        ```
    2.  **Lanzar el Dado**: Si todas las condiciones se cumplen (es decir, el dado ha sido clicado con el botón izquierdo del ratón), se llama al método `throw_dice()`, iniciando el proceso de lanzamiento del dado.
        ```gdscript
        throw_dice()
        ```
*   **Interacción**: Este método es la interfaz principal a través de la cual el jugador interactúa directamente con el dado para activarlo.