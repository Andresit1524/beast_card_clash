# `EndUI`
`EndUI` es una clase GDScript que extiende `Control`, diseñada para gestionar la interfaz de usuario que se presenta al final de una batalla o segmento de juego. Su propósito principal es controlar la visibilidad y aplicar efectos de transición (como el fade) a esta interfaz, proporcionando opciones al jugador como volver al menú principal.

El script define una propiedad exportada, `ui_visible` (booleana), que controla la visibilidad general de la UI. Esta propiedad utiliza un *setter* personalizado que, cada vez que su valor cambia, invoca el método `set_ui_visible()` para aplicar los efectos visuales correspondientes. Esto permite que la visibilidad de la UI sea gestionada de forma externa al script, pero con las animaciones de fade encapsuladas internamente.

Internamente, `EndUI` hace referencia a nodos hijos como `blur_rect` (un `ColorRect` que se presume añade un efecto de desenfoque de fondo, aunque no es manipulado directamente por este script) y `exit_button` (un `Button` para la interacción del usuario). Utiliza el sistema `Tween` de Godot para animaciones suaves y se integra con un sistema de gestión de escenas (`SceneManager`) para la navegación entre distintas partes del juego.

# Métodos

## Métodos de Godot

### `_ready()`
Este método de callback de Godot se ejecuta una vez que el nodo `EndUI` y todos sus hijos han entrado en el árbol de escenas. Su función principal es configurar las conexiones iniciales necesarias para la interactividad de la UI:
- Conecta la señal `pressed` del nodo `exit_button` (un `Button` que se espera sea un hijo de `EndUI`) al método `_quit_battle()`. Esto asegura que cuando el jugador hace clic en el botón de salida, se ejecute la lógica para finalizar la batalla y cambiar de escena.

```gdscript
func _ready() -> void:
	exit_button.pressed.connect(_quit_battle)
```

## Otros métodos

### `set_ui_visible(value: bool)`
Este método es el *setter* personalizado para la propiedad exportada `ui_visible`. Se encarga de controlar la visibilidad del nodo `EndUI` y de aplicar un efecto de *fade* (aparición o desaparición gradual) utilizando el sistema `Tween` de Godot. La duración de este efecto está definida por la constante `FADE_TIME` (0.5 segundos).

-   **Si `value` es `false` (ocultar UI):**
    1.  Crea un nuevo `Tween`.
    2.  Anima la propiedad `modulate` del nodo `EndUI` (que afecta el color y la transparencia de todo el control) para que pase de su estado actual a `Color.TRANSPARENT` (totalmente transparente) durante `FADE_TIME`.
    3.  Una vez completada la animación de fade out, se añade un `tween_callback` que establece la propiedad `visible` del nodo `EndUI` a `false`. Esto asegura que el nodo no sea procesado ni dibujado después de que se haya vuelto completamente transparente.

    ```gdscript
    if not value:
        tween.tween_property(self, "modulate", Color.TRANSPARENT, FADE_TIME)
        tween.tween_callback(func(): visible = false)
        return
    ```

-   **Si `value` es `true` (mostrar UI):**
    1.  Establece `visible = true` para asegurar que el nodo sea dibujado.
    2.  Inicializa `modulate` a `Color.TRANSPARENT` para que el efecto de fade in comience desde la invisibilidad.
    3.  Crea un nuevo `Tween`.
    4.  Anima la propiedad `modulate` del nodo `EndUI` para que pase de `Color.TRANSPARENT` a `Color.WHITE` (totalmente visible) durante `FADE_TIME`.

    ```gdscript
    visible = true
    modulate = Color.TRANSPARENT
    tween.tween_property(self, "modulate", Color.WHITE, FADE_TIME)
    ```

Este método garantiza transiciones visuales suaves al mostrar u ocultar la interfaz de fin de batalla, mejorando la experiencia del jugador.

## Funciones asociadas a señales

#### `_quit_battle()`
Este método está conectado a la señal `pressed` del nodo `exit_button`. Cuando el jugador hace clic en el botón de salida, se ejecuta la siguiente lógica:

1.  Establece la propiedad `ui_visible` del `EndUI` a `false`. Esto activa el *setter* `set_ui_visible()`, lo que inicia la animación de *fade out* de la interfaz y finalmente la oculta.
2.  Llama al método `change_to_scene()` del singleton `SceneManager`, pasándole la cadena `"start_menu"`. Esto indica que, una vez que la UI de fin de batalla se ha ocultado, el juego debe cambiar a la escena del menú principal, llevando al jugador fuera de la batalla actual.

```gdscript
func _quit_battle() -> void:
	ui_visible = false
	SceneManager.change_to_scene("start_menu")
```