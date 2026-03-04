# `dice`
Este script `dice.gd` extiende `Node3D` y gestiona el comportamiento visual y la interacción de un dado en el entorno 3D del juego. Su función principal es simular el lanzamiento de un dado, incluyendo animaciones de rotación y elevación, y reflejar el resultado numérico en su cara superior. Esto permite integrar una mecánica de aleatoriedad interactiva, fundamental para la toma de decisiones o la resolución de eventos durante las partidas de **Beast Card Clash**.

El dado puede ser inicializado con un número específico, que se muestra inmediatamente. Cuando el dado es "mezclado" o "lanzado", realiza una secuencia de rotaciones aleatorias rápidas mientras se eleva y desciende, para finalmente detenerse mostrando un número aleatorio de 1 a 6.

La configuración de rotaciones se maneja mediante un diccionario de cuaterniones, `ROTATIONS`, que mapea cada número del dado a una orientación 3D específica para que ese número quede en la cara superior. La interacción se activa mediante eventos de ratón, permitiendo a los jugadores hacer clic en el dado para activarlo.

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez que el nodo y todos sus hijos están en el árbol de escenas. Su principal responsabilidad es la inicialización del estado del dado:

1.  **Rotación inicial:** Si la variable `number` (el número que debe mostrar el dado) está definida en el diccionario `ROTATIONS`, el dado se orienta inmediatamente a la rotación correspondiente. Esto asegura que el dado muestre el número correcto al inicio del juego o escena.
    ```gdscript
    if number in ROTATIONS: quaternion = ROTATIONS[number]
    ```
2.  **Guardar posición inicial:** La posición actual del dado en el mundo 3D se guarda en la variable `_start_position`. Esta posición es crucial para asegurar que el dado regrese a su lugar original después de la animación de "lanzamiento".
    ```gdscript
    _start_position = position
    ```

## Otros métodos

### `shuffle_dice()`
Este método orquesta la animación completa de "lanzar" o "mezclar" el dado. Simula el acto de lanzar un dado al aire y dejarlo caer, mostrando un nuevo número aleatorio:

1.  **Creación de Tween:** Se inicializa un `Tween` con una transición `TRANS_QUAD` y `EASE_OUT` para las animaciones de movimiento, lo que proporciona un efecto de aceleración y desaceleración suave.
    ```gdscript
    var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    ```
2.  **Rotación aleatoria:** Antes de la animación de movimiento, se llama a `set_dice_rotation()` para iniciar la secuencia de rotaciones que terminará mostrando un número aleatorio (generado con `randi() % 6 + 1`).
    ```gdscript
    set_dice_rotation(ROTATIONS[randi() % 6 + 1])
    ```
3.  **Animación de elevación:** El dado se mueve verticalmente hacia arriba hasta la altura definida por `THROW_HEIGHT`. Esta animación dura la primera mitad de `ROTATION_TOTAL_TIME`.
    ```gdscript
    tween.tween_property(self , "position", Vector3.UP * THROW_HEIGHT, ROTATION_TOTAL_TIME / 2.0)
    ```
4.  **Animación de descenso:** Después de alcanzar la altura máxima, la animación de descenso se configura con `Tween.EASE_IN` para simular la gravedad. El dado regresa a su `_start_position` original, tomando la segunda mitad de `ROTATION_TOTAL_TIME`.
    ```gdscript
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self , "position", _start_position, ROTATION_TOTAL_TIME / 2.0)
    ```
Esta combinación de movimientos y transiciones busca dar una sensación realista y satisfactoria al jugador al interactuar con el dado.

### `set_dice_rotation(target_rotation: Quaternion)`
Este método es responsable de la parte visual de la rotación del dado, simulando un "rodar" o "tumbar" antes de mostrar el número final.

1.  **Creación de Tween:** Se crea un nuevo `Tween` para manejar las rotaciones.
    ```gdscript
    var tween := create_tween()
    ```
2.  **Rotaciones intermedias:** Se ejecuta un bucle que realiza múltiples rotaciones aleatorias rápidas. Esto crea el efecto de que el dado está girando de forma incontrolada antes de detenerse. Cada rotación intermedia dura `ROTATION_TIME`. La cantidad de rotaciones está determinada por `ROTATION_TOTAL_TIME / ROTATION_TIME`.
    ```gdscript
    for i in range(ROTATION_TOTAL_TIME / ROTATION_TIME):
        tween.tween_property(self , "quaternion", ROTATIONS[randi() % 6 + 1], ROTATION_TIME)
    ```
3.  **Rotación final:** Una vez completadas las rotaciones aleatorias, el dado se rota suavemente hacia la `target_rotation` especificada, que es la orientación que muestra el número deseado en la cara superior. Esta rotación final también dura `ROTATION_TIME`.
    ```gdscript
    tween.tween_property(self , "quaternion", target_rotation, ROTATION_TIME)
    ```
El diccionario `ROTATIONS` es crucial para este método, ya que define las orientaciones exactas para cada número del dado:
```gdscript
@onready var ROTATIONS := {
	1: Basis(Vector3.DOWN, Vector3.RIGHT, Vector3.BACK).get_rotation_quaternion(),
	2: Quaternion.IDENTITY,
	3: Basis(Vector3.RIGHT, Vector3.BACK, Vector3.DOWN).get_rotation_quaternion(),
	4: Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP).get_rotation_quaternion(),
	5: Basis(Vector3.RIGHT, Vector3.DOWN, Vector3.FORWARD).get_rotation_quaternion(),
	6: Basis(Vector3.UP, Vector3.LEFT, Vector3.BACK).get_rotation_quaternion(),
}
```
Cada entrada asegura que, al aplicar la rotación correspondiente, la cara del dado con ese número quede hacia arriba.

## Funciones asociadas a señales

### `_on_static_body_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int)`
Este método es un *callback* conectado a la señal `input_event` de un nodo `StaticBody` (o un nodo similar que emita eventos de entrada 3D) que se espera que sea un componente hijo o hermano que represente la geometría colisionable del dado.

-   **Señal a la que apunta:** `input_event` de un `StaticBody` (u otro `CollisionObject3D`).
-   **Funcionamiento:**
    1.  **Filtrado de eventos:** La función primero verifica si el evento de entrada es un clic con el botón izquierdo del ratón (`MOUSE_BUTTON_LEFT`). Si el evento no cumple estas condiciones, la función retorna inmediatamente sin realizar ninguna acción.
        ```gdscript
        if not (
            event is InputEventMouseButton
            and event.is_pressed()
            and event.button_index == MOUSE_BUTTON_LEFT
        ): return
        ```
    2.  **Lanzar el dado:** Si se detecta un clic izquierdo del ratón sobre el `StaticBody` asociado, se llama al método `shuffle_dice()`. Esto inicia la animación completa del lanzamiento del dado, incluyendo la rotación y el movimiento vertical.

Esta implementación permite que el dado sea interactivo en el juego, respondiendo directamente a la entrada del jugador para iniciar el proceso de "lanzamiento".