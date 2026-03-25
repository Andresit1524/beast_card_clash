extends Node

## Constantes del juego
const MAX_CARD_VAlUE := 10


## Lista de elementos
enum Elements {NONE, AIR, EARTH, ENERGY, FIRE, WATER}


## Colores asociados a cada elemento
const ELEMENTS_COLORS = {
	Elements.NONE: Color.GRAY,
	Elements.AIR: Color.SKY_BLUE,
	Elements.EARTH: Color.YELLOW_GREEN,
	Elements.ENERGY: Color.YELLOW,
	Elements.FIRE: Color.ORANGE_RED,
	Elements.WATER: Color.STEEL_BLUE
}


## Lista de equipos
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


## Miembros de los equipos
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


## Especies disponibles y las skins disponibles para cada uno
enum Species {BEAR, CONDOR, CHAMALEON, FROG}


## Skins disponibles para cada especie. Base (la skin por defecto) va de primero
const SKINS: Dictionary[Species, PackedStringArray] = {
	Species.BEAR: ["base", "andean", "black", "grizzly", "panda", "polar"],
	Species.CHAMALEON: ["base"],
	Species.CONDOR: ["base"],
	Species.FROG: ["base", "green", "perez"]
}
