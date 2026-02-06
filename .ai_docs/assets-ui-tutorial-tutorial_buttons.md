# `VBoxContainer` (Controlador de Tutorial y Paneles)

Este script gestiona una secuencia lógica de elementos visuales dentro de un contenedor de interfaz de usuario. Su función principal es controlar la transición secuencial de recursos (texturas) a través de una lista predefinida, permitiendo al usuario avanzar paso a paso por una serie de paneles explicativos o narrativos. Está diseñado para actuar como el controlador de flujo de un tutorial o una introducción visual dentro de **Beast Card Clash**.

El sistema utiliza un nodo `TextureRect` como visor dinámico y un arreglo de recursos para centralizar los activos visuales, facilitando la edición de contenido desde el inspector de Godot sin necesidad de modificar el código.

# Métodos

## Métodos de Godot

### `_ready() -> void`
Inicializa el componente asegurando que la interfaz muestre el primer elemento de la lista al momento de entrar al árbol de escena. Accede al índice `0` del arreglo `panels_list` y asigna el recurso a la propiedad `texture` del `panel_node`.

```gdscript
func _ready() -> void:
    panel_node.texture = panels_list[0]
```

## Funciones asociadas a señales

### `_on_next_button_pressed() -> void`
Este método se activa mediante la señal `pressed` de un botón de navegación (generalmente etiquetado como "Siguiente"). Incrementa el contador `current_panel` para avanzar en el arreglo.

El método incluye una validación de límites para detectar el final de la secuencia:
1. Si el índice actual iguala o supera el tamaño de `panels_list`, invoca automáticamente a `_on_skip_button_pressed()`.
2. Si aún hay elementos, actualiza la propiedad `texture` del `panel_node` con el siguiente recurso.

```gdscript
func _on_next_button_pressed() -> void:
    current_panel += 1

    if current_panel >= panels_list.size():
        _on_skip_button_pressed()
        return

    panel_node.texture = panels_list[current_panel]
```

### `_on_skip_button_pressed() -> void`
Actúa como el punto de salida de la secuencia de paneles. Se activa mediante la señal de un botón de "Omitir" o como consecuencia de haber terminado de recorrer todos los paneles en `_on_next_button_pressed`.

> [!IMPORTANT]
> Actualmente, este método funciona como un **placeholder**. La lógica para cambiar de escena o cerrar el modal del tutorial aún no está implementada, limitándose a una impresión en consola para depuración.

```gdscript
func _on_skip_button_pressed() -> void:
    print("[Info] Salta el tutorial!")
    return
```