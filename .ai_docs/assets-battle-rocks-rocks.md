# `Rocks`
Este script, denominado `Rocks` y que hereda de `Node3D`, actúa como un gestor y contenedor para una colección de objetos de roca dentro del juego. Su propósito principal es instanciar, posicionar, rotar y asignar un elemento a una cantidad predefinida de rocas, organizándolas en un patrón circular en el entorno 3D. Utiliza constantes como `ROCK_COUNT` (cantidad de rocas), `RADIUS` (radio del círculo) y `ROCK_Z_OFFSET` (altura de las rocas) para definir la disposición circular de estos elementos. Además, una variable de exportación `rock_scene` permite especificar la escena (`PackedScene`) que se instanciará para cada roca individual, delegando la lógica y el aspecto de cada roca a su propia configuración y script (`Rock.gd`).

Las rocas son instancias de una escena `PackedScene` externa, lo que permite que el script `Rocks` se enfoque en la gestión del conjunto, mientras la lógica de cada roca es manejada por su propio script. La disposición de las rocas es fundamental para la interacción en el juego, formando un círculo de `ROCK_COUNT` rocas alrededor de un punto central, con una altura ligeramente elevada sobre el plano. Cada roca recibe un índice único (`rock_index`) y un elemento asignado cíclicamente de `GameConstants.Elements`, lo que sugiere que estas rocas cumplen un rol mecánico o visual relacionado con los elementos del juego.

# Métodos

## Métodos de Godot

### `_ready()`
Este método es una función de *callback* de Godot que se ejecuta una vez cuando el nodo `Rocks` y todos sus hijos son añadidos a la escena y están listos para su uso. Su única función es inicializar la disposición de las rocas en el entorno 3D, llamando al método `_instance_rocks()`. Esto asegura que todas las rocas se creen, posicionen y configuren automáticamente al inicio de la escena donde este nodo `Rocks` esté presente.

## Otros métodos

### `_instance_rocks() -> void`
Este método es el corazón del script `Rocks`, responsable de la creación, posicionamiento y configuración de todas las rocas en la escena del juego.

1.  **Limpieza previa de rocas:** Antes de instanciar nuevas rocas, el método itera sobre todos los nodos hijos actuales del nodo `Rocks` y los libera de la memoria (`child.free()`). Esto es crucial para evitar duplicados si el método se llama varias veces durante la ejecución (por ejemplo, para reiniciar la disposición de las rocas), asegurando que siempre se trabaje con un conjunto fresco de rocas.

    ```gdscript
    for child in get_children():
        child.free()
    ```

2.  **Preparación del vector direccional:** Se define un `Vector3` llamado `director` que inicialmente apunta en la dirección `Vector3.FORWARD` (adelante en el espacio local) y tiene una magnitud igual al valor de la constante `RADIUS` (actualmente `8.0`). Este vector servirá como base para calcular la posición radial de cada roca, que luego será rotada.

    ```gdscript
    var director = Vector3.FORWARD * RADIUS
    ```

3.  **Instanciación y configuración en bucle:** El script itera `ROCK_COUNT` veces (establecido en `18`) para crear y configurar cada roca individualmente:
    *   **Instanciación de la roca:** Dentro del bucle, se crea una nueva instancia de la escena de roca predefinida (`rock_scene`) usando `rock_scene.instantiate()`. La variable `@export var rock_scene: PackedScene` debe estar configurada en el editor de Godot para apuntar a la escena de una roca individual (por ejemplo, `Rock.tscn`), que probablemente contiene un nodo `Node3D` con un *mesh* y un script asociado (`Rock.gd`).
    *   **Cálculo del ángulo de posición:** Se calcula un `new_rock_angle` para cada roca. Este ángulo distribuye las `ROCK_COUNT` rocas uniformemente alrededor de un círculo completo (`TAU` radianes, que es igual a 360 grados o `2 * PI`).
        ```gdscript
        var new_rock_angle := (TAU * i) / ROCK_COUNT
        ```
    *   **Asignación de posición:** La posición de la nueva roca (`new_rock.position`) se determina rotando el vector `director` alrededor del eje `Vector3.UP` por el `new_rock_angle` calculado. A esta posición radial se le añade un desplazamiento vertical (`Vector3.UP * ROCK_Z_OFFSET`) para elevar las rocas ligeramente sobre el plano del suelo, utilizando la constante `ROCK_Z_OFFSET` (actualmente `0.1`).
        ```gdscript
        new_rock.position = director.rotated(Vector3.UP, new_rock_angle) + Vector3.UP * ROCK_Z_OFFSET
        ```
    *   **Asignación de índice:** Se asigna el índice `i` del bucle (de `0` a `ROCK_COUNT - 1`) a la propiedad `rock_index` de la nueva roca. Esto proporciona un identificador único para cada roca, útil para la lógica del juego.
    *   **Rotación de la roca:** La roca individual se rota alrededor de su propio eje `Vector3.UP` por el `new_rock_angle`. Esto alinea la orientación de la roca con su posición radial en el círculo, de modo que parece "mirar" hacia afuera desde el centro del círculo.
        ```gdscript
        new_rock.rotate(Vector3.UP, new_rock_angle)
        ```
    *   **Adición a la escena:** La nueva roca (`new_rock`) se añade como hija del nodo `Rocks`. Esto la integra en la jerarquía de la escena y la hace visible y funcional.
        ```gdscript
        add_child(new_rock)
        ```
    *   **Asignación de elemento:** Finalmente, se asigna un elemento a la roca. El elemento se determina utilizando el operador módulo (`%`) con el índice de la roca (`i`) y el número total de elementos definidos en `GameConstants.Elements.size()`. Esto asegura una distribución cíclica de los elementos entre las rocas. Por ejemplo, si hay 3 elementos, las rocas tendrían elementos `0, 1, 2, 0, 1, 2, ...`. La conversión explícita `as GameConstants.Elements` mejora la seguridad de tipos si `GameConstants.Elements` es un `enum`. El comentario `Lo añade después para que se actualice el sprite adecuadamente` sugiere que el script de la roca (`Rock.gd`) tiene lógica interna para actualizar su representación visual (como un *sprite* o material 3D) basándose en este elemento asignado.
        ```gdscript
        new_rock.element = (i % GameConstants.Elements.size()) as GameConstants.Elements
        ```