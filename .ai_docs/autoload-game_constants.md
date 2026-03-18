# `GlobalGameData`
Este script actúa como un repositorio centralizado para las constantes y enumeraciones fundamentales del juego **Beast Card Clash**. Su propósito principal es definir valores clave y tipologías de datos que son utilizados consistentemente a lo largo de todo el proyecto, asegurando coherencia y facilitando la gestión de la información central del juego. Al extender de `Node`, se puede configurar fácilmente como un *Autoload* (Singleton) en Godot, permitiendo que sus definiciones sean accesibles globalmente desde cualquier otro script o nodo del juego sin necesidad de referencias explícitas.

Este archivo consolida definiciones cruciales como el valor máximo de las cartas, los tipos elementales, las identificaciones de los equipos (facultades de la UNAL) y las especies de animales con sus respectivas *skins*.

## Constantes

### `MAX_CARD_VAlUE`
```gdscript
const MAX_CARD_VAlUE := 10
```
Esta constante numérica entera define el valor máximo que puede tener una carta en el juego. Es un umbral importante para la lógica de combate, el balance del juego y la generación de cartas, ya que cualquier mecánica que involucre el poder o la defensa de las cartas debería respetar este límite.

### `TEAMS_MEMBERS`
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
Este diccionario (`Dictionary[Teams, Array]`) está diseñado para almacenar los miembros asociados a cada equipo definido en la enumeración `Teams`. Actualmente, se inicializa con todos los equipos mapeados a un array vacío. Esto sugiere que los miembros de cada equipo serán cargados o asignados dinámicamente en otra parte del juego, posiblemente al inicio de una partida, a través de la configuración del jugador, o mediante un sistema de gestión de datos persistente. Su estructura permite asociar fácilmente un listado de "miembros" (que podrían ser identificadores de personajes, datos de jugadores, etc.) a su equipo correspondiente.

### `SKINS`
```gdscript
const SKINS: Dictionary[Species, PackedStringArray] = {
	Species.BEAR: ["base", "andean", "black", "grizzly", "panda", "polar"],
	Species.CHAMALEON: ["base"],
	Species.CONDOR: ["base"],
	Species.FROG: ["base", "green", "perez"]
}
```
Este diccionario (`Dictionary[Species, PackedStringArray]`) define las *skins* (apariencias visuales) disponibles para cada especie de personaje del juego. La clave del diccionario es un valor de la enumeración `Species`, y su valor asociado es un `PackedStringArray` que contiene los nombres de las *skins* disponibles para esa especie. La primera *skin* en cada array (`"base"`) se considera la apariencia por defecto. Esta constante es crucial para la personalización de los personajes, la carga de recursos gráficos y la representación visual de las cartas en la interfaz de usuario.

## Enumeraciones (Enums)

### `Elements`
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
Esta enumeración define los diferentes tipos elementales presentes en el juego. Estos elementos son fundamentales para las mecánicas de estrategia, ya que los personajes, las cartas y las habilidades pueden tener afinidades o debilidades a ciertos elementos, creando un sistema de "piedra, papel o tijera" o interacciones más complejas. `NONE` se incluye para representar la ausencia de un elemento.

### `Teams`
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
Esta enumeración lista los distintos equipos o facciones que participan en el juego. Los nombres de los equipos están inspirados en las facultades de la Universidad Nacional de Colombia (UNAL), lo que añade un elemento temático y educativo al proyecto. `NO_TEAM` se usa para representar un personaje o entidad que no pertenece a ningún equipo. Estos equipos son centrales para la gestión de partidas multijugador, la asignación de personajes a jugadores y posiblemente para efectos de juego que involucren interacciones entre facciones.

### `Species`
```gdscript
enum Species {
	BEAR,
	CONDOR,
	CHAMALEON,
	FROG
}
```
Esta enumeración define las especies de animales autóctonos de Colombia que sirven como base para los personajes del juego. Cada valor representa una categoría de animal que tendrá sus propias características, habilidades y, como se ve en la constante `SKINS`, sus propias opciones de personalización visual. Es una pieza clave para la identificación y clasificación de los personajes en el juego.