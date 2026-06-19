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
