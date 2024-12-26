# Project Creator

A command-line tool written in COBOL to quickly scaffold new programming projects with proper directory structures and basic configurations.

## Features

- Creates project structures for multiple programming languages:
  - Python (with virtual environment and pytest)
  - Go
  - Rust
  - JavaScript
  - C++
  - COBOL

- Saves last used project path for convenience
- Interactive menu-driven interface
- Automatic creation of basic project files and configurations

## Prerequisites

- GnuCOBOL compiler (>= 3.0)
- Python3 (for Python projects)
- Go (for Go projects)
- Rust/Cargo (for Rust projects)
- Node.js (for JavaScript projects)
- G++ (for C++ projects)
- Basic Unix/Linux commands (mkdir, cat, chmod)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/project-creator.git
   cd project-creator
   ```

2. Compile the COBOL program:
   ```bash
   cobc -x -o project-creator src/main.cob
   ```

3. Make the program executable:
   ```bash
   chmod +x project-creator
   ```

4. Optional: Add to your PATH for system-wide access:
   ```bash
   sudo ln -s $(pwd)/project-creator /usr/local/bin/
   ```

## Verwendung (Usage)

1. Starten Sie das Programm:
   ```bash
   ./project-creator
   ```

2. Folgen Sie den Anweisungen im interaktiven Menü:
   - Wählen Sie die Programmiersprache
   - Geben Sie den Projektnamen ein
   - Wählen Sie den Projektpfad

Das Programm erstellt automatisch die entsprechende Projektstruktur.


