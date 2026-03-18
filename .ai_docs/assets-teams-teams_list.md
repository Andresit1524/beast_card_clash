# `TeamsList`
`TeamsList` es una clase auxiliar que extiende `Resource`, diseñada para centralizar y gestionar los íconos visuales asociados a los distintos equipos o facciones presentes en el juego **Beast Card Clash**. Su propósito principal es mapear cada identificador de equipo, definido por el enumerador `GameConstants.Teams`, a una `Texture2D` correspondiente, que representa el logo o ícono de dicho equipo.

Al ser un `Resource`, permite que una instancia de `TeamsList` sea creada y configurada directamente en el editor de Godot, guardándose como un archivo `.tres` o `.res`. Esto facilita la gestión de activos visuales relacionados con los equipos de una manera modular y re utilizable, permitiendo a los diseñadores y programadores asignar los íconos a cada equipo de forma visual y sin necesidad de modificar el código directamente.

La clase expone un diccionario `teams_icons` para su configuración en el editor, donde se establecen las asociaciones entre los equipos y sus respectivos íconos. Posteriormente, se proporciona un método para recuperar estos íconos de forma sencilla y tipada.

```gdscript
class_name TeamsList extends Resource
```

# Métodos

## Otros métodos

### `get_team(team: GameConstants.Teams) -> Texture2D`
Este método es la interfaz principal para obtener los íconos de los equipos. Recibe como argumento un valor del enumerador `GameConstants.Teams` y devuelve la `Texture2D` asociada a ese equipo.

El método accede directamente al diccionario `teams_icons` utilizando el argumento `team` como clave. Es fundamental que el valor de `team` sea una clave existente en el diccionario `teams_icons` para evitar errores de tipo "Key Not Found".

```gdscript
## Obtiene el ícono de un equipo
func get_team(team: GameConstants.Teams) -> Texture2D:
	return teams_icons[team]
```

La estructura del diccionario `teams_icons` se inicializa con todos los equipos definidos en `GameConstants.Teams`, asegurando que haya un espacio predefinido para cada ícono:

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

Este diseño permite que cualquier componente del juego que necesite mostrar el ícono de un equipo específico pueda hacerlo de forma consistente, simplemente llamando a `get_team()` con el identificador del equipo deseado.