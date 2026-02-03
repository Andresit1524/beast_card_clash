# `Flags`

Este script actúa como un gestor centralizado de estados booleanos (banderas) dentro del flujo de ejecución de **Beast Card Clash**. Su propósito principal es servir como un **Singleton (Autoload)** que permite a otros componentes del juego consultar el estado global de ciertas condiciones de manera rápida y desacoplada.

El sistema utiliza una estructura de diccionario para organizar estas condiciones, lo que facilita la expansión de estados sin necesidad de modificar la lógica de consulta. En el contexto de un juego de cartas, estas banderas pueden determinar si una partida está activa, si un tutorial ha finalizado o si se han cumplido hitos específicos relacionados con la biodiversidad o las facultades de la UNAL.

# Métodos

## Otros métodos

### `get_flag(flag: String)`
Este método funciona como un *getter* público para acceder a los valores almacenados en el diccionario privado `_flags`. 

* **Funcionamiento:** Recibe una cadena de texto que debe coincidir exactamente con una de las llaves definidas en el diccionario. Devuelve el valor booleano asociado.
* **Uso técnico:** Al estar diseñado para ser consultado desde un Singleton, permite que cualquier script del proyecto verifique estados globales sin necesidad de referencias directas entre nodos.

```gdscript
# Ejemplo de uso desde otro componente:
if Flags.get_flag("played"):
    _iniciar_interfaz_combate()
```

> [!IMPORTANT]
> Actualmente, el script no cuenta con un método de escritura (`set_flag`). Esto implica que las banderas están definidas estáticamente en el código o deben ser modificadas internamente por la lógica de este mismo script si se expande en el futuro.

### Propiedades internas (Variables)

#### `_flags: Dictionary[String, bool]`
Es el contenedor principal de la información. Utiliza tipado fuerte para asegurar que las llaves sean siempre cadenas y los valores sean booleanos.

* **Banderas actuales:**
    * `"played"`: Indica si el estado de "jugado" está activo (inicializado en `false`).

```gdscript
var _flags: Dictionary[String, bool] = {
    "played": false
}
```