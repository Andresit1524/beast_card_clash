# 🐾 Beast Card Clash - Guía del Agente Gemini
Este archivo proporciona instrucciones y contexto crítico para trabajar en el proyecto **Beast Card Clash (BCC)**, un juego de cartas por turnos en Godot 4.6.

## 📌 Resumen del Proyecto
BCC es un juego inspirado en Card Jitsu Fuego, con temática de fauna colombiana y ambientación en la Universidad Nacional de Colombia. Utiliza una estética 2.5D/3D.

- **Motor:** Godot 4.6.1.stable.mono
- **Lenguaje Principal:** GDScript (C# soportado)
- **Arquitectura:** La recomendada por Godot (basado en herencia, organizado por cercania, convenciones de nombres oficiales)

## 🛠️ Comandos Clave (CLI)
- **Ejecutar Proyecto:** `godot --path .` (Asumiendo que `godot` está en el PATH).
- **Pruebas:** El proyecto usa `addons/` y `assets/utils/` para utilidades, sin un framework integrado para tests.
- **Búsqueda:** Usa siempre `rg` (ripgrep) para buscar en el código.
- **Scripts de Soporte:** Usa `py` para ejecutar herramientas en `.doc_maker/` en lugar de `python`.

## 📏 Convenciones de Desarrollo

### Nomenclatura e Idioma
- **Código:** Todo el código (variables, funciones, clases) debe estar en **Inglés**.
- **Documentación/Comentarios:** Deben estar en **Español**.
- **Estilo de Código:** Sigue la convencion de GDScript o C# dependiendo del lenguaje:
	- `snake_case`: Variables, funciones, archivos (`.gd`, `.tscn`).
	- `PascalCase`: Clases (`class_name` y `class`) y tipos
	- `SCREAMING_SNAKE_CASE`: Constantes y Enums.
- **Nodos:** Los nombres de los nodos en el árbol de escenas deben usar `PascalCase`.

### Arquitectura de Batalla
- **BattleManager (`assets/battle/battle_manager.gd`):** Actúa como Mediador. Orquesta la comunicación entre la UI (`BattleUI`), el mundo 3D (`BattleWorld`) y los datos (`BattleData`).
- **Estados:** Los estados de batalla heredan de `BattleState` y son hijos de `BattleManager`. Se encuentran en `assets/battle/states/`.
- **Sincronía:** Se prefiere el uso de `await` para esperar a que terminen las animaciones (Tweens) antes de proceder con la lógica de juego.

## 📂 Estructura del Proyecto
- `assets/`: Recursos del proyecto
- `assets/battle/`: Núcleo del sistema de combate (Mediador, Estados, UI, Mundo).
- `assets/cards/`: Definición de cartas y recursos relacionados.
- `autoload/`: Singletons globales para gestión de escenas, música, flags y stats del jugador.
- `.docs/`: Documentación técnica detallada (Arquitectura, Todo, Changelog).
- `.ai_docs/`: Documentación generada automáticamente por IA.
- `addons/`: Plugins de terceros (`dialogue_manager`, `vector_display_2d`).

## 🧩 Autoloads Críticos
1. `SceneManager`: Cambio de escenas centralizado.
2. `PlayerStats`: Persistencia temporal de la sesión del jugador.
3. `DialogueManager`: Manejo de diálogos (Plugin).
4. `FlagsManager`: Gestión de estados de progreso.

## ⚠️ Consideraciones de Seguridad y Estilo
- **Mimetismo:** Antes de implementar, revisa `assets/utils/utilities.gd` para usar funciones de ayuda existentes.
- **Señales:** Sigue el patrón de conexión en `_ready()` o vía inspector, priorizando el desacoplamiento mediante el `BattleManager`.
- **Rutas:** Usa `uid://` preferiblemente para recursos de Godot 4 para evitar problemas con cambios de ruta.

---

*Este archivo es una guía viva para el agente Gemini. Actualízalo si descubres nuevos patrones o herramientas.*
