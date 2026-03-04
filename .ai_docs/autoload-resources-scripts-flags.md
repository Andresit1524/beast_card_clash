# `Flags`
La clase `Flags` es un `AutoloadResource` fundamental para la gestión de la progresión de la historia del juego. Extendiendo `AutoloadResource`, `Flags` se establece como un recurso de Godot que además es un _singleton_ accesible globalmente en cualquier punto del proyecto. Esto significa que puede ser instanciado una vez al inicio del juego y su estado puede ser consultado y modificado desde cualquier script sin necesidad de pasarlo como argumento o buscarlo en el árbol de nodos.

Su propósito principal es almacenar y gestionar "banderas" (flags), que son variables encargadas de dictar el estado y la progresión de la narrativa del juego. Estas banderas permiten rastrear eventos ya ocurridos, decisiones tomadas o condiciones alcanzadas que impactan directamente el desarrollo de la historia, como por ejemplo, si un personaje ya fue encontrado, una misión completada o un camino desbloqueado.

Actualmente, el diseño de `Flags` prevé que todas las banderas sean valores booleanos, lo que es adecuado para representar estados binarios (verdadero/falso). Sin embargo, la propia descripción del código anticipa una futura flexibilidad para adaptar el sistema y permitir el uso de otros tipos de datos si las necesidades de la historia se vuelven más complejas, lo que demuestra una arquitectura pensada para la escalabilidad.

Este enfoque centralizado en `Flags` simplifica enormemente la gestión del estado del juego, permitiendo que componentes dispares (como diálogos, sistemas de misiones, eventos ambientales o lógicas de personajes) interactúen de manera coherente con la progresión de la historia sin acoplamientos complejos.

```gdscript
class_name Flags extends AutoloadResource
```

La implementación actual define únicamente la clase y su herencia, sin propiedades ni métodos explícitos. Se espera que las banderas se gestionen a través de propiedades `export` o variables directamente definidas dentro de la clase `Flags` que luego se manipulen desde otros scripts a través de la instancia global del _singleton_.

# Métodos
Actualmente, la clase `Flags` no contiene métodos explícitos definidos en el fragmento de código proporcionado. Su funcionalidad se deriva de su naturaleza como `AutoloadResource` y las propiedades (flags) que se espera contenga en futuras iteraciones.