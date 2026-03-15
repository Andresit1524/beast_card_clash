# `TeamsList`
`TeamsList` es una clase auxiliar definida como un `Resource`, lo que le permite ser creada y guardada como un archivo `.tres` en el editor de Godot. Su función principal es centralizar y gestionar los íconos visuales (`Texture2D`) asociados a cada uno de los equipos presentes en el juego **Beast Card Clash**.

Este recurso actúa como un diccionario configurable, donde cada equipo, identificado por un valor del enumerador `GameConstants.Teams`, tiene asignado un `Texture2D` correspondiente a su ícono. Esto facilita el acceso uniforme a los assets visuales de los equipos desde cualquier parte del proyecto, asegurando consistencia y simplificando la gestión de recursos. Al ser un `Resource`, puede ser exportado y editado directamente desde el editor de Godot, permitiendo a los diseñadores de arte o programadores asignar fácilmente los íconos a cada equipo sin modificar el código.

```gdscript
class_name TeamsList extends Resource
```
La declaración `class_name TeamsList extends Resource` establece que esta clase extiende `Resource` y puede ser referenciada por su nombre `TeamsList` en todo el proyecto.

---

# Métodos

## Otros métodos

### `get_team(team: GameConstants.Teams) -> Texture2D`
Este método público proporciona una interfaz sencilla para obtener el ícono (`Texture2D`) de un equipo específico. Recibe como argumento un valor del enumerador `GameConstants.Teams` que identifica al equipo.

Internamente, el método utiliza el argumento `team` como clave para buscar y retornar el `Texture2D` correspondiente dentro del diccionario `teams_icons`.

```gdscript
func get_team(team: GameConstants.Teams) -> Texture2D:
	return teams_icons[team]
```
> **Nota:** Se asume que el `GameConstants.Teams` es un enumerador que está definido en el script `GameConstants.gd` o similar, y que sus valores corresponden a las claves utilizadas en el diccionario `teams_icons`. El uso de esta estructura garantiza que solo se puedan solicitar íconos para equipos válidos definidos en las constantes del juego.

### Propiedades Exportadas

`TeamsList` expone una única propiedad exportada que es fundamental para su funcionamiento:

#### `teams_icons: Dictionary`
Este diccionario almacena los mapeos entre los enumeradores de equipo y sus respectivos íconos `Texture2D`. Al estar marcado con `@export`, este diccionario es visible y editable directamente en el Inspector de Godot cuando se selecciona una instancia de `TeamsList` (por ejemplo, un archivo `.tres` que usa esta clase).

```gdscript
@export var teams_icons: Dictionary = {
	GameConstants.Teams.NO_TEAM: null,
	GameConstants.Teams.ACETILES: null,
	GameConstants.Teams.ADN: null,
	GameConstants.Teams.INGENIOSOS_ELEMENTALES: null,
	GameConstants.Teams.PHOTO_AGROS: null,
	GameConstants.Teams.PLUMA_DORADA: null,
	GameConstants.Teams.RPC_TEAM: null,
	GameConstants.Teams.REAL_PINCEL: null,
	GameConstants.Teams.VA_GAMES: null,
	GameConstants.Teams.ZOOTECNICOS: null,
}
```
La inicialización del diccionario incluye todas las entradas posibles del enumerador `GameConstants.Teams` (o al menos las que se esperan que tengan un ícono), con valores `null` por defecto. Esto guía a los desarrolladores a asignar las texturas correctas en el editor para cada equipo.

---

### Interacción con otros componentes del proyecto

`TeamsList` es un componente pasivo que sirve como fuente de datos. Su uso principal en el proyecto sería:

- **Configuración de la UI:** Cualquier elemento de la interfaz de usuario (HUD, pantalla de selección de equipos, etc.) que necesite mostrar el ícono de un equipo específico obtendrá la textura de este recurso. Por ejemplo, un `TextureRect` podría configurarse para mostrar `TeamsList.get_team(some_team_enum_value)`.
- **Integración de GameConstants:** La dependencia de `GameConstants.Teams` sugiere una estructura de proyecto donde `GameConstants` centraliza las definiciones importantes del juego, asegurando que los identificadores de equipo sean consistentes en todo el código.
- **Flujo de Recursos:** Se espera que exista al menos una instancia de `TeamsList` guardada como un archivo `.tres` en el proyecto, la cual será cargada y referenciada por los scripts que necesiten acceder a los íconos de los equipos. Esto permite una fácil modificación de los assets sin cambios en el código.