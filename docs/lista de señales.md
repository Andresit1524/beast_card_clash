# Lista de señales de batalla
Esta es la lista de señales que llegan a la escena de batalla y la forma en la que se propagan. Se omiten las señales de interfaz.

> [!Note] Formato
> 
> ```
> O Señal (ó X Señal si la regla de propagación de señales no se cumple por el camino)
> | Descripción
> | 
> o -> Señal receptora (x si no cumple la regla)
> o ~> Función intermedia (x si no cumple la regla) 
> | 
> o => Función destino (x si no cumple la regla)
> | 
> Resultado tras el destino
> ```

---

<!--
Plantilla

```
O 
| 
|
o -> 
o ~> 
|
o==> 
|

``` 
-->

---

### Señales mal hechas

```
X Card.card_selected(card: Card)
| Se emite cuando la carta es presionada (Card._on_pressed)
| 
o -> BattleUI.card_selected(card: Card)
| 
x==> BattleManager._on_card_selected(selected_card: Card) -> void
|
Juega la carta seleccionada, desactiva la mano, refresca la interfaz y pasa el turno
```

```
X BattleTurn.enable_dice
| Se emite al inicio del estado Turn de batalla para permitirle al jugador lanzar el dado
|
x==> BattleStage.enable_dice(enabled: bool) -> void
|
Activa o desactiva el dado según el caso
```

---

### Señales bien hechas

```
O Rock.rock_selected(rock: Rock)
| Se emite cuando una roca se selecciona
|
o -> BattleStage.rock_selected(rock: Rock)
|
o==> BattleManager._on_rock_selected(selected_rock: Rock) -> void
|
Si es el turno humano, desactiva las rocas, mueve el personaje hacia la roca seleccionada, verifica si hay cartas jugables y salta el turno o activa la mano dependiendo del caso.
```

```
O BattleReferee.round_handled
| Se emite cuando la ronda ya fue manejada
|
o==> (await) BattleManager.decide_next_or_end() -> void
|
Se usa después de detectar el fin de ronda por el BattleManager. Cuando eso pasa se delega la batalla al Referee y esta señal es para que él indique que termino su trabajo
``` 

```
O BattleStage._rocks_ready
| Se emite cuando las rocas están listas
|
o==> (await) BattleStage.set_players(new_players: Array[Player]) -> void
|
Se usa para que las rocas estén listas antes de colocar a los jugadores sobre ellas
``` 
