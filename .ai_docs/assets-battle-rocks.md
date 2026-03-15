# `rock_spawner`
Este script, adjunto a un nodo `Node3D`, tiene como función principal la generación y gestión dinámica de instancias de una escena de roca (`rock_scene`) en un entorno 3D. Actúa como un gestor de elementos ambientales que posiciona múltiples rocas en un patrón circular alrededor de la posición del nodo al que está adjunto. Su configuración se realiza completamente a través de variables exportadas en el editor de Godot, permitiendo a los diseñadores controlar el número de rocas y su distancia desde el centro de forma intuitiva.

El script se encarga de:
- Instanciar la `rock_scene` definida, que es un `PackedScene` que representa la escena de una roca individual.
- Posicionar estas instancias en un patrón circular equidistante.
- Rotar cada roca para que su "frente" apunte hacia afuera del centro del círculo.
- Limpiar y regenerar las rocas cuando los parámetros configurables (`rocks_count` o `radius`) cambian, tanto en tiempo de ejecución como en el editor, gracias a los *setters* implementados en las propiedades.

Este componente es ideal para crear formaciones rocosas o estructuras similares que requieren una distribución radial y fácil ajuste por parte de los diseñadores de niveles.

# Métodos

## Métodos de Godot

### `_ready()`
Este método de ciclo de vida de Godot se ejecuta una vez que el nodo al que está adjunto el script, y sus hijos, han sido añadidos al árbol de la escena. Su única función es invocar al método `update_rocks()`. Esto asegura que las rocas se generen y posicionen inmediatamente según los valores configurados de `rocks_count` (cantidad de rocas) y `radius` (distancia desde el centro hasta cada roca) tan pronto como la escena se carga o el nodo entra en el árbol.

## Otros métodos

### `update_rocks() -> void`
Este método encapsula la lógica central para la gestión de las rocas. Su ejecución conlleva los siguientes pasos:

1.  **Limpieza de rocas existentes:**
    Itera sobre todos los nodos hijos actuales del `rock_spawner` y los libera de la memoria usando `queue_free()`. Este paso es crucial para eliminar las rocas previamente generadas y evitar duplicaciones o acumulación de nodos antes de crear nuevas instancias, asegurando un estado limpio antes de la regeneración.

    ```gdscript
    for child in get_children():
        child.queue_free()
    ```

2.  **Verificación de inicialización del nodo:**
    Incluye una comprobación `if not is_node_ready(): return` para asegurar que el nodo está completamente inicializado en el árbol de la escena antes de proceder con la instanciación. Esto es particularmente útil cuando el método es llamado desde los *setters* de las variables exportadas (`rocks_count` y `radius`) mientras se edita en Godot, previniendo posibles errores si se intentan crear nodos antes de que el `rock_spawner` esté completamente listo.

3.  **Cálculo del vector director:**
    Se inicializa un vector `director` que apunta en la dirección `Vector3.FORWARD` (eje Z positivo local del `rock_spawner`) y tiene una longitud igual al `radius` configurado. Este vector sirve como base para calcular la posición de cada roca individual a lo largo del círculo.

    ```gdscript
    var director = Vector3.FORWARD * radius
    ```

4.  **Generación y posicionamiento de rocas:**
    Se inicia un bucle que se ejecuta `rocks_count` veces. En cada iteración:
    *   **Instanciación:** Se crea una nueva instancia de la `rock_scene` utilizando `rock_scene.instantiate()`. La `rock_scene` es una variable `@export` de tipo `PackedScene` que debe ser asignada en el editor de Godot a una escena de roca predefinida.
    *   **Cálculo de rotación:** Se calcula el ángulo `new_rock_rotation` necesario para distribuir las rocas de manera uniforme en un círculo completo (360 grados o `TAU` radianes). Este ángulo asegura que cada roca esté equidistante de la siguiente en la circunferencia.
    *   **Posicionamiento:** La posición de la `new_rock` se determina rotando el `director` alrededor del eje `Vector3.UP` (eje Y) por `new_rock_rotation`. Esto coloca la roca en el punto correcto de la circunferencia, a la distancia `radius` del centro del `rock_spawner`.
    *   **Orientación:** La propia `new_rock` es rotada alrededor de su eje `Vector3.UP` por el mismo `new_rock_rotation`. Esto asegura que la "cara" frontal de la roca (su eje Z local) apunte hacia afuera desde el centro del círculo, dando una apariencia radial.
    *   **Adición al árbol:** Finalmente, la roca instanciada y posicionada se añade como hija del nodo `rock_spawner` mediante `add_child(new_rock, true)`. El argumento `true` indica que es un hijo "interno", lo cual es una buena práctica para nodos generados programáticamente que son gestionados exclusivamente por el script padre.

    ```gdscript
    for i in range(rocks_count):
        var new_rock: Node3D = rock_scene.instantiate()
        var new_rock_rotation := (TAU * i) / rocks_count

        new_rock.position = director.rotated(Vector3.UP, new_rock_rotation)
        new_rock.rotate(Vector3.UP, new_rock_rotation)
        add_child(new_rock, true)
    ```

    Este método es invocado automáticamente por los *setters* de las variables `@export` `rocks_count` y `radius`. Esto significa que cualquier cambio en estos valores a través del Inspector de Godot resultará en una actualización visual inmediata de la disposición de las rocas, facilitando la iteración de diseño.