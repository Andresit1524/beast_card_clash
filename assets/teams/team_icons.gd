## Almacena los íconos de los equipos del juego
class_name TeamIcons


const ICONS_PATH := "res://assets/teams/sprites"
const ICONS: Dictionary[Constants.Teams, CompressedTexture2D] = {
	Constants.Teams.NO_TEAM: preload("%s/character.png" % ICONS_PATH),
	Constants.Teams.ACETILES: preload("%s/acetiles.png" % ICONS_PATH),
	Constants.Teams.ADN: preload("%s/adn.png" % ICONS_PATH),
	Constants.Teams.INGENIOSOS_ELEMENTALES: preload("%s/ingeniosos_elementales.png" % ICONS_PATH),
	Constants.Teams.PHOTO_AGROS: preload("%s/photo_agros.png" % ICONS_PATH),
	Constants.Teams.PLUMA_DORADA: preload("%s/pluma_dorada.png" % ICONS_PATH),
	Constants.Teams.RPC_TEAM: preload("%s/rcp_team.png" % ICONS_PATH),
	Constants.Teams.REAL_PINCEL: preload("%s/real_pincel.png" % ICONS_PATH),
	Constants.Teams.VA_GAMES: preload("%s/va_games.png" % ICONS_PATH),
	Constants.Teams.ZOOTECNICOS: preload("%s/zootecnicos.png" % ICONS_PATH),
}


## Obtiene el ícono de un equipo
static func get_team(team: Constants.Teams) -> Texture2D:
	return ICONS[team]
