# `PlayerProfile`
Este script, denominado `PlayerProfile` (nombre inferido por su contenido), actúa como un contenedor centralizado para almacenar y gestionar los datos fundamentales de un jugador dentro del juego `Beast Card Clash`. Al extender `Node`, este script puede ser utilizado de diversas maneras en la arquitectura del proyecto. Es una práctica común en el desarrollo de videojuegos indie usar scripts como este como un *Autoload* (Singleton) para asegurar que la información del jugador esté accesible desde cualquier parte del juego sin necesidad de pasarlo explícitamente entre escenas. También podría ser parte de un nodo instanciado en una escena específica, aunque su naturaleza de "datos de jugador" sugiere una utilidad más global.

Su propósito principal es mantener las características esenciales del personaje del jugador, incluyendo su identificador, afiliación a un equipo o facultad, especie animal y apariencia visual inicial. Este enfoque simplifica la gestión de la identidad y las propiedades básicas del jugador a lo largo de las diferentes fases del juego, promoviendo una experiencia de desarrollo eficiente.

## Variables
El script define las siguientes propiedades para almacenar los datos del jugador, las cuales se inicializan con valores predeterminados para facilitar el desarrollo y las pruebas:

*   `player_name: String = "Osorio"`
    *   Representa el nombre o alias que el jugador ha elegido para sí mismo dentro del juego. Es un identificador de tipo `String` con un valor predeterminado "Osorio". Este nombre es crucial para la identificación del jugador en interfaces de usuario y registros de puntuación.

*   `team: GameConstants.Teams = GameConstants.Teams.NO_TEAM`
    *   Define la afiliación del jugador a un equipo o facultad específica. Se utiliza una enumeración `Teams` del script `GameConstants` para asegurar valores consistentes y predefinidos en todo el proyecto. El valor inicial `NO_TEAM` indica que el jugador no tiene una afiliación de equipo asignada, lo que podría ser el estado inicial antes de unirse a una partida o en modos de juego que no requieren equipos. Este campo es clave para mecánicas competitivas y la representación de las "facultades de la Universidad Nacional de Colombia" como equipos o facciones.

*   `species: GameConstants.Species = GameConstants.Species.BEAR`
    *   Especifica la especie animal que el jugador ha elegido o se le ha asignado, representando uno de los "animales autóctonos colombianos" que dan vida al universo de `Beast Card Clash`. Al igual que con `team`, utiliza la enumeración `Species` de `GameConstants` para mantener la coherencia y facilitar la referenciación de las diferentes criaturas. El valor inicial `BEAR` (Oso) sirve como un ejemplo de especie, fundamental para determinar las habilidades, cartas y la estética general del personaje del jugador.

*   `skin: String = GameConstants.SKINS[species][0]`
    *   Determina la apariencia visual específica ("skin") de la especie seleccionada. Es una `String` que se inicializa extrayendo el primer elemento de una colección de skins disponible para la `species` actual. Esta colección está definida en el diccionario `SKINS` de `GameConstants`.
        ```gdscript
        var skin: String = GameConstants.SKINS[species][0]
        ```
        Este fragmento de código indica que `GameConstants.SKINS` es una estructura de datos (probablemente un `Dictionary`) donde las claves son las `Species` (e.g., `GameConstants.Species.BEAR`) y los valores son arrays o listas de nombres de skins (e.g., `["default_bear_skin", "arctic_bear_skin"]`). El índice `[0]` selecciona la skin predeterminada o la primera disponible para esa especie. Este enfoque permite una fácil gestión y selección de las diferentes apariencias visuales disponibles para cada animal, contribuyendo a la personalización del juego.