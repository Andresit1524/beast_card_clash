# `SceneManager`
Este script, que extiende `Node`, funciona como un **gestor centralizado de escenas** para el juego Beast Card Clash. Su propósito principal es facilitar las transiciones entre diferentes escenas del juego de una manera organizada y validada, mejorando la mantenibilidad y la experiencia de desarrollo.

Para lograr esto, el `SceneManager` utiliza un recurso personalizado llamado `Scenes` (previamente cargado como `_scenes`). Este recurso, que muy probablemente es un archivo `.tres` o `.gd` que extiende `Resource`, contiene una colección de `PackedScene`s (las escenas reales del juego) indexadas por nombres de `String`. Esto permite que el `SceneManager` cambie entre escenas simplemente refiriéndose a ellas por su nombre lógico en lugar de sus rutas de archivo directas, centralizando la configuración de las escenas en un único lugar.

---

# Métodos

## Métodos de Godot

### `_ready()`
Este método es parte del ciclo de vida de Godot y se ejecuta una vez cuando el nodo `SceneManager` entra en el árbol de escenas. Su función principal aquí es inicializar y validar el recurso `_scenes`.

```gdscript
func _ready():
	_scenes.expected_type = TYPE_OBJECT
	_scenes.check_item_types()
```

1.  **`_scenes.expected_type = TYPE_OBJECT`**: Establece el tipo esperado de los elementos dentro del recurso `_scenes` a `TYPE_OBJECT`. Esto es crucial para asegurar que los elementos almacenados en `_scenes` sean referencias a objetos, en este caso, instancias de `PackedScene`.
2.  **`_scenes.check_item_types()`**: Llama a un método del recurso `_scenes` (asumiendo que es un recurso personalizado con esta funcionalidad) para verificar que todos los elementos definidos dentro de él cumplen con el `expected_type` configurado. Esta validación temprana ayuda a detectar errores de configuración de escenas al inicio del juego, lo que es vital para una buena experiencia de desarrollo.

> [!TIP]
> La validación en `_ready()` es una buena práctica para asegurar que los recursos críticos están correctamente configurados antes de que intenten ser usados, previniendo errores en tiempo de ejecución.

## Otros métodos

### `change_to_scene(scene_name: String) -> void`
Este método es la interfaz principal del `SceneManager` para realizar transiciones entre escenas. Permite a cualquier otro script o componente del juego solicitar un cambio de escena especificando el nombre lógico de la escena.

```gdscript
func change_to_scene(scene_name: String) -> void:
	get_tree().change_scene_to_packed(_scenes.get_item(scene_name))
```

1.  **`scene_name: String`**: Recibe un `String` que representa el nombre de la escena a la que se desea cambiar. Este nombre debe coincidir con una de las entradas definidas en el recurso `_scenes`.
2.  **`_scenes.get_item(scene_name)`**: Utiliza el nombre proporcionado para buscar y obtener la `PackedScene` correspondiente del recurso `_scenes`. Esta es la escena precargada que Godot puede instanciar.
3.  **`get_tree().change_scene_to_packed(...)`**: Godot proporciona esta función para cambiar la escena activa del `SceneTree` a una `PackedScene` específica. El `SceneManager` envuelve esta funcionalidad, abstrayendo los detalles de dónde se encuentra físicamente el archivo de la escena.

> [!NOTE]
> Para ver la lista de nombres de escenas disponibles y las `PackedScene`s asociadas, los desarrolladores deben revisar el recurso `scenes.tres` (o el nombre que tenga el recurso preconfigurado con el `uid://bn7v8txng2pda`) directamente en el Inspector de Godot. Esto centraliza la gestión de escenas y facilita la navegación por el proyecto.