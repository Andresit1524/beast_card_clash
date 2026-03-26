# `BattleStart`
`BattleStart` es una clase que representa un estado dentro de la máquina de estados del sistema de combate principal del juego `Beast Card Clash`. Hereda directamente de `BattleState`, lo que la integra en el flujo general de la lógica de batalla. Su función principal es gestionar todas las configuraciones y preparaciones iniciales necesarias para que un duelo de cartas pueda comenzar. Esto incluye la orquestación de la música, la configuración de los participantes (jugador y bots), la interfaz de usuario específica de la batalla y el entorno de juego. Una vez que todas estas configuraciones se han completado, `BattleStart` cede el control al estado de juego apropiado para iniciar el primer turno de la batalla.

# Métodos

## Otros métodos

### `start() -> void`
El método `start()` se invoca automáticamente cuando la máquina de estados de batalla transiciona a este estado (`BattleStart`). Este método es el punto de entrada para toda la lógica de inicialización de la batalla y se encarga de asegurar que todos los componentes estén debidamente configurados antes de que la acción comience.

A continuación, se detalla el flujo de ejecución de este método:

```gdscript
func start() -> void:
	MusicManager.play_music("battle")

	manager.setup_player()
	manager.setup_bots()
	manager.setup_ui()
	manager.setup_world()

	# Delega el turno al jugador que corresponda
	to_state.emit(BattleLoop if manager.current_turn.is_bot else BattleTurn)
```

1.  **Reproducción de música:**
    ```gdscript
    	MusicManager.play_music("battle")
    ```
    Esta línea es responsable de iniciar la reproducción de la música de fondo específica para las batallas. Se asume que `MusicManager` es un singleton o un nodo accesible globalmente que gestiona la lógica de audio del juego, cargando y reproduciendo la pista identificada con el nombre "battle".

2.  **Configuración de componentes de batalla:**
    ```gdscript
    	manager.setup_player()
    	manager.setup_bots()
    	manager.setup_ui()
    	manager.setup_world()
    ```
    Estas cuatro llamadas a métodos en la instancia `manager` son cruciales para preparar el ecosistema de la batalla. El objeto `manager` actúa como un orquestador central que coordina los diferentes aspectos del juego:
    *   `manager.setup_player()`: Inicializa o configura al jugador principal, incluyendo la carga de su mazo de cartas, sus puntos de vida y otros atributos relevantes para el combate.
    *   `manager.setup_bots()`: Prepara a los oponentes controlados por la inteligencia artificial (IA). Esto implica asignarles sus respectivos mazos, establecer sus atributos iniciales y cualquier otra configuración necesaria para su lógica.
    *   `manager.setup_ui()`: Configura y muestra los elementos de la interfaz de usuario (UI) específicos para la batalla, como el HUD (Heads-Up Display) que muestra la mano de cartas del jugador, contadores de turnos, barras de vida, etc.
    *   `manager.setup_world()`: Prepara el escenario o entorno de juego donde se llevará a cabo la batalla. Esto puede incluir la carga de modelos 3D o 2.5D, la configuración de cámaras, iluminación y otros elementos visuales interactivos.

3.  **Transición al siguiente estado de batalla:**
    ```gdscript
    	to_state.emit(BattleLoop if manager.current_turn.is_bot else BattleTurn)
    ```
    Después de que todas las configuraciones iniciales se han completado, `BattleStart` emite la señal `to_state`. Esta señal es el mecanismo estándar para que la máquina de estados de batalla transicione a un nuevo estado, delegando el control del flujo del juego. El estado al que se transiciona se determina dinámicamente según la lógica del primer turno:
    *   Si `manager.current_turn.is_bot` es `true`, lo que indica que el bot tiene el primer turno, la señal emite la clase `BattleLoop`. Este estado es probable que gestione la lógica para los turnos de los oponentes de IA.
    *   Si `manager.current_turn.is_bot` es `false`, lo que significa que el jugador humano tiene el primer turno, la señal emite la clase `BattleTurn`. Este estado probablemente se encarga de la lógica específica para el turno del jugador.

    Tanto `BattleLoop` como `BattleTurn` se espera que sean también clases que extienden `BattleState`, continuando el ciclo de la máquina de estados de combate. Esta decisión condicional garantiza que la batalla siempre comience con el participante correcto, alineándose con las reglas del juego o la configuración inicial establecida por el `manager`.