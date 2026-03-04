# `Globals`
Este script, que extiende `Node`, funciona como un repositorio centralizado para las constantes, enumeraciones y datos estáticos globales del juego **Beast Card Clash**. Al estar diseñado para ser probablemente un *autoload singleton*, asegura que esta información esté accesible de forma consistente desde cualquier parte del proyecto, facilitando la gestión y el mantenimiento de valores clave que definen la estructura y las mecánicas fundamentales del juego.

En línea con la inspiración del proyecto en la biodiversidad colombiana y las facultades de la UNAL, este script define las principales categorías de elementos estratégicos, equipos (facultades), especies de animales autóctonos y sus respectivas personalizaciones visuales.

### Constantes y Enumeraciones Definidas:

*   `MAX_CARD_VAlUE`:
    ```gdscript
    const MAX_CARD_VAlUE := 10
    ```
    Define el valor máximo que puede tener una carta en el juego. Este es un límite superior crucial para la lógica de juego y el balance de las cartas, afectando directamente la estrategia y las habilidades de los jugadores.

*   `Elements`:
    ```gdscript
    enum Elements {
    	NONE,
    	AIR,
    	EARTH,
    	ENERGY,
    	FIRE,
    	WATER
    }
    ```
    Una enumeración que establece los diferentes tipos elementales presentes en el juego. Estos elementos son fundamentales para la mecánica de "estrategia elemental" mencionada en el README, probablemente influyendo en las fortalezas y debilidades de las cartas, así como en las interacciones en combate. `NONE` representa la ausencia de un elemento específico.

*   `Teams`:
    ```gdscript
    enum Teams {
    	NO_TEAM,
    	ACETILES,
    	ADN,
    	INGENIOSOS_ELEMENTALES,
    	PHOTO_AGROS,
    	PLUMA_DORADA,
    	RPC_TEAM,
    	REAL_PINCEL,
    	VA_GAMES,
    	ZOOTECNICOS
    }
    ```
    Una enumeración que define los diferentes equipos o facciones del juego. Los nombres de estos equipos (`ACETILES`, `ADN`, `INGENIOSOS_ELEMENTALES`, etc.) reflejan directamente la inspiración del proyecto en las facultades de la Universidad Nacional de Colombia (UNAL), tal como se describe en el README. `NO_TEAM` es un valor para indicar la ausencia de asignación a un equipo.

*   `TEAMS_MEMBERS`:
    ```gdscript
    const TEAMS_MEMBERS: Dictionary[Teams, Array] = {
    	Teams.NO_TEAM: [],
    	Teams.ACETILES: [],
    	Teams.ADN: [],
    	Teams.INGENIOSOS_ELEMENTALES: [],
    	Teams.PHOTO_AGROS: [],
    	Teams.PLUMA_DORADA: [],
    	Teams.RPC_TEAM: [],
    	Teams.REAL_PINCEL: [],
    	Teams.VA_GAMES: [],
    	Teams.ZOOTECNICOS: []
    }
    ```
    Un diccionario que asocia cada `Team` con una lista (`Array`) de sus miembros. Aunque actualmente se inicializa con arrays vacíos para cada equipo, su propósito es almacenar o referenciar los personajes o unidades que pertenecen a cada facción. Este diccionario provee una estructura para organizar la composición de los equipos del juego.

*   `Species`:
    ```gdscript
    enum Species {
    	BEAR,
    	CONDOR,
    	CHAMALEON,
    	FROG
    }
    ```
    Una enumeración que lista las diferentes especies de animales disponibles en el juego. Estas especies representan los "animales autóctonos" que sirven como base para los personajes de las cartas, fusionando la biodiversidad colombiana con la jugabilidad competitiva.

*   `SKINS`:
    ```gdscript
    const SKINS: Dictionary[Species, PackedStringArray] = {
    	Species.BEAR: ["base", "andean", "black", "grizzly", "panda", "polar"],
    	Species.CHAMALEON: ["base"],
    	Species.CONDOR: ["base"],
    	Species.FROG: ["base", "green", "perez"]
    }
    ```
    Un diccionario que define las distintas apariencias o "skins" disponibles para cada `Species`. Cada especie tiene una `PackedStringArray` que lista los nombres de sus skins, donde el primer elemento ("base") se considera la skin por defecto. Esta constante permite la personalización visual de los personajes animales, añadiendo variedad y reflejando la "personalidad académica" y creativa de las facultades asociadas.