# `back_button.gd`

Este script extiende la funcionalidad básica de un `BaseButton` para actuar como un controlador de navegación de retorno dentro de la interfaz de usuario de **Beast Card Clash**. Su propósito principal es desacoplar la lógica de entrada del usuario de la gestión de escenas, delegando la transición al Singleton global del proyecto.

El script es ligero y está diseñado para ser adjuntado a nodos de tipo `Button` o `TextureButton` en menús secundarios, opciones o pantallas de créditos donde se requiera una salida consistente hacia el menú principal.

# Métodos

## Métodos de Godot

### `_ready() -> void`
Es el punto de entrada del script. Se encarga de la inicialización de las señales del nodo.

*   **Funcionamiento:** Realiza la conexión de la señal nativa `pressed` del `BaseButton` con el método local `_on_pressed`. Esta conexión programática asegura que el botón sea funcional independientemente de si la conexión se configuró manualmente en el editor de Godot.

```gdscript
func _ready() -> void:
    connect("pressed", _on_pressed)
```

## Funciones asociadas a señales

#### `_on_pressed() -> void`
Este método actúa como el *callback* principal cuando el usuario interactúa con el botón (clic o pulsación).

*   **Lógica de Ejecución:** Invoca al sistema de gestión de escenas global mediante la clase `SceneManager`. 
*   **Interacción con el proyecto:** Utiliza el método `change_to_scene` pasando como argumento el identificador `"start_menu"`. Esto implica la existencia de un **Autoload/Singleton** llamado `SceneManager` que centraliza las transiciones y la carga de recursos de las escenas del juego.

> [!IMPORTANT]
> El correcto funcionamiento de este script depende enteramente de que `SceneManager` esté registrado en los *Autoloads* del proyecto y posea el método `change_to_scene()`.

```gdscript
func _on_pressed() -> void:
    SceneManager.change_to_scene("start_menu")
```