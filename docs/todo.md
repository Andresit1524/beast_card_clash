# BCC: Plan de Mejora del Sistema de Batalla

Este documento detalla los pasos para limpiar la arquitectura de batalla, reducir el acoplamiento y mejorar la legibilidad.

## 1. Centralización de Turnos (Autonomía de Estados)
Actualmente `BattleTurn` depende de que `BattleManager` llame a `player_turn_ended.emit()`.
- [X] ~~Rediseñar `BattleTurn.start()` para que maneje sus propios eventos~~
- [ ] Conectar `battle_world.dice_thrown` -> Ejecutar lógica de resaltado de rocas
- [ ] Conectar `battle_world.rock_selected` -> Mover jugador y habilitar mano
- [ ] Conectar `battle_ui.card_selected` -> Registrar jugada y desconectar eventos

## 2. Bus de Eventos Local (Reducción de Señales)
Crear un sistema donde el Manager y los estados puedan escuchar eventos de bajo nivel sin intermediarios redundantes.
- [ ] Implementar un `LocalBus` (o señales directas en el Manager) para eventos como `dice_thrown`, `rock_selected`, `card_selected`
- [ ] Eliminar las señales puente en `BattleWorld.gd` y `BattleUI.gd`

## 3. Desacoplamiento Player -> Hand
El nodo `Player.gd` (3D) no debe conocer a `Hand.gd` (UI).
- [X] ~~Eliminar `@export var hand: Hand` de `Player.gd`~~
- [X] ~~Emitir únicamente `deck_updated` desde `Player.gd`~~
- [X] ~~Hacer que `BattleManager` escuche `deck_updated` y llame a `battle_ui.set_hand_from_deck()`~~

## 4. Limpieza de BattleData
Mover la responsabilidad de las constantes y eliminar la referencia circular al Manager.
- [ ] Mover constantes compartidas a `GameConstants.gd`
- [ ] Eliminar `@export var manager: BattleManager`
- [ ] Hacer que `BattleData` herede de `Node` o `Resource` puro para almacenamiento de estados (HP, Ranking, Turnos)

## 5. Reestructuración de Archivos (Pasos)
Organizar el caos actual de carpetas siguiendo el esquema de `arquitectura_batalla.md`.
- [ ] Crear carpetas `core/`, `world/` y `ui/`
- [ ] Mover los estados a `core/states/`
- [ ] Mover `dice/`, `rocks/` y `player/` a `world/components/`
- [ ] Mover `hand/` y `panels/` a `ui/components/`
- [ ] Actualizar las rutas en `battle.tscn` (Godot debería hacerlo automáticamente, pero revisar dependencias manuales)

## 6. Auditoría de Sobreingeniería y Limpieza de Código (Ponytail Audit)
Actualmente existen abstracciones excesivas y código obsoleto que complican el mantenimiento del proyecto.
- [ ] Reemplazar `AutoloadResource`: Eliminar la jerarquía `AutoloadResource` y sus subclases (`Flags`, `Playlist`, `Scenes`). Reemplazarlas por recursos (`Resource`) nativos con variables exportadas tipadas para beneficiarse de la validación estática del editor.
- [X] ~~Simplificar Herencia de `Player`: Cambiar la clase base de `Player` de `CharacterBody3D` a `Node3D` ya que los movimientos se realizan mediante `Tween` y no requieren simulación física 3D.~~
- [X] ~~Eliminar Código Muerto: Métodos sin uso `Player.add_card()` y `Player.remove_card()`.~~
- [ ] Eliminar Código Muerto: Método sin uso `MusicManager.switch_music_playing()`.
- [ ] Simplificar Comprobaciones Redundantes: En `assets/utils/utilities.gd`, remover `if color is Color:` en `print_color()` dado que el parámetro ya está tipado estáticamente.

## 7. Ajustes de Reglas de Combate y Lógica de Árbitro
La lógica de resolución de batallas tiene comportamientos inconsistentes en empates.
- [X] Corregir Resolución de Empates en `BattleReferee`: Modificar la función `_compare_players` en `referee.gd`. Actualmente, ante elementos e iguales valores, devuelve `-1` otorgándole la victoria al segundo jugador por defecto. Debe retornar `0` e implementar una mecánica de desempate real (como una ronda extra o daño nulo).
- [X] ~~Evitar Referencias de UI Bloqueadas en el Panel de Jugador: En `PlayerPanel.gd`, corregir la función `set_card_sprite` que tiene el chequeo `not card_texture.texture` para permitir la asignación correcta cuando el sprite de la textura inicial es nulo.~~

## 8. Revisión de Código - Beast Card Clash (Proyecto General)

### Crítico
Problemas que causarán errores, bloqueos o problemas de rendimiento significativos.
- [X] referee.gd — La comparación de jugadores en `_compare_players()` otorga la victoria por defecto al segundo jugador si hay empate en elementos y valores al retornar `-1` — Solución sugerida: Retornar `0` para indicar un empate real y resolver el flujo con daño nulo o ronda de desempate.
- [X] ~~player_panel.gd — El método `set_card_sprite()` valida `not card_texture.texture` antes de asignar la textura de la carta, bloqueando la primera asignación si el sprite en el inspector empieza siendo nulo — Solución sugerida: Retirar la comprobación `not card_texture.texture` de la línea.~~
- [X] ~~player.gd — `Player` hereda de `CharacterBody3D` sin hacer uso de físicas de colisión ni funciones cinemáticas 3D nativas (movimientos manuales por Tween) — Solución sugerida: Heredar directamente de `Node3D` para reducir el overhead en el motor de físicas de Godot.~~

### Mejoras
Aspectos de calidad del código, estilo o mantenibilidad que deben abordarse.
- [ ] Varios archivos — Declaración de tipos dinámicos o ausentes en callbacks, lambdas de filtros (ej. `func(p)` en `battle_data.gd`) y retornos de funciones (ej. `func get_rocks()` en `battle_manager.gd`) — Solución sugerida: Implementar tipado fuerte estático completo en GDScript 2 (ej. `func(p: Player)`, `func get_rocks() -> Array[Rock]`).
- [X] ~~player.gd — Uso de una lambda anónima redundante `func(): moved.emit()` en el callback del Tween — Solución sugerida: Pasar directamente la señal como Callable: `tween.tween_callback(moved.emit)`.~~
- [X] ~~card.gd — Uso de una lambda anónima redundante `func(): set_physics_process(true)` en el callback del Tween — Solución sugerida: Reemplazar por `tween.tween_callback(set_physics_process.bind(true))`.~~
- [ ] music_manager.gd — Parámetro `on` sin tipo explícito en la firma del método `switch_music_playing(on = null)` — Solución sugerida: Declararlo con un tipo estático o Variant si puede ser nulo (`on: Variant = null`), o eliminar la función completa al tratarse de código muerto.
