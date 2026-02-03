# `MainMenu`

Este script actúa como el controlador principal de la interfaz de usuario del menú de inicio. Su propósito fundamental es gestionar la transición inicial del flujo de ejecución del juego, coordinando la ambientación sonora y las interacciones del usuario para navegar hacia las diferentes secciones del proyecto (Tutorial, Créditos o Salida).

El script se apoya en dos sistemas globales (Autoloads/Singletons) denominados `MusicManager` y `SceneManager`, lo que permite una gestión centralizada y desacoplada de la lógica de recursos.

# Métodos

## Métodos de Godot

### `_ready() -> void`
Es el punto de entrada al inicializar la escena del menú. Su función principal es establecer el estado auditivo inicial del juego.

* **Funcionamiento**: Invoca al método `play_music` del singleton `MusicManager`, pasando como argumento el identificador `"start_menu"`. Esto asegura que la banda sonora correspondiente al menú principal comience a reproducirse apenas el nodo entra al árbol de escenas.

```gdscript
func _ready() -> void:
    MusicManager.play_music("start_menu")
```

## Funciones asociadas a señales

#### `_on_play_button_pressed() -> void`
Este método está vinculado a la señal `pressed` del botón destinado a iniciar la experiencia de juego.

* **Funcionamiento**: Utiliza el `SceneManager` para realizar una transición hacia la escena `"tutorial"`. Se asume que el tutorial es la puerta de entrada obligatoria o recomendada para los nuevos jugadores antes de acceder a las mecánicas principales de *Beast Card Clash*.

#### `_on_credits_button_pressed() -> void`
Este método responde a la interacción con el botón de créditos del menú.

* **Funcionamiento**: Solicita al `SceneManager` el cambio hacia la escena `"credits"`. Este flujo permite a los usuarios visualizar la información sobre **Osito y Co.** y los detalles de la licencia MIT mencionados en la documentación general.

#### `_on_quit_button_pressed() -> void`
Gestiona la terminación de la instancia del juego desde la interfaz de usuario.

* **Funcionamiento**: Accede al `SceneTree` mediante `get_tree()` y ejecuta el método `quit()`. Esto cierra la aplicación de forma inmediata y segura en plataformas de escritorio.

> [!NOTE]
> Este script depende enteramente de la existencia de los singletons `MusicManager` y `SceneManager`. Cualquier cambio en la firma de los métodos de estos managers (como `play_music` o `change_to_scene`) requerirá una actualización directa en este controlador.