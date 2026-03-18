# `BattleState`
`BattleState` es una clase fundamental en la arquitectura de estados del juego, diseñada para gestionar la lógica y el flujo específicos relacionados con el sistema de combate. Actúa como una especialización de `BaseState`, lo que la integra dentro de un patrón de máquina de estados (`State Machine`) más amplio que probablemente orquesta las diferentes fases y transiciones del juego, o específicamente de la batalla.

La función principal de `BattleState` es encapsular y proporcionar una interfaz de alto nivel para el `BattleManager`. Este enfoque permite que la lógica de estado se mantenga separada de la implementación detallada de las mecánicas de batalla, promoviendo así la modularidad y la claridad en el código.

El script define una única propiedad clave:

```gdscript
class_name BattleState extends BaseState


## Wrapper para el BattleManager
var manager: BattleManager:
	set(value):
		controlled_node = value
	get:
		return controlled_node
```

La línea `class_name BattleState extends BaseState` declara `BattleState` como una clase globalmente accesible que hereda de `BaseState`. Se infiere que `BaseState` provee una estructura común para todos los estados del juego, incluyendo una forma de referenciar el nodo que cada estado está controlando.

La variable `manager` es de tipo `BattleManager` y sirve como un "wrapper" o envoltorio para una instancia de `BattleManager`. Esta propiedad cuenta con accesores personalizados (`set` y `get`):

*   **`set(value)`**: Cuando se asigna un valor a `manager`, este valor se asigna internamente a `controlled_node`. Esto implica que `controlled_node` es una variable definida en la clase base `BaseState`, utilizada de manera genérica para referenciar el nodo que un estado está manejando. En el contexto de `BattleState`, este nodo genérico se especializa para ser siempre un `BattleManager`.

    ```gdscript
    set(value):
        controlled_node = value
    ```

*   **`get`**: Cuando se accede a la propiedad `manager`, se devuelve el valor almacenado en `controlled_node`. Esto asegura que, al interactuar con `manager`, siempre se obtenga una referencia al `BattleManager` asociado con este estado, beneficiándose de la inferencia de tipo `BattleManager` para todas las operaciones subsiguientes.

    ```gdscript
    get:
        return controlled_node
    ```

Esta configuración permite que `BattleState` actúe como un puente entre la máquina de estados y el `BattleManager` real. De este modo, la máquina de estados puede activar o desactivar `BattleState` según sea necesario, y `BattleState`, a su vez, puede delegar la ejecución de las acciones de batalla al `BattleManager` asociado. Este patrón es robusto para gestionar los cambios de estado durante una partida de "Beast Card Clash", donde la fase de combate es una etapa crucial y compleja.