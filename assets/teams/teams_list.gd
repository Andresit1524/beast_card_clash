## Una clase auxiliar para almacenar los íconos de los equipos del juego. Accede a ellas por su
## elemento y valor usando [code]get_team()[/code]
class_name TeamsList extends Resource


@export var teams_icons: Dictionary = {
	Constants.Teams.NO_TEAM: null,
	Constants.Teams.ACETILES: null,
	Constants.Teams.ADN: null,
	Constants.Teams.INGENIOSOS_ELEMENTALES: null,
	Constants.Teams.PHOTO_AGROS: null,
	Constants.Teams.PLUMA_DORADA: null,
	Constants.Teams.RPC_TEAM: null,
	Constants.Teams.REAL_PINCEL: null,
	Constants.Teams.VA_GAMES: null,
	Constants.Teams.ZOOTECNICOS: null,
}


## Obtiene el ícono de un equipo
func get_team(team: Constants.Teams) -> Texture2D:
	return teams_icons[team]
