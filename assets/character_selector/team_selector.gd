extends Control

@export var teams_button_group: ButtonGroup
@export var line_edit_node: LineEdit

var current_team: int = -1

# El grupo de botones tiene como finalidad para sus botones miembros:
#
# - Tener comportamiento de Radio Button (solo seleccionar uno a la vez)
# - Centralizar las señales como ves abajo
func _ready():
    teams_button_group.pressed.connect(set_team)

## Vuelve al selector de aspectos con el botón de volver
func _on_back_button_pressed() -> void:
    SceneManager.change_to_scene("skin_selector")

## Establece el equipo del jugador dependiendo del botón pulsado en el selector de equipo
func set_team(team_node: BaseButton):
    # VA-Games no es equipo elegible, ergo, no aparece. No lo añadas
    match team_node.get_parent().name:
        "NoTeam":
            current_team = GameConstants.Teams.NO_TEAM
        "Acetiles":
            current_team = GameConstants.Teams.ACETILES
        "ADN":
            current_team = GameConstants.Teams.ADN
        "IngeniososElementales":
            current_team = GameConstants.Teams.INGENIOSOS_ELEMENTALES
        "PhotoAgros":
            current_team = GameConstants.Teams.PHOTO_AGROS
        "PlumaDorada":
            current_team = GameConstants.Teams.PLUMA_DORADA
        "RCPTeam":
            current_team = GameConstants.Teams.RPC_TEAM
        "RealPincel":
            current_team = GameConstants.Teams.REAL_PINCEL
        "Zootecnicos":
            current_team = GameConstants.Teams.ZOOTECNICOS

    print_debug("Equipo elegido: ", current_team as GameConstants.Teams)

## Actualiza los datos y pasa a jugar cuando se presiona el botón de jugar.[br]
##
## No pueden haber datos vacíos
func submit_and_play():
    if not line_edit_node.text:
        push_warning("Nombre vacío")
        line_edit_node.placeholder_text = "¡Nombre vacío!"
        return

    if current_team == -1:
        push_warning("Equipo vacío")
        ## ! Lógica de Ui para advertir de que falta equipo
        return

    ## ! Lógica para los demás datos cuando estos falten

    PlayerStats.team = current_team as GameConstants.Teams
    PlayerStats.player_name = line_edit_node.text

    FlagsManager.set_flag("character_selected", true)
    push_warning("No hay escena de juego")
