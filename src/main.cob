       IDENTIFICATION DIVISION.
       PROGRAM-ID. PROJECT-CREATOR.
       AUTHOR. CLAUDE.
       DATE-WRITTEN. 2024-03-19.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SPECIAL-NAMES.
           CONSOLE IS CRT.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CONFIG-FILE
           ASSIGN TO WS-CONFIG-PATH
           ORGANIZATION IS LINE SEQUENTIAL
           FILE STATUS IS WS-FILE-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD CONFIG-FILE.
       01 CONFIG-RECORD.
           05 SAVED-PATH         PIC X(255).
       
       WORKING-STORAGE SECTION.
       01 WS-PROJECT-DETAILS.
           05 WS-PARENT-PATH     PIC X(255).
           05 WS-PROJECT-NAME    PIC X(50).
           05 WS-PROJECT-TYPE    PIC 9.
               88 PYTHON         VALUE 1.
               88 GOLANG        VALUE 2.
               88 RUST          VALUE 3.
               88 JAVASCRIPT    VALUE 4.
               88 CPLUSPLUS     VALUE 5.
               88 COBOL         VALUE 6.
       
       01 WS-MENU-CHOICE        PIC 9.
       01 WS-ERROR-FLAG         PIC 9.
           88 IS-VALID          VALUE 0.
           88 HAS-ERROR         VALUE 1.
       
       01 WS-CONFIRM            PIC X.
           88 YES               VALUE "Y" "y".
           88 NEIN             VALUE "N" "n".
       
       01 WS-STATUS.
           05 WS-FILE-STATUS    PIC XX.
           88 SUCCESS           VALUE "00".
       
       01 WS-ENV-DETAILS.
           05 WS-HOME            PIC X(255).
           05 WS-CONFIG-PATH     PIC X(255).
       01 WS-ENV-BLOCK.
           05 ENV-NAME          PIC X(5).
           05 ENV-VALUE         PIC X(255).
       
       SCREEN SECTION.
       01 CLEAR-SCREEN.
           05 BLANK SCREEN.
       
       01 MAIN-MENU.
           05 LINE 2 COL 5      VALUE "Project Creator Menu".
           05 LINE 4 COL 5      VALUE "1. Python Project".
           05 LINE 5 COL 5      VALUE "2. Go Project".
           05 LINE 6 COL 5      VALUE "3. Rust Project".
           05 LINE 7 COL 5      VALUE "4. JavaScript Project".
           05 LINE 8 COL 5      VALUE "5. C++ Project".
           05 LINE 9 COL 5      VALUE "6. COBOL Project".
           05 LINE 11 COL 5     VALUE "Enter choice (1-6): ".
       
       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
           PERFORM DISPLAY-MENU
           PERFORM GET-PROJECT-DETAILS
           PERFORM CREATE-PROJECT
           STOP RUN.
       
       INITIALIZE-PROGRAM.
           INITIALIZE WS-PROJECT-DETAILS
           SET IS-VALID TO TRUE
           PERFORM GET-HOME-PATH
           PERFORM LOAD-CONFIG.
       
       GET-HOME-PATH.
           MOVE "HOME" TO ENV-NAME
           ACCEPT ENV-VALUE FROM ENVIRONMENT ENV-NAME
           STRING 
               FUNCTION TRIM(ENV-VALUE)
               "/.config/newpipi_project_path"
               DELIMITED BY SIZE
               INTO WS-CONFIG-PATH
           END-STRING.
       
       LOAD-CONFIG.
           OPEN INPUT CONFIG-FILE
           IF WS-FILE-STATUS = "35"
               MOVE SPACES TO WS-PARENT-PATH
           ELSE
               IF SUCCESS
                   READ CONFIG-FILE
                       AT END
                           MOVE SPACES TO WS-PARENT-PATH
                       NOT AT END
                           MOVE SAVED-PATH TO WS-PARENT-PATH
                   END-READ
                   CLOSE CONFIG-FILE
               END-IF
           END-IF.
       
       DISPLAY-MENU.
           DISPLAY CLEAR-SCREEN
           DISPLAY MAIN-MENU
           ACCEPT WS-MENU-CHOICE AT LINE 11 COL 25
           MOVE WS-MENU-CHOICE TO WS-PROJECT-TYPE.
       
       GET-PROJECT-DETAILS.
           DISPLAY CLEAR-SCREEN
           DISPLAY "Enter project path [" AT LINE 2 COL 5
           DISPLAY FUNCTION TRIM(WS-PARENT-PATH) 
               AT LINE 2 COL 24
           DISPLAY "]: " AT LINE 2 COL 45
           ACCEPT WS-PARENT-PATH AT LINE 2 COL 48
           
           IF WS-PARENT-PATH = SPACES
               MOVE SAVED-PATH TO WS-PARENT-PATH
           END-IF
           
           DISPLAY "Enter project name: " AT LINE 4 COL 5
           ACCEPT WS-PROJECT-NAME AT LINE 4 COL 25
           
           PERFORM VALIDATE-INPUT.
       
       VALIDATE-INPUT.
           IF WS-PROJECT-NAME = SPACES
               DISPLAY "Project name cannot be empty!" 
                   AT LINE 20 COL 5
               SET HAS-ERROR TO TRUE
           END-IF.
       
       CREATE-PROJECT.
           IF IS-VALID
               DISPLAY "Creating project..." AT LINE 6 COL 5
               EVALUATE WS-PROJECT-TYPE
                   WHEN 1 PERFORM CREATE-PYTHON-PROJECT
                   WHEN 2 PERFORM CREATE-GO-PROJECT
                   WHEN 3 PERFORM CREATE-RUST-PROJECT
                   WHEN 4 PERFORM CREATE-JS-PROJECT
                   WHEN 5 PERFORM CREATE-CPP-PROJECT
                   WHEN 6 PERFORM CREATE-COBOL-PROJECT
               END-EVALUATE
               
               DISPLAY "Project created successfully!" 
                   AT LINE 8 COL 5
               DISPLAY "Press any key to continue..." 
                   AT LINE 12 COL 5
               ACCEPT WS-CONFIRM AT LINE 12 COL 35
           END-IF.
       
       CREATE-PYTHON-PROJECT.
           DISPLAY "Creating Python project structure..." 
               AT LINE 10 COL 5
           
           *> Create directory structure
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """, 
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src""")
           END-CALL
           
           *> Create temporary script for main.py content
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cat > /tmp/create_main.sh << 'EOF'",
                   X'0A',
                   "cat > $1 << 'END'",
                   X'0A',
                   "#!/usr/bin/env python3",
                   X'0A',
                   "def main():",
                   X'0A',
                   "    print('Hello from $2!')",
                   X'0A',
                   X'0A',
                   "if __name__ == '__main__':",
                   X'0A',
                   "    main()",
                   X'0A',
                   "END",
                   X'0A',
                   "EOF")
           END-CALL

           *> Make script executable
           CALL "SYSTEM" USING 
               "chmod +x /tmp/create_main.sh"
           END-CALL

           *> Execute script to create main.py
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "/tmp/create_main.sh """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.py"" """,
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """")
           END-CALL

           *> Create and initialize virtual environment
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """ && python3 -m venv venv")
           END-CALL
           
           *> Create requirements.txt
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo ""pytest>=7.0.0"" > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/requirements.txt""")
           END-CALL
           
           *> Install requirements
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """ && ./venv/bin/pip install -r requirements.txt")
           END-CALL.
       
       CREATE-GO-PROJECT.
           DISPLAY "Creating Go project structure..." 
               AT LINE 10 COL 5
           
           *> Create base directory
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """")
           END-CALL

           *> Create project subdirectories
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/cmd""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/internal""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/pkg""")
           END-CALL

           *> Initialize go module and tidy
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """ && go mod init ",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   " && go mod tidy")
           END-CALL

           *> Create main.go
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cat > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/cmd/main.go"" << 'EOF'",
                   X'0A',
                   "package main",
                   X'0A',
                   X'0A',
                   "import (",
                   X'0A',
                   "    ""fmt""",
                   X'0A',
                   ")",
                   X'0A',
                   X'0A',
                   "func main() {",
                   X'0A',
                   "    fmt.Println(""Hello from ",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "!"")",
                   X'0A',
                   "}",
                   X'0A',
                   "EOF")
           END-CALL.
       
       CREATE-RUST-PROJECT.
           DISPLAY "Creating Rust project structure..." 
               AT LINE 10 COL 5
           
           *> Create new Rust project using cargo
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   """ && cargo new ",
                   FUNCTION TRIM(WS-PROJECT-NAME))
           END-CALL

           *> Add common dependencies to Cargo.toml
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'clap = ""4.5.1""' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/Cargo.toml""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'serde = ""1.0""' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/Cargo.toml""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'serde_json = ""1.0""' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/Cargo.toml""")
           END-CALL

           *> Update main.rs with better template
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cat > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.rs"" << 'EOF'",
                   X'0A',
                   "fn main() {",
                   X'0A',
                   "    println!(""Hello from ",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "!"");",
                   X'0A',
                   "}",
                   X'0A',
                   X'0A',
                   "#[cfg(test)]",
                   X'0A',
                   "mod tests {",
                   X'0A',
                   "    #[test]",
                   X'0A',
                   "    fn it_works() {",
                   X'0A',
                   "        assert_eq!(2 + 2, 4);",
                   X'0A',
                   "    }",
                   X'0A',
                   "}",
                   X'0A',
                   "EOF")
           END-CALL.
       
       CREATE-JS-PROJECT.
           DISPLAY "Creating JavaScript project structure..." 
               AT LINE 10 COL 5
           
           *> Create base directory
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src""")
           END-CALL

           *> Initialize npm project with default values
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """ && npm init -y")
           END-CALL

           *> Install common dependencies
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """ && npm install express dotenv jest")
           END-CALL

           *> Add test script to package.json
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cd """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   """ && npm pkg set scripts.test=""jest""")
           END-CALL

           *> Create main.js
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "cat > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.js"" << 'EOF'",
                   X'0A',
                   "require('dotenv').config();",
                   X'0A',
                   "const express = require('express');",
                   X'0A',
                   "const app = express();",
                   X'0A',
                   "const port = process.env.PORT || 3000;",
                   X'0A',
                   X'0A',
                   "app.get('/', function(req, res) ",
                   X'0A',
                   "    res.send('Hello from ",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "!');",
                   X'0A',
                   "});",
                   X'0A',
                   X'0A',
                   "app.listen(port, function() ",
                   X'0A',
                   "    console.log('Server running on port ' + port);",
                   X'0A',
                   "});",
                   X'0A',
                   "EOF")
           END-CALL

           *> Create .env
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'PORT=3000' > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/.env""")
           END-CALL.
       
       CREATE-CPP-PROJECT.
           DISPLAY "Creating C++ project structure..." 
               AT LINE 10 COL 5
           
           *> Create directory structure
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/include""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/build""")
           END-CALL

           *> Create CMakeLists.txt
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'cmake_minimum_required(VERSION 3.10)' > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/CMakeLists.txt""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'project(", 
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   ")' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/CMakeLists.txt""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'set(CMAKE_CXX_STANDARD 17)' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/CMakeLists.txt""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'add_executable(main src/main.cpp)' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/CMakeLists.txt""")
           END-CALL

           *> Create main.cpp
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '#include <iostream>' > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cpp""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo 'int main() {' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cpp""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '    std::cout << ""Hello from ",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "!"" << std::endl;' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cpp""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '    return 0;' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cpp""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '}' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cpp""")
           END-CALL.

       CREATE-COBOL-PROJECT.
           DISPLAY "Creating COBOL project structure..." 
               AT LINE 10 COL 5
           
           *> Create directory structure
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/copybooks""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "mkdir -p """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/bin""")
           END-CALL

           *> Create main.cob line by line
           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '       01 WS-HELLO    PIC X(50)' > """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cob.tmp""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '           VALUE ""Hello from ",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "!"".' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cob.tmp""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '       PROCEDURE DIVISION.' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cob""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '       MAIN-PROCEDURE.' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cob""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '           DISPLAY WS-HELLO' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cob""")
           END-CALL

           CALL "SYSTEM" USING 
               FUNCTION CONCATENATE(
                   "echo '           STOP RUN.' >> """,
                   FUNCTION TRIM(WS-PARENT-PATH),
                   "/",
                   FUNCTION TRIM(WS-PROJECT-NAME),
                   "/src/main.cob""")
           END-CALL.
       
       CLEANUP-PROGRAM.
           DISPLAY "Press any key to continue..." 
               AT LINE 22 COL 5
           ACCEPT WS-CONFIRM AT LINE 22 COL 35.
		   