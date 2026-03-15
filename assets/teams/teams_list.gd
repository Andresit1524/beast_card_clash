## Una clase auxiliar para almacenar los íconos de los equipos del juego. Accede a ellas por su
## elemento y valor usando [code]get_team()[/code]
class_name TeamsList extends Resource


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


## Obtiene el ícono de un equipo
func get_team(team: GameConstants.Teams) -> Texture2D:
	return teams_icons[team]
