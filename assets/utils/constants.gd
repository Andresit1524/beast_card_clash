## Almacena las constantes del juego para su consulta a lo largo del proyecto
class_name Constants


## Tiempo de espera en acciones de batalla
const BATTLE_WAIT_TIME := 2.0

## Cantidad de cartas iniciales en las barajas
const INITIAL_CARDS := 9

## Valor máximo de las cartas
const MAX_CARD_VALUE := 10

## Cantidad máxima de jugadores
const MAX_PLAYERS := 4

## Salud de los jugadores
const MAX_HEALTH := 5

## Nombres para los jugadores
const NAMES := [
	"Ana La Rana",
	"Andrew",
	"Arturo",
	"Barry",
	"Bartolome",
	"Beth",
	"Bianca",
	"Búho Sensei - Nacho",
	"Carlos Jimenez",
	"Carmen",
	"Chepe García",
	"Cristal",
	"Don Poncho",
	"Dorothy",
	"Doru",
	"Eliel Picoalto",
	"Fabio Aguilar",
	"Guacharaco",
	"Juan Orca",
	"Keneth",
	"Manchas",
	"Maria",
	"Marjane",
	"Matt Cougar",
	"Mr Bear",
	"Nairo “El Andino”",
	"Osorio P",
	"Ramón",
	"Teddy",
	"Thiago",
	"Thomas",
	"Titi",
	"Walter Mendoza",
	"Wolfy",
	"Zarah",
]


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


## Especies disponibles y las skins disponibles para cada uno
# ! Sin implementar
enum Species {BEAR, CONDOR, CHAMALEON, FROG}


## Elige un elemento al azar que no sea el nulo
static func get_random_valid_element() -> Elements:
	return randi_range(1, Elements.size() - 1) as Elements
