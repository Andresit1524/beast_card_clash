# `PlayerPanel`
Este script, que extiende `PanelContainer`, es responsable de gestionar y visualizar los datos de un jugador dentro de la interfaz de usuario de batalla. Actúa como un componente de UI autónomo que muestra el nombre del jugador, su equipo, su salud actual y la carta que tiene en juego (o una carta genérica si está oculta). Su diseño reactivo permite que las actualizaciones de datos se reflejen automáticamente en la interfaz.

El panel se configura mediante variables `@export` que facilitan su integración y personalización directamente desde el editor de Godot. Estas propiedades, al ser modificadas, desencadenan métodos internos para refrescar la visualización del panel, asegurando que la UI esté siempre sincronizada con el estado del jugador.

## Estructura de las propiedades del panel
El `PlayerPanel` maneja dos grupos principales de información visual:

1.  **Datos del jugador:**
    *   `player_name`: Nombre visible del jugador.
    *   `team`: Equipo al que pertenece el jugador, representado por una enumeración de `GameConstants.Teams`.
    *   `health`: Puntos de vida actuales del jugador, con un rango entre 0 y 5.

2.  **Datos de la carta:**
    *   `element`: Elemento de la carta, representado por una enumeración de `GameConstants.Elements`.
    *   `value`: Valor numérico de la carta, con un rango entre 1 y 10.
    *   `hide_card`: Booleano que determina si la carta debe mostrarse o permanecer oculta (mostrando un *placeholder*).

Para obtener los recursos gráficos, el panel se apoya en dos referencias externas:
*   `cards_list`: Un recurso (`CardsList`) que provee las texturas de las cartas según su elemento y valor.
*   `teams_list`: Un recurso (`TeamsList`) que provee las texturas de los iconos de equipo.

Estas propiedades son accesibles y configurables en el inspector de Godot.

```gdscript
class_name PlayerPanel extends PanelContainer

@export var player_name: String:
	set(value):
		player_name = value
		refresh_panel()
@export var team: GameConstants.Teams:
	set(value):
		team = value
		refresh_panel()
@export_range(0, 5) var health: int:
	set(value):
		health = value
		refresh_panel()

@export var element: GameConstants.Elements:
	set(value):
		element = value
		if not hide_card: update_card()
@export_range(1, 10) var value: int:
	set(val):
		value = val
		if not hide_card: update_card()
@export var hide_card: bool = false:
	set(value):
		if value == hide_card: return
		hide_card = value
		update_card()

@export var cards_list: CardsList
@export var teams_list: TeamsList
```
<p align="center">
    <i>Definición de las propiedades exportadas del panel.</i>
</p>

## Interacción con la interfaz de usuario

El script se encarga de conectar las propiedades internas con los nodos de la UI que las representan visualmente. Esto se logra mediante la asignación de nodos `@onready`, lo que garantiza que las referencias a los controles de UI estén disponibles desde el inicio.

```gdscript
@onready var name_label: Label = $Margin/Contents/PlayerData/Name
@onready var team_texture: TextureRect = $Margin/Contents/PlayerData/Team
@onready var card_texture: TextureRect = $Margin/Contents/Card
@onready var life_bar: ProgressBar = $Margin/Contents/LifeBar
@onready var life_label: RichTextLabel = $Margin/Contents/LifeBar/LifeValue
@onready var base_card_scale := card_texture.scale
```
<p align="center">
    <i>Nodos de UI a los que el script hace referencia, declarados con <code>@onready</code>.</i>
</p>

# Métodos

## Métodos de Godot

### `_ready()`
Este método se ejecuta una vez que el nodo y todos sus hijos han entrado en el árbol de escena. Su función principal es asegurar que el panel se inicialice correctamente con los datos actuales del jugador y de la carta.

*   Llama a `refresh_panel()` para establecer el nombre del jugador, el ícono del equipo y la barra de vida.
*   Llama a `update_card()` para configurar la imagen de la carta, incluyendo su animación inicial.

```gdscript
func _ready():
	refresh_panel()
	update_card()
```
<p align="center">
    <i>Inicialización del panel en <code>_ready()</code>.</i>
</p>

## Otros métodos

### `refresh_panel() -> void`
Este método se encarga de actualizar los elementos de la interfaz de usuario relacionados con los datos generales del jugador. Es invocado automáticamente cada vez que las propiedades `player_name`, `team` o `health` son modificadas a través de sus *setters*.

*   **Actualización de datos básicos:** Establece el texto del `name_label` con el valor de `player_name` (o "Sin nombre" si está vacío) y asigna la textura del equipo (`team_texture`) obteniéndola de `teams_list` usando la propiedad `team`.
*   **Actualización de la barra de vida:** Sincroniza el `value` de `life_bar` con la propiedad `health`. Además, actualiza el `life_label` (un `RichTextLabel`) para mostrar el valor de la vida con un color. El texto será `"[color=white]X[/color]"` si la vida es mayor que 0, y `"[color=red]0[/color]"` si es 0, proporcionando una indicación visual rápida del estado de salud del jugador.

```gdscript
func refresh_panel() -> void:
	if (not name_label or not team_texture or not card_texture): return

	# Actualiza los datos del jugador
	name_label.text = player_name if player_name else "Sin nombre"
	team_texture.texture = teams_list.get_team(team)

	# Actualiza la barra de vida
	var color := "white" if health > 0 else "red"
	life_bar.value = health
	life_label.text = "[color=%s]%s[/color]" % [color, health]
```
<p align="center">
    <i>Lógica de actualización de los datos del jugador y su barra de vida.</i>
</p>

### `update_card() -> void`
Este método gestiona la actualización visual de la carta del jugador, incorporando una animación de "volteo" o "revelación". Es invocado automáticamente cada vez que las propiedades `element`, `value` o `hide_card` son modificadas a través de sus *setters*.

*   **Animación de escala:** Crea un `Tween` que anima la propiedad `scale` de `card_texture`. Primero, la carta se reduce horizontalmente a un ancho de 0 (`Vector2(0, base_card_scale.y)`), simulando un giro. Luego, llama al método `set_card_sprite()` como *callback* en el punto medio de la animación (cuando la carta es invisible). Finalmente, la carta se expande de nuevo a su escala original (`base_card_scale`). Esta secuencia crea un efecto visual de cambio de carta.

```gdscript
func update_card() -> void:
	if not cards_list: return

	# Actualiza el sprite de la carta
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(card_texture, "scale", Vector2(0, base_card_scale.y), 0.1)
	tween.tween_callback(set_card_sprite)
	tween.tween_property(card_texture, "scale", base_card_scale, 0.1)
```
<p align="center">
    <i>Método que orquesta la animación y actualización de la carta.</i>
</p>

### `set_card_sprite() -> void`
Este método es el encargado directo de asignar la textura correcta a `card_texture`. Es invocado como parte de la animación de `update_card()`.

*   **Lógica de asignación de textura:** Si la propiedad `hide_card` es `false`, el método obtiene la textura de la carta de `cards_list` utilizando las propiedades `element` y `value`. Si `hide_card` es `true`, asigna la textura del *placeholder* proporcionada por `cards_list`, ocultando la información de la carta real del jugador.

```gdscript
func set_card_sprite() -> void:
	if not cards_list or not card_texture.texture: return
	card_texture.texture = cards_list.get_card(element, value) if not hide_card else cards_list.placeholder
```
<p align="center">
    <i>Lógica para establecer el sprite de la carta, considerando si debe estar oculta.</i>
</p>