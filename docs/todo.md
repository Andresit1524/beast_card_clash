# BCC: Plan de Mejora del Sistema de Batalla
Este documento detalla los pasos para limpiar la arquitectura de batalla, reducir el acoplamiento y mejorar la legibilidad.

---

## 1. Centralización de Turnos (Autonomía de Estados)
Actualmente `BattleTurn` depende de que `BattleManager` llame a `player_turn_ended.emit()`.

**Acción:** Rediseñar `BattleTurn.start()` para que maneje sus propios eventos:
1. Conectar `battle_world.dice_thrown` -> Ejecutar lógica de resaltado de rocas.
2. Conectar `battle_world.rock_selected` -> Mover jugador y habilitar mano.
3. Conectar `battle_ui.card_selected` -> Registrar jugada y desconectar eventos.

---

## 2. Bus de Eventos Local (Reducción de Señales)
Crear un sistema donde el Manager y los estados puedan escuchar eventos de bajo nivel sin intermediarios redundantes.

**Acción:**
- Implementar un `LocalBus` (o señales directas en el Manager) para eventos como `dice_thrown`, `rock_selected`, `card_selected`.
- Eliminar las señales puente en `BattleWorld.gd` y `BattleUI.gd`.

---

## 3. Desacoplamiento Player -> Hand
El nodo `Player.gd` (3D) no debe conocer a `Hand.gd` (UI).

**Acción:**
- Eliminar `@export var hand: Hand` de `Player.gd`.
- `Player.gd` solo emite `deck_updated`.
- El `BattleManager` escucha `deck_updated` y llama a `battle_ui.set_hand_from_deck()`.

---

## 4. Limpieza de `BattleData`
Mover la responsabilidad de las constantes y eliminar la referencia circular al Manager.

**Acción:**
- Mover constantes compartidas a `GameConstants.gd`.
- Eliminar `@export var manager: BattleManager`.
- Hacer que `BattleData` herede de `Node` o `Resource` puro para almacenamiento de estados (HP, Ranking, Turnos).

---

## 5. Reestructuración de Archivos (Pasos)
Organizar el caos actual de carpetas siguiendo el esquema de `arquitectura_batalla.md`.

1. Crear carpetas `core/`, `world/` y `ui/`.
2. Mover los estados a `core/states/`.
3. Mover `dice/`, `rocks/` y `player/` a `world/components/`.
4. Mover `hand/` y `panels/` a `ui/components/`.
5. Actualizar las rutas en `battle.tscn` (Godot debería hacerlo automáticamente, pero revisar dependencias manuales).
