"""
Script para generar documentación automática de scripts C# y GDScript.

Por Andrés López y con ayuda de GitHub Copilot.

Utiliza Google Gemini AI para analizar scripts y generar documentación markdown.
Requiere tener y configurar la variable de entorno `GEMINI_API_KEY` con una clave API de Google AI Studio.

**No modifiques este script**
"""

import os
from pathlib import Path
from typing import Optional
import google.generativeai as genai
import sys
from colorama import Fore, Style

# Bandera que determina si se hizo algún cambio
changes = False

# Obtener directorio del script actual para rutas robustas
SCRIPT_DIR = Path(__file__).parent.resolve()
PROJECT_ROOT = SCRIPT_DIR.parent

# Directorios a escanear, de salida y del prompt
SCAN_ROOT_DIR = PROJECT_ROOT
OUTPUT_DOCS_DIR = PROJECT_ROOT / ".ai_docs"
PROMPT_FILE_PATH = SCRIPT_DIR / "prompt.md"

# Directorios a excluir del escaneo
EXCLUDED_DIRS = {
    ".ai_docs",
    ".builds",
    ".doc_maker",
    ".docs",
    ".git",
    ".godot",
    ".idea",
    ".vscode",
    "addons",
}

# Configuración de la API de Gemini
GEMINI_MODEL = "gemini-2.5-flash"
ENV_VAR_NAME = "GEMINI_API_KEY"
genai_model = None


def config_api():
    """
    Configura el modelo con la clave API prevista
    """

    gemini_api_key = os.getenv(ENV_VAR_NAME)
    if gemini_api_key:
        genai.configure(api_key=gemini_api_key)
        global genai_model
        genai_model = genai.GenerativeModel(GEMINI_MODEL)
        print(
            Fore.BLUE
            + f"[Info] Modelo configurado: {genai_model.model_name}"
            + Style.RESET_ALL
        )
    else:
        print(
            Fore.RED
            + f"[Error] La variable de entorno {ENV_VAR_NAME} no existe. Por favor, créala con tu clave de API de Google AI Studio"
            + Style.RESET_ALL
        )
        sys.exit(1)


def read_file(file_path: Path) -> Optional[str]:
    """Lee un archivo de forma segura y devuelve su contenido.

    Args:
        file_path (Path): Ruta al archivo a leer.

    Returns:
        Optional[str]: Contenido del archivo o None si hay error.
    """

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return f.read()
    except Exception as e:
        print(
            Fore.RED
            + f"[Error] Ocurrió un error al leer {file_path}: {e}"
            + Style.RESET_ALL
        )
        return None


def find_script_files(scan_directory: Path):
    """Encuentra todos los scripts C# y GDScript en el directorio.

    Filtra automáticamente los directorios excluidos durante el recorrido.

    Args:
        scan_directory (Path): Directorio raíz a escanear.

    Yields:
        Path: Rutas de archivos .cs y .gd encontrados.
    """

    for dirpath, dirnames, filenames in os.walk(scan_directory):
        # Elimina carpetas excluidas del recorrido para optimizar búsqueda
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS]

        # Retorna solo scripts C# (.cs) o GDScript (.gd)
        for filename in filenames:
            file_path = Path(dirpath) / filename
            if file_path.suffix in {".gd", ".cs"}:
                yield file_path


def generate_script_documentation(
    script_path: Path, project_root: Path, readme_content: str
):
    """Genera documentación markdown para un script usando Gemini AI.

    Utiliza el contenido del prompt.md y el README.md como contexto para
    generar documentación con IA.

    Args:
        script_path (Path): Ruta absoluta al script a documentar.
        project_root (Path): Ruta raíz del proyecto para mantener estructura.
        readme_content (str): Contenido del README.md para contexto.

    Returns:
        bool. Indica si el archivo fue guardado.
    """

    # Lee el template de prompt
    prompt_template = read_file(PROMPT_FILE_PATH)
    if prompt_template is None:
        print(
            Fore.RED
            + f"[Error] No se pudo leer el prompt desde {PROMPT_FILE_PATH}"
            + Style.RESET_ALL
        )
        return False

    # Lee el contenido del script a documentar
    script_content = read_file(script_path)
    if script_content is None:
        print(
            Fore.RED
            + f"[Error] No se pudo leer el script desde {script_path}"
            + Style.RESET_ALL
        )
        return False

    # Construye el prompt final con contexto del proyecto
    context_section = ""
    if readme_content:
        context_section = (
            f"**Contexto general del proyecto (README.md):**\n\n---\n\n{readme_content}"
        )

    final_prompt = f"{context_section}\n{prompt_template}\n{script_content}\n```"

    # Intenta generar la documentación con el modelo
    try:
        response = genai_model.generate_content(final_prompt)
    except Exception as e:
        print(
            Fore.RED
            + f"[Error] Error con Gemini al procesar {script_path}: {e}"
            + Style.RESET_ALL
        )
        return False

    # Genera la ruta de salida con estructura plana: carpeta-sub_carpeta-archivo.md
    relative_path_str = str(script_path.relative_to(project_root).with_suffix(""))
    flat_filename = relative_path_str.replace(os.sep, "-").replace(" ", "_") + ".md"
    output_file_path = OUTPUT_DOCS_DIR / flat_filename

    # Asegura que el directorio de salida exista
    OUTPUT_DOCS_DIR.mkdir(exist_ok=True)

    # Guarda el contenido de la documentación generada
    try:
        with open(output_file_path, "w", encoding="utf-8") as f:
            try:
                f.write(response.text)
            except ValueError:
                content = "".join(
                    part.text for part in response.candidates[0].content.parts
                )
                f.write(content)
                if not content:
                    print(
                        Fore.YELLOW
                        + f"[Warning] La respuesta de la IA para {script_path} está vacía o incompleta: {response.candidates[0].finish_reason.name}"
                        + Style.RESET_ALL
                    )
                    return False

        print(
            Fore.GREEN
            + f"[Success] Documentación generada: {output_file_path}"
            + Style.RESET_ALL
        )
        return True
    except Exception as e:
        print(
            Fore.RED
            + f"[Error] No se pudo guardar {output_file_path}: {e}"
            + Style.RESET_ALL
        )
        return False


if __name__ == "__main__":
    print(
        Style.BRIGHT
        + "--- Creador de documentación (para C# y GDScript) ---"
        + Style.RESET_ALL
    )

    # Configura la API
    config_api()

    # Carga el contenido del README para contexto
    readme_file_path = PROJECT_ROOT / "README.md"
    readme_content = ""
    if readme_file_path.is_file():
        readme_content = read_file(readme_file_path)
        if readme_content:
            print(Fore.BLUE + "[Info] Contexto del README.md cargado" + Style.RESET_ALL)
        else:
            print(Fore.YELLOW + "[Warning] README.md vacío" + Style.RESET_ALL)
    else:
        print(Fore.YELLOW + "[Warning] No se encontró README.md" + Style.RESET_ALL)

    # Valida que el directorio existe
    if not SCAN_ROOT_DIR.is_dir():
        print(
            Fore.RED
            + f"[Error] El directorio a escanear no existe: {SCAN_ROOT_DIR}"
            + Style.RESET_ALL
        )
        sys.exit(1)

    print(
        Fore.BLUE + f"[Info] Escaneando scripts en: {SCAN_ROOT_DIR}" + Style.RESET_ALL
    )

    # Escanea y documenta cada script encontrado
    for script_file in find_script_files(SCAN_ROOT_DIR):
        # Acciona la bandera para indicar si hubo cambios
        if generate_script_documentation(script_file, PROJECT_ROOT, readme_content):
            changes = True

    # Advierte si no hubo cambios
    if not changes:
        print(
            Fore.YELLOW
            + "[Warning] No hubo cambios en la documentación"
            + Style.RESET_ALL
        )
