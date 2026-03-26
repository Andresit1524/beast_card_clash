# `BattleState`
`BattleState` es una clase fundamental en la arquitectura de la máquina de estados del juego, específicamente diseñada para encapsular y gestionar la lógica asociada a la fase de **duelo o combate** (la "batalla" en sí misma). Al heredar de `BaseState`, se integra en un patrón de máquina de estados que permite al juego transicionar y manejar diferentes contextos o modos de juego de manera organizada, como la exploración del mundo abierto o las interacciones de los menús.

Su función principal es orquestar las operaciones que tienen lugar cuando el juego se encuentra en el estado de batalla activo. Esto incluye la gestión de los turnos de los jugadores, la aplicación de las reglas de las cartas, la actualización del estado del juego en respuesta a las acciones de los jugadores y la interacción con la interfaz de usuario específica de la batalla.

La interacción de `BattleState` con el sistema de batalla central se realiza a través de su propiedad `manager`. Esta propiedad, tipada como `BattleManager`, actúa como un *wrapper* o envoltorio para el nodo `BattleManager` que el estado está controlando. La implementación de su *setter* y *getter* asegura que el `BattleManager` asignado sea la misma instancia referenciada por `controlled_node`, una propiedad heredada de `BaseState`. Esta conexión directa y fuertemente tipada permite que `BattleState` acceda de forma segura y eficiente a todos los servicios y datos que ofrece el `BattleManager`, como la lógica de juego, la información de los jugadores y las cartas, sin necesidad de realizar suposiciones sobre el tipo genérico de `controlled_node`.

```gdscript
class_name BattleState extends BaseState

## Wrapper para el BattleManager
var manager: BattleManager:
	set(value):
		controlled_node = value
	get:
		return controlled_node
```

En resumen, `BattleState` es el cerebro operativo cuando los jugadores están enfrascados en un duelo de cartas, sirviendo como un punto de control central para toda la lógica, reglas y eventos que definen el combate. Su diseño como un estado le permite ser activado y desactivado limpiamente por la máquina de estados principal, facilitando la modularidad y el mantenimiento del código.