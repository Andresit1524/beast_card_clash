# `Rocks`
El script `Rocks` define un nodo `Node3D` que actúa como un gestor para la creación y disposición de objetos de tipo "roca" en el entorno 3D del juego. Su función principal es instanciar una cantidad configurable de rocas en una formación circular, asignando a cada una un "elemento" de forma cíclica. Esta funcionalidad es clave para establecer los puntos de interés o "campos de batalla" para las cartas en el juego `Beast Card Clash`, integrando la temática de elementos y biodiversidad.

Este script gestiona la lógica de:
*   Generación dinámica de rocas a partir de una escena predefinida.
*   Disposición espacial de las rocas en un patrón circular con un radio configurable.
*   Asignación de un elemento a cada roca, utilizando una constante global `GameConstants.Elements`.
*   Mantenimiento de una lista de las rocas instanciadas.

---

# Métodos

## Métodos de Godot

### `_ready()`
Este método se llama automáticamente cuando el nodo y todos sus hijos están listos para entrar en la escena. Su función es inicializar la disposición de las rocas en la escena, asegurando que se generen tan pronto como el nodo `Rocks` esté disponible.

```gdscript
func _ready():
	update_rocks()
```

Al llamar a `update_rocks()`, se desencadena la creación, posicionamiento y configuración de todas las rocas según los parámetros definidos en el inspector de Godot.

## Otros métodos

### `update_rocks() -> void`
Este método es el núcleo de la funcionalidad de `Rocks`. Se encarga de la generación, posicionamiento y configuración de las rocas en la escena. Es llamado tanto en `_ready()` como por los *setters* de las propiedades `rocks_count` y `radius`, lo que permite una actualización dinámica de la disposición de las rocas directamente desde el editor o durante la ejecución si estas propiedades se modifican.

```gdscript
func update_rocks() -> void:
	for child in get_children():
		child.queue_free()

	if not is_node_ready(): return

	var director = Vector3.FORWARD * radius

	for i in range(rocks_count):
		var new_rock: Node3D = rock_scene.instantiate()
		var new_rock_rotation := (TAU * i) / rocks_count

		# Posición y rotación de la roca
		new_rock.position = director.rotated(Vector3.UP, new_rock_rotation)
		new_rock.position.y = ROCK_Y_OFFSET
		new_rock.rotate(Vector3.UP, new_rock_rotation)
		add_child(new_rock)

		# Elemento
		new_rock.element = i % GameConstants.Elements.size()
		rocks_list.append(new_rock)
```

**Funcionamiento detallado:**
1.  **Limpieza previa:** Itera sobre todos los hijos actuales del nodo `Rocks` y los libera de la memoria (`child.queue_free()`). Esto asegura que no queden rocas duplicadas o antiguas al regenerar la lista.
2.  **Verificación de nodo listo:** Realiza una comprobación `if not is_node_ready(): return` para evitar errores si el método es llamado antes de que el nodo esté completamente inicializado, especialmente útil para los *setters* en el editor.
3.  **Cálculo de posición base:** Define un vector `director` que se extiende desde el centro del nodo `Rocks` a lo largo del eje Z (`Vector3.FORWARD`) por una distancia igual a `radius`.
4.  **Bucle de instanciación:** Recorre un rango desde `0` hasta `rocks_count - 1`:
    *   **Instanciación:** Crea una nueva instancia de la escena de roca (`rock_scene`). Se asume que `rock_scene` es una `PackedScene` que contiene un nodo `Node3D` como raíz, que será el `new_rock`.
    *   **Cálculo de rotación:** Determina la rotación angular (`new_rock_rotation`) necesaria para distribuir las rocas uniformemente en un círculo completo (`TAU` radianes).
    *   **Posicionamiento:**
        *   La posición de `new_rock` se calcula rotando el vector `director` alrededor del eje Y (`Vector3.UP`) por `new_rock_rotation`. Esto coloca la roca en la circunferencia deseada.
        *   Se aplica un `ROCK_Y_OFFSET` para ajustar la altura de la roca por encima del plano base.
    *   **Rotación de la roca:** `new_rock` se rota sobre su propio eje Y (`Vector3.UP`) con el mismo ángulo `new_rock_rotation`. Esto hace que cada roca "mire" hacia afuera del centro del círculo.
    *   **Jerarquía de nodos:** La nueva roca se añade como hija del nodo `Rocks` (`add_child(new_rock)`).
    *   **Asignación de elemento:** Se asigna un `element` a la roca. El valor se obtiene usando el operador módulo (`%`) sobre el índice del bucle (`i`) y el tamaño de `GameConstants.Elements`. Esto asegura que los elementos se asignen de forma cíclica (por ejemplo, si hay 3 elementos, las rocas tendrán elemento 0, 1, 2, 0, 1, 2...). Se asume que `new_rock` tiene una propiedad `element` que puede ser establecida.
    *   **Almacenamiento:** La instancia `new_rock` (que es un `Node3D`) se añade a la lista `rocks_list`.

### `get_abstract_rocks_list() -> Array`
Este método tiene como objetivo obtener una representación "abstracta" de las rocas presentes en la escena.

```gdscript
func get_abstract_rocks_list() -> Array:
	for rock_pos in get_children():
		var rock: RockScene = rock_pos.get_child(0)
		rocks_list.append(rock.get_abstract_rock())

	return rocks_list
```

**Funcionamiento detallado:**
1.  **Iteración de hijos:** Itera sobre todos los hijos del nodo `Rocks`. Cada `rock_pos` en este bucle es una de las instancias `Node3D` creadas por `update_rocks()`.
2.  **Acceso a `RockScene`:** Para cada `rock_pos`, se intenta acceder a su primer hijo (`rock_pos.get_child(0)`), el cual se asume que es de tipo `RockScene`. Esto implica que la escena de roca (`rock_scene`) que se instancia en `update_rocks()` tiene la estructura: `Node3D` (raíz de la escena, `new_rock`) que contiene un nodo `RockScene` como su primer hijo.
3.  **Obtención de representación abstracta:** Se llama al método `get_abstract_rock()` en la instancia de `RockScene` encontrada. Se espera que este método devuelva un objeto que represente los datos clave o el estado de la roca de forma más concisa o para un propósito específico del juego (ej. datos para la interfaz de usuario, lógica de juego).
4.  **Almacenamiento y retorno:** El objeto "abstracto" retornado se añade a la lista `rocks_list`.
    *   **Nota importante:** A diferencia de `update_rocks()`, este método no limpia `rocks_list` antes de añadir nuevos elementos. Si `get_abstract_rocks_list()` es llamado después de `update_rocks()`, `rocks_list` contendrá una mezcla de `Node3D` (instancias de roca) y las representaciones "abstractas" de `RockScene`, lo que podría llevar a comportamientos inesperados si la lista no se gestiona con cuidado en otras partes del código. Se recomienda que, si el propósito es solo obtener la lista abstracta, se retorne una nueva lista o se limpie `rocks_list` antes de añadir los elementos abstractos.
5.  Finalmente, se retorna la lista `rocks_list`, que ahora contendrá los objetos abstractos (y potencialmente las instancias de `Node3D` originales si no se vació previamente).