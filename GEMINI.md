# Beast Card Clash - Guía del Agente Gemini
Este archivo proporciona instrucciones y contexto crítico para trabajar en el proyecto **Beast Card Clash (BCC)**.

BCC es un juego de cartas por turnos hecho en Godot 4.6. Inspirado en Card Jitsu Fuego, con temática de fauna colombiana y ambientación en la Universidad Nacional de Colombia. Utiliza una estética 2.5D/3D.

- **Motor:** Godot 4.6 stable mono
- **Lenguaje Principal:** GDScript (C# soportado)
- **Arquitectura:** La recomendada por Godot (basado en herencia, organizado por cercania, convenciones de nombres oficiales)

## Comandos a la mano
- **Ejecutar Proyecto:** `godot --path .` (Asumiendo que `godot` está en el PATH). Si no, pregunta al usuario por la ruta de Godot.
- **Pruebas:** El proyecto usa `addons/` y `assets/utils/` para utilidades, sin un framework integrado para tests.
- **Búsqueda:** Usa siempre `rg` (ripgrep) para buscar en el código.

## Convenciones de Desarrollo
- **Código:** Todo el código (variables, funciones, clases) debe estar en **Inglés**.
- **Documentación/Comentarios:** Deben estar en **Español**.
- **Estilo de Código:** Sigue la convencion oficial de GDScript o C# para Godot dependiendo del caso. Para GDScript:
	- `snake_case`: Variables, funciones, archivos (`.gd`, `.tscn`).
	- `PascalCase`: Clases (`class_name` y `class`) y tipos
	- `SCREAMING_SNAKE_CASE`: Constantes y Enums.
- **Nodos:** Los nombres de los nodos en el árbol de escenas deben usar `PascalCase`.
- **Archivos y carpetas:** `snake_case`

## Estructura del Proyecto
- `assets/`: Recursos del proyecto
	- `battle/`: Núcleo del sistema de combate (Mediador, Estados, UI, Mundo).
	- `cards/`: Definición de cartas y recursos relacionados.
- `autoload/`: Singletons globales para gestión de escenas, música, flags y stats del jugador.
- `addons/`: Plugins de terceros (`dialogue_manager`, `vector_display_2d`).
- `docs/`: Documentación técnica rápida (normalmente esta se migra a otro repo)

## Autoloads Críticos
1. `SceneManager`: Cambio de escenas centralizado.
2. `PlayerStats`: Persistencia temporal de la sesión del jugador.
3. `DialogueManager`: Manejo de diálogos (Plugin).
4. `FlagsManager`: Gestión de estados de progreso.

## Consideraciones de Seguridad y Estilo
- **Mimetismo:** Antes de implementar, revisa el contexto y estilo del codigo y de ser necesario, otros archivos. Actúa con base en lo que ves.
- **Señales:** Sigue el patrón de conexión en `_ready()` o vía inspector, priorizando el desacoplamiento y orden.
- **Rutas:** Usa `uid://` preferiblemente para recursos de Godot para evitar problemas con cambios de ruta.

---

*Este archivo es una guía viva para el agente Gemini. Actualízalo si descubres nuevos patrones o herramientas.*
