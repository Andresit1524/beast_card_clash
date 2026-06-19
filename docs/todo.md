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
- [X] Eliminar Código Muerto: Método sin uso `MusicManager.switch_music_playing()`.
- [X] Simplificar Comprobaciones Redundantes: En `assets/utils/utilities.gd`, remover `if color is Color:` en `print_color()` dado que el parámetro ya está tipado estáticamente.

## Más tareas
- [ ] Clase interna `Snapshot` en `BattleData` . Usar un diccionario nativo `{"name": name, "team": team}`. [assets/battle/battle_data.gd ]
- [X] Función `Card.set_properties()` . Asignar propiedades directamente sobre la instancia de `Card`. [assets/cards/card.gd ]
- [X] Función `Utilities.get_enum_name()` . Usar `EnumName.keys()[value]` nativo de GDScript. [assets/utils/utilities.gd ]
- [X] Clases `Constants` y `Utilities` heredando de Node . Eliminar `extends Node` para que hereden implícitamente de `RefCounted` . [ assets/utils/constants.gd , assets/utils/utilities.gd ]
