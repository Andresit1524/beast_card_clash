# `PlayerData`
Este script actúa como un contenedor de datos fundamentales para la configuración de un jugador dentro del juego. Extiende la clase `Node` de Godot, lo que le permite existir en el árbol de escenas sin una representación visual directa, siendo ideal para la gestión de estados y datos globales o específicos de una entidad. Su propósito principal es almacenar y gestionar la información base de un jugador, como su nombre, equipo asignado, especie de animal elegida y la variante de apariencia (skin) asociada a dicha especie.

La información contenida en este script se inicializa con valores por defecto, lo que indica que estos valores serán probablemente sobreescritos o configurados por el usuario o el sistema de juego en etapas posteriores (por ejemplo, durante la creación de un perfil de jugador o la selección de personaje). La dependencia de un script externo `GameConstants` para tipos enumerados (`Teams`, `Species`) y datos de configuración (`SKINS`) es evidente, lo que subraya una arquitectura donde las constantes del juego se centralizan para facilitar la consistencia y el mantenimiento.

```gdscript
# Datos del jugador
var player_name: String = "Osorio"
var team: GameConstants.Teams = GameConstants.Teams.NO_TEAM
var species: GameConstants.Species = GameConstants.Species.BEAR
var skin: String = GameConstants.SKINS[species][0]
```

*   `player_name`: Una variable de tipo `String` que almacena el nombre del jugador, inicialmente "Osorio".
*   `team`: Una variable de tipo `GameConstants.Teams` que define el equipo al que pertenece el jugador. Se inicializa con `GameConstants.Teams.NO_TEAM`, sugiriendo que el jugador puede no tener un equipo asignado inicialmente o que esta es la configuración por defecto antes de una selección.
*   `species`: Una variable de tipo `GameConstants.Species` que representa la especie de animal elegida por el jugador. Se inicializa con `GameConstants.Species.BEAR`, que concuerda con la temática de animales autóctonos del proyecto.
*   `skin`: Una variable de tipo `String` que almacena la clave o ruta de la apariencia visual (skin) del personaje del jugador. Su valor se obtiene dinámicamente de la constante `GameConstants.SKINS`, utilizando la `species` seleccionada como índice para obtener la primera opción de skin disponible para esa especie (`[0]`). Esto permite una asociación directa entre la especie y sus apariencias visuales disponibles, facilitando la personalización del personaje.