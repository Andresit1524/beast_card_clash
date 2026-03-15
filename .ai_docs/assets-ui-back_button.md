# `ReturnToStartMenuButton`
Este script, que extiende la clase `Control` de Godot, está diseñado para funcionar como un componente interactivo de la interfaz de usuario (UI) que facilita la navegación entre escenas. Su propósito principal es detectar cuando el control al que está adjunto es "presionado" y, en respuesta, iniciar una transición a la escena `start_menu` del juego. Esto lo convierte en un candidato ideal para botones de retroceso, botones de menú principal o cualquier elemento de UI que necesite redirigir al jugador al menú de inicio.

El script se auto-conecta a la señal `pressed` de su nodo propietario en el método `_ready`, lo que implica que el nodo debe ser una subclase de `Control` que emita dicha señal (como `Button`, `TextureButton`, etc.). Al ser activado, delega la tarea de cambio de escena a un gestor de escenas global (`SceneManager`), promoviendo una gestión centralizada y consistente de las transiciones.

# Métodos

## Métodos de Godot

### `_ready() -> void`
Este método es parte del ciclo de vida de los nodos de Godot y se ejecuta una vez cuando el nodo y todos sus hijos están listos en el árbol de escenas. Su función dentro de este script es establecer la conexión entre la señal `pressed` del nodo `Control` al que está adjunto y el método `_on_pressed` del propio script. Esto asegura que cualquier interacción que emita la señal `pressed` en el `Control` active la lógica de navegación de escena definida en `_on_pressed`.

```gdscript
func _ready() -> void:
	connect("pressed", _on_pressed)
```
La línea `connect("pressed", _on_pressed)` es crucial, ya que establece el puente para que la interacción del usuario con el control dispare el cambio de escena. Al conectar la señal a un método dentro del mismo script, se mantiene la lógica de comportamiento autocontenida y modular.

## Funciones asociadas a señales

#### `_on_pressed() -> void`
Este método es la función de *callback* que se invoca cuando la señal `pressed` del nodo propietario es emitida. Su lógica principal consiste en llamar al método `change_to_scene` de un singleton o clase global `SceneManager`, pasándole la cadena `"start_menu"` como argumento.

```gdscript
func _on_pressed() -> void:
	SceneManager.change_to_scene("start_menu")
```
Esto indica que el proyecto utiliza una arquitectura donde las transiciones de escena son manejadas centralmente por un `SceneManager`. Este enfoque permite un control uniforme sobre el proceso de cambio de escena, que podría incluir animaciones de transición, carga asíncrona o lógicas de guardado. En este caso específico, el objetivo es siempre navegar a la escena identificada como el "menú de inicio", proporcionando una forma estandarizada de volver a la pantalla principal del juego. Este método encapsula la funcionalidad de un "botón de retroceso" o "botón de ir al menú principal" dentro del contexto del juego.