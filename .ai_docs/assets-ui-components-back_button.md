# `BackButton`
Este script se adjunta a un nodo `Control` para dotarlo de la funcionalidad de un botón de "retroceso". Su principal función es detectar cuando el usuario interactúa con este control y, en respuesta, navegar a la escena del menú principal (`start_menu`) del juego.

La implementación aprovecha el sistema de señales de Godot para manejar la interacción del usuario y un `SceneManager` global o autoload para gestionar la transición entre escenas de manera centralizada.

# Métodos

## Métodos de Godot

### `_ready()`
Este método, parte del ciclo de vida de los nodos de Godot, se ejecuta una vez que el nodo `BackButton` y todos sus hijos han entrado en el árbol de escenas.

Su propósito es establecer una conexión entre la señal `pressed` del propio nodo `Control` al que está adjunto este script y el método `_on_pressed()` también definido en este script.

```gdscript
func _ready() -> void:
	connect("pressed", _on_pressed)
```

Al conectar la señal `pressed` a `_on_pressed`, se asegura que cada vez que el `Control` sea activado (típicamente por un clic del ratón, un toque en pantallas táctiles o una pulsación de tecla/gamepad), el método `_on_pressed()` será invocado para ejecutar la lógica de navegación.

## Otros métodos

### `_on_pressed()`
Este método es la pieza central de la funcionalidad del botón de retroceso. Su ejecución está directamente ligada a la activación del nodo `Control` al que está adjunto el script, gracias a la conexión establecida en `_ready()`.

```gdscript
func _on_pressed() -> void:
	SceneManager.change_to_scene("start_menu")
```

Dentro de este método, se realiza una llamada a `SceneManager.change_to_scene("start_menu")`. Esto indica que el script delega la responsabilidad de cambiar de escena a una clase `SceneManager` global o autoload (singleton) del proyecto. El argumento `"start_menu"` es un identificador de la escena a la que se desea navegar, que en este contexto corresponde al menú principal del juego.

> [!NOTE]
> La clase `SceneManager` se asume como un `Autoload` (Singleton) o una clase estática que gestiona la transición entre escenas del juego, proporcionando una interfaz centralizada para la navegación. Esto es una buena práctica para desacoplar la lógica de cambio de escena de los nodos individuales.

## Funciones asociadas a señales

#### `_on_pressed()`
Este método está asociado a la señal `pressed` del nodo `Control` al que se adjunta este script.

Cuando el nodo `Control` es "presionado" (por ejemplo, mediante un clic del usuario), la señal `pressed` se emite. Gracias a la conexión realizada en `_ready()`, esta emisión de señal invoca el método `_on_pressed()`. Su función es, por lo tanto, actuar como el *handler* para la interacción del usuario con el botón, ejecutando la acción de cambiar a la escena `start_menu`.