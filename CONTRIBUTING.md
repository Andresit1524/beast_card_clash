# Guía de Contribución

¡Gracias por tu interés en contribuir a Beast Card Clash! Esta guía te enseñará todo lo que necesitas para desarrollar y colaborar en el proyecto de forma efectiva.

## Primeros Pasos
Para contribuir al desarrollo de BCC, asegúrate de tener lo siguiente:

### Requisitos
- Un sistema operativo compatible (Windows, Linux o macOS).
- Git y una cuenta de GitHub.
- [Godot 4.6](https://downloads.godotengine.org/?version=4.6&flavor=stable&slug=win64.exe.zip&platform=windows.64). Opcionalmente, la versión .NET si quieres usar C#.
- Godot será actualizado en la medida de los posible, al menos hasta la versión 4.6.
- [.NET SDK 8 o superior](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) (opcional, solo si usas C#).
- Un editor de código como Visual Studio Code o JetBrains Rider (recomendado).

## Flujo de Trabajo: Colaboración Directa
Este proyecto utiliza un modelo de colaboración directa. Para poder enviar cambios, necesitas ser añadido como colaborador en el repositorio. Avísale a Andrés para solicitar acceso.

Una vez que seas colaborador, podrás crear ramas directamente en el repositorio.

### Instalación
1. Clona este repositorio en tu computadora. Desde una terminal en la carpeta que quieras:

   ```bash
   git clone https://github.com/Andresit1524/beast_card_clash
   cd beast_card_clash
   ```

   Opcionalmente, puedes usar una herramienta visual como GitHub Desktop.

## Configuración del Espacio de Trabajo

### Si usas Visual Studio Code
1. Instala la extensión [godot-tools](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools) para obtener la mejor integración con Godot.
2. En la carpeta `.vscode/`, crea un archivo `settings.json` (si no existe) y añade la siguiente configuración. No olvides reemplazar el valor de `godotTools.editorPath.godot4` con la ruta real a tu ejecutable de Godot.

    ```json
    {
        "godotTools.editorPath.godot4": "[ruta/absoluta/a/tu/ejecutable/de/Godot]",

        // Exclusiones de archivos para mantener el explorador limpio
        "files.exclude": {
            "**/.builds/": true,
            "**/.doc_maker/": true,
            "**/.godot/": true
        }
    }
    ```

3. Abre el proyecto en Godot para que genere los archivos de configuración necesarios.

## Guía de Estilo de Código
Para mantener la consistencia en el proyecto, te pedimos que sigas estas guías:

- El código debe estar en inglés. Solo los comentarios y la documentación pueden estar en español.
- **GDScript**: Usa `snake_case` para nombres de variables, funciones, archivos y carpetas.
- **C#**: Usa `PascalCase` para nombres de clases, métodos, archivos y carpetas.
- Los nodos en la escena deben usar `PascalCase`.
- Mantén siempre una buena ortografía y sé consistente con el estilo del código existente.

## Cómo Enviar Cambios
Para asegurar un desarrollo ordenado, nunca trabajes directamente sobre la rama `main`. Sigue estos pasos para enviar tus cambios:

1.  **Crea una nueva rama**: Usa un nombre descriptivo para tu rama (ej. `feature/new-card` o `fix/main-menu-bug`).

    ```bash
    git checkout -b <nombre-de-tu-rama>
    ```

2.  **Realiza tus cambios y haz commit**: Añade los archivos que modificaste y crea un commit con un mensaje claro que describa tus cambios.

    ```bash
    git add .
    git commit -m "título del commit"
    ```

3.  **Sube tu rama al repositorio**:

    ```bash
    git push origin <nombre-de-tu-rama>
    ```

4.  **Abre un Pull Request**: Ve a la página del repositorio en GitHub. Verás una notificación para crear un Pull Request desde tu nueva rama. Revisa tus cambios y envíalo para que pueda ser revisado e integrado.