# `SceneManager`

Este script funciona como un controlador centralizado para la navegación entre las diferentes interfaces y niveles del proyecto. Su propósito principal es desacoplar la lógica de cambio de escenas del resto de los nodos, permitiendo que cualquier componente del juego solicite una transición sin conocer las rutas de archivos específicas o la estructura del sistema de archivos.

El sistema utiliza un diccionario de escenas precargadas (`PackedScene`) vinculadas mediante **UIDs de Godot**, lo que garantiza que los recursos estén listos en memoria antes de ser llamados y previene errores de referencia si los archivos se mueven de carpeta en el sistema de archivos.

> [!NOTE]
> Por la naturaleza de su funcionamiento y el comentario interno sobre el "singleton", este script está diseñado para ser configurado en los **Autoloads** del proyecto, facilitando el acceso global desde cualquier parte del código mediante `SceneManager.change_to_scene()`.

# Métodos

## Otros métodos

### `change_to_scene(scene_name: String) -> void`
Es la función principal de interfaz para el resto del sistema. Recibe una cadena de texto que debe coincidir exactamente con una de las llaves definidas en el diccionario `scenes`.

```gdscript
func change_to_scene(scene_name: String) -> void:
    get_tree().change_scene_to_packed(scenes[scene_name])
```

**Funcionamiento:**
1.  Busca el objeto `PackedScene` correspondiente en el diccionario interno.
2.  Utiliza el método `change_scene_to_packed` de la clase `SceneTree`. Este método es más eficiente que `change_scene_to_file`, ya que procesa una escena que ya ha sido instanciada en memoria durante la fase de carga del script.
3.  Reemplaza la escena actual en el nodo raíz por la nueva escena proporcionada.

### Variables de configuración (Diccionario `scenes`)
El script define una propiedad `scenes` de tipo `Dictionary[String, PackedScene]` que actúa como el registro maestro de navegación:

*   **`start_menu`**: Referencia al menú principal del juego.
*   **`credits`**: Referencia a la pantalla de créditos y colaboradores.
*   **`tutorial`**: Referencia a la escena de aprendizaje de mecánicas.

> [!IMPORTANT]
> Al añadir nuevas escenas a este diccionario, es fundamental utilizar la sintaxis `preload("uid://...")` para mantener la integridad de las referencias y asegurar que el cambio de escena sea instantáneo para el usuario final.