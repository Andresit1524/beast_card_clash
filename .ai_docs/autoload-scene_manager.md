# `SceneManager`
Este script, que extiende `Node`, actúa como un gestor centralizado para las transiciones de escenas dentro del juego. Su función principal es facilitar el cambio entre diferentes escenas del proyecto de manera controlada y verificada. Para ello, precarga un recurso personalizado de tipo `Scenes` que contiene una colección de las `PackedScene` disponibles, indexadas por un nombre (`String`).

Al inicio, el gestor valida la integridad de este recurso de escenas, asegurando que los elementos almacenados sean del tipo esperado. Posteriormente, proporciona una interfaz sencilla para que otros componentes del juego soliciten cambios de escena utilizando el nombre lógico de la escena. Este enfoque encapsula la lógica de carga y validación de escenas, promoviendo una mayor consistencia y reduciendo errores en la gestión del flujo del juego.

# Métodos

## Métodos de Godot

### `_ready()`
El método `_ready()` se ejecuta una vez que el nodo `SceneManager` ha entrado en el árbol de escenas. Su propósito en este script es inicializar y validar el recurso `_scenes` que contiene la lista de escenas del juego.

```gdscript
func _ready():
	_scenes.expected_type = TYPE_OBJECT
	_scenes.check_item_types()
```

1.  **`_scenes.expected_type = TYPE_OBJECT`**: Esta línea establece una propiedad `expected_type` dentro del recurso `_scenes`. Esto indica que se espera que los elementos contenidos en `_scenes` sean de tipo `Object`. En el contexto de Godot, las `PackedScene` (que son los objetos que se cargan para las escenas) son instancias de `Object`. Esta configuración es una medida de seguridad o validación interna del recurso `_scenes`.
2.  **`_scenes.check_item_types()`**: Después de establecer el tipo esperado, se llama a este método del recurso `_scenes`. Esta función, presumiblemente implementada dentro de la clase `Scenes` (que se precarga con `uid://bn7v8txng2pda`), se encarga de verificar que todos los elementos almacenados dentro del recurso `_scenes` realmente correspondan al `expected_type` especificado. Esto ayuda a detectar configuraciones incorrectas o recursos dañados al inicio del juego, garantizando que solo se intenten cargar escenas válidas.

> [!Note] Contexto de `Scenes`
> El recurso `_scenes` (precargado desde `uid://bn7v8txng2pda`) es un recurso personalizado. Su funcionalidad de `expected_type` y `check_item_types()` sugiere que es una colección tipada de `PackedScene`, que ofrece una capa adicional de validación de datos para la lista de escenas del juego. Se recomienda revisar la definición de este recurso (`scenes.tres` en el inspector o su script asociado) para entender completamente su funcionamiento interno.

## Otros métodos

### `change_to_scene(scene_name: String) -> void`
Este método público es la interfaz principal para solicitar un cambio de escena. Permite a cualquier otro script en el proyecto navegar a una nueva escena simplemente proporcionando su nombre lógico como un `String`.

```gdscript
func change_to_scene(scene_name: String) -> void:
	get_tree().change_scene_to_packed(_scenes.get_item(scene_name))
```

1.  **`_scenes.get_item(scene_name)`**: Se utiliza el recurso `_scenes` para obtener la `PackedScene` correspondiente al `scene_name` proporcionado. El `Scenes` recurso está diseñado para almacenar y recuperar estas escenas `PackedScene` por su nombre, actuando como un diccionario o mapa.
2.  **`get_tree().change_scene_to_packed(...)`**: Una vez que se ha recuperado la `PackedScene` deseada, se llama al método `change_scene_to_packed()` de la `SceneTree` global del juego. Este método de Godot se encarga de liberar la escena actual de la memoria, cargar la nueva `PackedScene` y establecerla como la escena activa del juego.

> [!Tip] `scenes.tres`
> Como se menciona en la documentación del método, para conocer la lista exacta de nombres de escena válidos y las `PackedScene` asociadas, es necesario inspeccionar el recurso `scenes.tres` (o el nombre que tenga el recurso con `uid://bn7v8txng2pda`) directamente en el editor de Godot. Este archivo es crucial para la configuración de las escenas disponibles en el juego.