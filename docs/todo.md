# BCC: Plan de Mejora del Sistema de Batalla

Este documento detalla los pasos para limpiar la arquitectura de batalla, reducir el acoplamiento y mejorar la legibilidad.

## Revisión inicial

### Centralización de Turnos (Autonomía de Estados)
Actualmente `BattleTurn` depende de que `BattleManager` llame a `player_turn_ended.emit()`.
- [X] ~~Rediseñar `BattleTurn.start()` para que maneje sus propios eventos~~
- [ ] Conectar `battle_world.dice_thrown` -> Ejecutar lógica de resaltado de rocas
- [ ] Conectar `battle_world.rock_selected` -> Mover jugador y habilitar mano
- [ ] Conectar `battle_ui.card_selected` -> Registrar jugada y desconectar eventos

### Bus de Eventos Local (Reducción de Señales)
Crear un sistema donde el Manager y los estados puedan escuchar eventos de bajo nivel sin intermediarios redundantes.
- [ ] Implementar un `LocalBus` (o señales directas en el Manager) para eventos como `dice_thrown`, `rock_selected`, `card_selected`
- [ ] Eliminar las señales puente en `BattleWorld.gd` y `BattleUI.gd`

### Reestructuración de Archivos (Pasos)
Organizar el caos actual de carpetas siguiendo el esquema de `arquitectura_batalla.md`.
- [ ] Crear carpetas `core/`, `world/` y `ui/`
- [ ] Mover los estados a `core/states/`
- [ ] Mover `dice/`, `rocks/` y `player/` a `world/components/`
- [ ] Mover `hand/` y `panels/` a `ui/components/`
- [ ] Actualizar las rutas en `battle.tscn` (Godot debería hacerlo automáticamente, pero revisar dependencias manuales)

### Auditoría de Sobreingeniería y Limpieza de Código (Ponytail Audit)
Actualmente existen abstracciones excesivas y código obsoleto que complican el mantenimiento del proyecto.
- [ ] Reemplazar `AutoloadResource`: Eliminar la jerarquía `AutoloadResource` y sus subclases (`Flags`, `Playlist`, `Scenes`). Reemplazarlas por recursos (`Resource`) nativos con variables exportadas tipadas para beneficiarse de la validación estática del editor.
- [X] ~~Simplificar Herencia de `Player`: Cambiar la clase base de `Player` de `CharacterBody3D` a `Node3D` ya que los movimientos se realizan mediante `Tween` y no requieren simulación física 3D.~~
- [X] ~~Eliminar Código Muerto: Métodos sin uso `Player.add_card()` y `Player.remove_card()`.~~
- [ ] Eliminar Código Muerto: Método sin uso `MusicManager.switch_music_playing()`.
- [ ] Simplificar Comprobaciones Redundantes: En `assets/utils/utilities.gd`, remover `if color is Color:` en `print_color()` dado que el parámetro ya está tipado estáticamente.

### Mejoras ante la sobreingeniería
Aspectos de calidad del código, estilo o mantenibilidad que deben abordarse.
- [ ] Varios archivos — Declaración de tipos dinámicos o ausentes en callbacks, lambdas de filtros (ej. `func(p)` en `battle_data.gd`) y retornos de funciones (ej. `func get_rocks()` en `battle_manager.gd`) — Solución sugerida: Implementar tipado fuerte estático completo en GDScript 2 (ej. `func(p: Player)`, `func get_rocks() -> Array[Rock]`).
- [X] ~~player.gd — Uso de una lambda anónima redundante `func(): moved.emit()` en el callback del Tween — Solución sugerida: Pasar directamente la señal como Callable: `tween.tween_callback(moved.emit)`.~~
- [X] ~~card.gd — Uso de una lambda anónima redundante `func(): set_physics_process(true)` en el callback del Tween — Solución sugerida: Reemplazar por `tween.tween_callback(set_physics_process.bind(true))`.~~
- [ ] music_manager.gd — Parámetro `on` sin tipo explícito en la firma del método `switch_music_playing(on = null)` — Solución sugerida: Declararlo con un tipo estático o Variant si puede ser nulo (`on: Variant = null`), o eliminar la función completa al tratarse de código muerto.

## Más tareas
- [ ] Clase interna `Snapshot` en `BattleData` . Usar un diccionario nativo `{"name": name, "team": team}`. [assets/battle/battle_data.gd ]
- [ ] Función `Card.set_properties()` . Asignar propiedades directamente sobre la instancia de `Card`. [assets/cards/card.gd ]
- [ ] Métodos `get_element()` en `ElementsList` y `get_team()` en `TeamsList`. Acceder directamente a los diccionarios/arrays expuestos en el inspector. [ assets/elements/elements_list.gd , assets/teams/teams_list.gd ]
- [ ] Función `Utilities.get_enum_name()` . Usar `EnumName.keys()[value]` nativo de GDScript. [assets/utils/utilities.gd ]
- [ ] Clases `Constants` y `Utilities` heredando de Node . Eliminar `extends Node` para que hereden implícitamente de `RefCounted` . [ assets/utils/constants.gd , assets/utils/utilities.gd ]
