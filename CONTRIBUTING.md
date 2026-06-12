# Guía de Contribución
¡Gracias por tu interés en contribuir a Beast Card Clash! Te explico como desarrollar y colaborar en el proyecto de forma efectiva.

## Primeros Pasos
Para contribuir al desarrollo de BCC, asegúrate de tener lo siguiente:

### Requisitos
- [Godot 4.6](https://downloads.godotengine.org/?version=4.6.3&flavor=stable&slug=mono_win64.zip&platform=windows.64). Recomendamos la versión .NET. Godot será actualizado en la medida de los posible, al menos dentro de las versiones 4.x
- [Plantillas de exportación de Godot](https://downloads.godotengine.org/?version=4.6.3&flavor=stable&slug=mono_export_templates.tpz&platform=templates) para tu versión del motor. Esto para exportar el juego. **¡Las plantillas se deben actualizar a la vez con el editor!**.
- [.NET SDK 9 o superior](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) (opcional, para usar C#).
- Un editor de código como Visual Studio Code (recomendado).

## Flujo de Trabajo: Colaboración Directa
Este proyecto utiliza un modelo de colaboración directa. Para poder enviar cambios, necesitas ser añadido como colaborador en el repositorio. Avísale a [Andresit1524 en GitHub](https://github.com/Andresit1524) para solicitar acceso.

Una vez que seas colaborador, podrás crear ramas directamente en el repositorio. ¡Cuida las ramas principales!

Clona este repositorio en tu computadora. Desde una terminal en la carpeta que quieras:

```bash
git clone https://github.com/Andresit1524/beast_card_clash
cd beast_card_clash
```

Opcionalmente, puedes usar una herramienta visual como GitHub Desktop.

## Configuración del Espacio de Trabajo

> [!NOTE]
> 
> Si usas Visual Studio Code
> 
> 1. Instala la extensión [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) para obtener la mejor integración con Godot. El editor te lo recomienda automáticamente.
> 2. En la carpeta `.vscode/` habrán archivos de configuración y recomendación que te ayudarán a tener una experiencia coherente con el del resto de personas. No lo cambies.
> 3. Abre el proyecto en Godot para que genere los archivos de configuración necesarios.
> 4. No recomendamos usar otro formateador diferente de Godot tools. Otros formateadores como GDFormat pueden ser perniciosos con los archivos ya existentes.

## Guía de Estilo de Código
Para mantener la consistencia en el proyecto, te pedimos que sigas estas guías:

- El código debe estar en inglés. Solo los comentarios y la documentación deberían estar en español.
- Usa `snake_case` en todo, excepto en tipos, clases, constantes y enumeradores (convención oficial de Godot).
- C# usa sus propias reglas de estilo, las cuales puedes consultar [aquí](https://docs.godotengine.org/es/4.x/tutorials/scripting/c_sharp/c_sharp_style_guide.html).
- Los nodos en la escena deben usar `PascalCase`. Mientras que las escenas y los archivos en `snake_case`
- Mantén siempre una buena ortografía y sé consistente con el estilo del código existente.
- Añade anotaciones de tipo siempre que puedas, te ayudará con el autocompletado y la lectura de código.

## Cómo Enviar Cambios
Para asegurar un desarrollo ordenado, nunca trabajes directamente sobre la rama `main`. Sigue estos pasos para enviar tus cambios:

1. **Crea una nueva rama:** Usa un nombre descriptivo para tu rama, o ponle uno cuando ya sepas que haces en ella.

    ```bash
    git checkout -b <tu_rama>
    ```

2. **Realiza tus cambios:** Mantén commits ordenados en el proceso.
3. **Sube tu rama al repositorio:**

    ```bash
    git push origin
    ```

4. **Abre un Pull Request:** Ve a la página del repositorio en GitHub. Verás una notificación para crear un Pull Request desde tu nueva rama. Revisa tus cambios y envíalo para que pueda ser revisado e integrado.
