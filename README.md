# Javascript Runtime written entirely in Bash

This is a simple Javascript Runtime for Bash. The script evaluates expressions, processes variable assignments, logs outputs, and supports basic control structures like `if` statements and `wait`.

## Prerequisites

Before running the script, ensure that you have `bc` (a command-line calculator) installed. `bc` is used to evaluate arithmetic expressions in the script.

To install `bc` on a Linux-based system, you can run:

- **Debian/Ubuntu-based systems** (e.g., Ubuntu, Linux Mint):

    ```bash
    sudo apt-get install bc
    ```

- **Arch-based systems** (e.g., Arch Linux, Manjaro):

    ```bash
    sudo pacman -S bc
    ```

- **Fedora-based systems**:

    ```bash
    sudo dnf install bc
    ```

- **CentOS/RHEL-based systems**:

    ```bash
    sudo yum install bc
    ```

- **macOS** (using Homebrew):

    ```bash
    brew install bc
    ```

- **Windows** (via Windows Subsystem for Linux, WSL):

    For WSL users, follow the Ubuntu method above or install `bc` through the package manager of your chosen distribution.

## Usage

### Running the Script

To run the script, use the following command:

```bash
./bashjs.sh [script.js]
```

Where `script.js` is the JavaScript-like file you want to interpret. If no file is provided, the script will read input from the standard input.

### Running the Script from Standard Input

You can also run the script by piping JavaScript-like code directly into it. For example:

```bash
echo -e "let x = 5;\nlet y = x * 2 + 3;\nconsole.log(y);" | bash bashjs.sh
```

This will output:

```
13
```

## Supported Features

- **Variable Assignment**: `let variable = expression;`
- **Arithmetic Expressions**: Supported via the `bc` calculator (e.g., `5 + 10`, `x * y / 2`).
- **Logging**: `console.log(expression);` outputs the evaluated result of the expression.
- **Conditionals**: `if (condition) { actions }` (simple `if` conditions).
- **Wait**: `wait(seconds);` pauses execution for the specified number of seconds.

## License

This script is released under the MIT License.