# Documentation of variables

The following are the different variables that can be overwritten in the user makefiles.

*	[Global variables](#global-variables)
*	[Installation/Directory variables](#installationdirectory-variables)
*	[Arduino IDE variables](#arduino-ide-variables)
*	[Sketch related variables](#sketch-related-variables)
*	[ISP programming variables](#isp-programming-variables)
*	[Compiler/Executable variables](#compilerexecutable-variables)
*	[Avrdude setting variables](#avrdude-setting-variables)
*	[Bootloader variables](#bootloader-variables)
*	[ChipKIT variables](#chipkit-variables)

## Global variables

### ARDUINO_QUIET

**Description:**

Suppress printing of Arduino-Makefile configuration.

Defaults to `0` (unset/disabled).

**Example:**

```Makefile
ARDUINO_QUIET = 1
```

**Requirement:** *Optional*

----

## Installation/Directory variables

### ARDMK_DIR

**Description:**

Directory where the `*.mk` files are stored.

Usually can be auto-detected as parent of `Arduino.mk`.

**Example:**

```Makefile
ARDMK_DIR = /usr/share/arduino
```

**Requirement:** *Optional*

----

### TOOLS_DIR

**Description:**

Directory where tools such as `xtensa-lx106-elf`, `esptool`, `espota.py`, etc. are stored in or in subdirectories.

**Example:**

```Makefile
TOOLS_DIR = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/tools
```

**Requirement:** *Optional*

----

## Arduino IDE variables

### ARDUINO_DIR

**Description:**

Directory where the Arduino IDE and/or core files are stored. Usually can be auto-detected as `AUTO_ARDUINO_DIR`.

**Example:**

```Makefile
# Linux
ARDUINO_DIR = /usr/share/arduino
# Mac OS X
ARDUINO_DIR = /Applications/Arduino.app/Contents/Resources/Java
# Mac OSX with IDE 1.5+
ARDUINO_DIR = /Applications/Arduino.app/Contents/Java
```

**Requirement:** *Optional*

----

### ARDUINO_PLATFORM_LIB_PATH

**Description:**

Directory where the Arduino platform dependent libraries are stored.

**Example:**

```Makefile
ARDUINO_PLATFORM_LIB_PATH = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/libraries
```

**Requirement:** *Optional*

----

### ARDUINO_VERSION

**Description:**

Version string for Arduino IDE and/or core.

Usually can be auto-detected as `AUTO_ARDUINO_VERSION` from `/usr/share/arduino/lib/version.txt`

**Example:**

```Makefile
ARDUINO_VERSION = 105
```

**Requirement:** *Optional*

----

### ARCHITECTURE

**Description:**

Architecture for Arduino 1.5+

Defaults to `esp8266` 

**Example:**

```Makefile
ARCHITECTURE = esp8266
```

**Requirement:** *Optional*

----

### ARDMK_VENDOR

**Description:**

Board vendor/maintainer.

Defaults to `esp8266com`

**Example:**

```Makefile
ARDMK_VENDOR = esp8266com
```

**Requirement:** *Optional*

----

### ARDUINO_SKETCHBOOK

**Description:**

Path to `sketchbook` directory.

Usually can be auto-detected from the Arduino `preferences.txt` file or the default `$(HOME)/sketchbook`

**Example:**

```Makefile
ARDUINO_SKETCHBOOK = $(HOME)/Documents/Arduino
```

**Requirement:** *Optional*

----

### ARDUINO_PREFERENCES_PATH

**Description:**

Path to Arduino `preferences.txt` file.

Usually can be auto-detected as `AUTO_ARDUINO_PREFERENCES` from the defaults:

*	on Linux (1.0):     `$(HOME)/.arduino/preferences.txt`
*	on Linux (1.5+):    `$(HOME)/.arduino15/preferences.txt`
*	on Mac OS X (1.0):  `$(HOME)/Library/Arduino/preferences.txt`
*	on Mac OS X (1.5+): `$(HOME)/Library/Arduino15/preferences.txt`

**Example:**

```Makefile
ARDUINO_PREFERENCES_PATH = $(HOME)/sketches/preferences.txt
```

**Requirement:** *Optional*

----

### ARDUINO_CORE_PATH

**Description:**

Path to standard Arduino core files.

**Example:**

```Makefile
ARDUINO_CORE_PATH = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/cores/esp8266
```

**Requirement:** *Optional*

----

## Sketch related variables

### ARDUINO_LIBS

**Description:**

Any libraries you intend to include.

Auto-detection not used. Separated by spaces. If the library has a `/utility` folder (like `SD` or `Wire` library), then the utility folder should also be specified.

**Example:**

```Makefile
ARDUINO_LIBS = SD SD/utility Wire Wire/utility
```

**Requirement:** *Optional*

----

### BOARD_TAG

**Description:**

Device type as listed in `boards.txt` or `make show_boards`.

**Example:**

```Makefile
BOARD_TAG = huzzah
```

**Requirement:** *Mandatory*

----

### BOARD_SUB

**Description:**

1.5+ submenu as listed in `boards.txt` or `make show_submenu`. (Not used)

**Example:**

```Makefile
# diecimila.name=Arduino Duemilanove or Diecimila
BOARD_TAG=diecimila

# diecimila.menu.cpu.atmega168=ATmega168
BOARD_SUB=atmega168
```

**Requirement:** *Not used*

----

### MONITOR_PORT

**Description:**

Path to serial (USB) device used for uploading/serial comms.

**Example:**

```Makefile
# Linux
MONITOR_PORT = /dev/ttyUSB0
# or
MONITOR_PORT = /dev/ttyACM0
# Mac OS X
MONITOR_PORT = /dev/cu.usb*
# Windows
MONITOR_PORT = com3
```

**Requirement:** *Mandatory*

----

### FORCE_MONITOR_PORT

**Description:**

Skip the MONITOR_PORT existance check.

**Example:**

```Makefile
# Enable
FORCE_MONITOR_PORT = true
# Disable (default)
undefine FORCE_MONITOR_PORT
```

**Requirement:** *Optional*

----

### USER_LIB_PATH

**Description:**

Directory where additional libraries are stored.

Defaults to `libraries` directory within user's sketchbook.

**Example:**

```Makefile
# Linux
USER_LIB_PATH = $(HOME)/sketchbook/libraries
# For a random project on *nix
USER_LIB_PATH = /path/to/my/project
```

**Requirement:** *Optional*

----

### OBJDIR

**Description:**

Directory where binaries and compiled files are put.

Defaults to `build-$(BOARD_TAG)` in your `Makefile` directory.

**Example:**

```Makefile
OBJDIR = /path/to/my/project-directory/bin
```

**Requirement:** *Optional*

----

### TARGET

**Description:**

What name you would like for generated target files.

Defaults to the name of your current working directory, but with underscores (_) instead of spaces.

**Example:**

```Makefile
TARGET = my-project
```

Will generate targets like `my-project.hex` and `my-project.elf`.

**Requirement:** *Optional*

----

### ARDUINO_VAR_PATH

**Description:**

Path to non-standard core's variant files.

**Example:**

```Makefile
ARDUINO_VAR_PATH = $(HOME)/sketchbook/hardware/arduino-tiny/cores/tiny
```

**Requirement:** *Optional*

----

### CORE

**Description:**

Name of the core

Usually can be auto-detected as `build.core` from `boards.txt`.

**Example:**

```Makefile
CORE = esp8266
```

**Requirement:** *Optional*

----

### VARIANT

**Description:**

Variant of a standard board design.

Usually can be auto-detected as `build.variant` from `boards.txt`.

**Example:**

```Makefile
VARIANT = adafruit
```

**Requirement:** *Optional*

----

### F_CPU

**Description:**

CPU speed in Hz

Usually can be auto-detected as `build.f_cpu` from `boards.txt`.

**Example:**

```Makefile
F_CPU = 8000000L
```

**Requirement:** *Optional*

----

### HEX_MAXIMUM_SIZE

**Description:**

Maximum hex file size

Usually can be auto-detected as `upload.maximum_size` from `boards.txt`

**Example:**

```Makefile
HEX_MAXIMUM_SIZE = 14336
```

**Requirement:** *Optional*

----

### MCU

**Description:**

Microcontroller model.

Usually can be auto-detected as `build.mcu` from `boards.txt`

**Example:**

```Makefile
MCU = esp8266
```

**Requirement:** *Optional*

----

### MONITOR_BAUDRATE

**Description:**

Baudrate of the serial monitor.

Defaults to `9600` if it can't find it in the sketch `Serial.begin()`

**Example:**

```Makefile
MONITOR_BAUDRATE = 57600
```

**Requirement:** *Optional*

----

## Compiler/Executable variables

### CC_NAME

**Description:**

C compiler.

Defaults to `xtensa-lx106-elf-gcc`.

**Example:**

```Makefile
CC_NAME = xtensa-lx106-elf-gcc
```

**Requirement:** *Optional*

----

### CXX_NAME

**Description:**

C++ compiler.

Defaults to `xtensa-lx106-elf-g++`.

**Example:**

```Makefile
CXX_NAME = xtensa-lx106-elf-g++
```

**Requirement:** *Optional*

----

### OBJCOPY_NAME

**Description:**

Objcopy utility.

Defaults to `xtensa-lx106-elf-objcopy`.

**Example:**

```Makefile
OBJCOPY_NAME = xtensa-lx106-elf-objcopy
```

**Requirement:** *Optional*

----

### OBJDUMP_NAME

**Description:**

Objdump utility.

Defaults to `xtensa-lx106-elf-objdump`.

**Example:**

```Makefile
OBJDUMP_NAME = xtensa-lx106-elf-objdump
```

**Requirement:** *Optional*

----

### AR_NAME

**Description:**

Archive utility.

Defaults to `xtensa-lx106-elf-ar`.

**Example:**

```Makefile
AR_NAME = xtensa-lx106-elf-ar
```

**Requirement:** *Optional*

----

### SIZE_NAME

**Description:**

Size utility.

Defaults to `xtensa-lx106-elf-size`.

**Example:**

```Makefile
SIZE_NAME = xtensa-lx106-elf-size
```

**Requirement:** *Optional*

----

### NM_NAME

**Description:**

Nm utility.

Defaults to `xtensa-lx106-elf-nm`.

**Example:**

```Makefile
NM_NAME = xtensa-lx106-elf-nm
```

**Requirement:** *Optional*

----

### OPTIMIZATION_LEVEL

**Description:**

Linker's `-O` flag

Defaults to `s`, which shouldn't really be changed as it breaks `SoftwareSerial` and usually results in bigger hex files.

**Example:**

```Makefile
OPTIMIZATION_LEVEL = 3
```

**Requirement:** *Optional*

----

### OTHER_LIBS

**Description:**

Additional Linker lib flags, for platform support

Defaults to ""

**Example:**

```Makefile
OTHER_LIBS = -lsomeplatformlib
```

**Requirement:** *Optional*

----

### CFLAGS_STD

**Description:**

Controls, *exclusively*, which C standard is to be used for compilation.

Defaults to `undefined` (the directive is normally included in `compiler.c.flags` from `platform.txt`)

For more information, please refer to the [Options Controlling C Dialect](https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html)

**Example:**

```Makefile
CFLAGS_STD = = -std=gnu89
```

**Requirement:** *Optional*

----

### CXXFLAGS_STD

**Description:**

Controls, *exclusively*, which C++ standard is to be used for compilation.

Defaults to `undefined` (the directive is normally included in `compiler.cpp.flags` from `platform.txt`)

For more information, please refer to the [Options Controlling C Dialect](https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html)

**Example:**

```Makefile
CXXFLAGS_STD = = -std=gnu++98
```

**Requirement:** *Optional*

----

### CFLAGS

**Description:**

Flags passed to compiler for files compiled as C. Add more flags to this
variable using `+=`.

Defaults are be auto-detected as `compiler.c.flags` from `platform.txt`

**Example:**

```Makefile
CFLAGS += -my-c-only-flag
```

**Requirement:** *Optional*

----

### CXXFLAGS

**Description:**

Flags passed to the compiler for files compiled as C++. Add more flags to this
variable using `+=`.

Defaults are be auto-detected as `compiler.cpp.flags` from `platform.txt`


**Example:**

```Makefile
CXXFLAGS += -my-c++-onlyflag
```

**Requirement:** *Optional*

----

### ASFLAGS

**Description:**

Flags passed to compiler for files compiled as assembly (e.g. `.S` files). Add
more flags to this variable using `+=`.

Defaults are be auto-detected as `compiler.S.flags` from `platform.txt`

**Example:**

```Makefile
ASFLAGS += -my-as-only-flag
```

**Requirement:** *Optional*

----

### CPPFLAGS

**Description:**

Flags passed to the C pre-processor (for C, C++ and assembly source flies). Add
more flags to this variable using `+=`.

Defaults to all flags required for a typical build.

**Example:**

```Makefile
CPPFLAGS += -DMY_DEFINE_FOR_ALL_SOURCE_TYPES
```

**Requirement:** *Optional*

----

### OVERRIDE_EXECUTABLES

**Description:**

Override the default build tools.

If set to `1`, each tool (`CC`, `CXX`, `AS`, `OBJCOPY`, `OBJDUMP`, `AR`, `SIZE`, `NM`) must have its path explicitly defined. See `chipKIT.mk`.

**Example:**

```Makefile
OVERRIDE_EXECUTABLES = 1
```

**Requirement:** *Optional*

----

### MONITOR_CMD

**Description:**

Command to run the serial monitor.

Defaults to `screen`

**Example:**

```Makefile
MONITOR_CMD = minicom
```

**Requirement:** *Optional*

----

### PRE_BUILD_HOOK

**Description:**

Path to shell script to be executed before build. Could be used to automatically
bump revision number for example.

Defaults to `pre-build-hook.sh`

**Example:**

```Makefile
PRE_BUILD_HOOK = $(HOME)/bin/bump-revision.sh
```

**Requirement:** *Optional*

----

## Esptool setting variables

### ESPTOOL

**Description:**

Path to `esptool` utility

Usually can be auto-detected within the parent of `TOOLS_DIR`

**Example:**

```Makefile
ESPTOOL = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/tools/esptool/esptool
```

**Requirement:** *Optional*

----

### TOOLS_PATH

**Description:**

Directory where the xtensa-lx106-elf-binaries (*-gcc, *.g++, *-objdump etc) are located.

Usually can be auto-detected from `TOOLS_DIR/xtensa-lx106-elf/bin`

**Example:**

```Makefile
TOOLS_PATH = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/tools/xtensa-lx106-elf/bin
```

**Requirement:** *Optional*

----

### ARDUINO_LIB_PATH

**Description:**

Directory where the standard Arduino libraries are stored.

Defaults to `ARDUINO_DIR/libraries`

**Example:**

```Makefile
# MacOS
ARDUINO_LIB_PATH = /Applications/Arduino.app/Contents/Java/libraries
```

**Requirement:** *Optional*

----

### BOARDS_TXT

**Description:**

Path to `boards.txt`

Defaults to `ARDUINO_DIR/hardware/esp8266com/esp8266/boards.txt`

**Example:**

```Makefile
BOARD_TXT = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/boards.txt
```

**Requirement:** *Optional*

----

### PLATFORM_TXT

**Description:**

Path to `platform.txt`

Defaults to `ARDUINO_DIR/hardware/esp8266com/esp8266/platform.txt`

**Example:**

```Makefile
BOARD_TXT = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/platform.txt
```

**Requirement:** *Optional*

----

### ESPTOOL_OPTS

**Description:**

Options to pass to `esptool` when creating HEX.

**Example:**

```Makefile
ESPTOOL_OPTS = -d
```

**Requirement:** *Optional*

----

### ESPTOOL_UPLOAD_OPTS

**Description:**

Options to pass to `esptool` when uploading/flashing HEX-binary.

**Requirement:** *Optional*

----

### ESPTOOL_UPLOAD_FS_OPTS

**Description:**

Options to pass to `esptool` when uploading/flashing SPIFFS-filesystem.

**Requirement:** *Optional*

----

### BOOTLOADER_PARENT

**Description:**

Absolute path to bootloader file's parent directory.

Defaults to `ARDUINO_DIR/hardware/esp8266com/esp8266/bootloaders`

**Example:**

```Makefile
BOOTLOADER_PARENT = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/bootloaders
```

**Requirement:** *Optional*

----

### FSTOOL

**Description:**

Path to `mkspiffs` utility

Usually can be auto-detected within the parent of `TOOLS_DIR`

**Example:**

```Makefile
ESPTOOL = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/tools/mkspiffs/mkspiffs
```

**Requirement:** *Optional*

----

### FSTOOL_OPTS

**Description:**

Options to pass to `mkspiffs` when creating Filesystem-image.

**Requirement:** *Optional*

----

### FS_DIR 

**Description:**

Path to root of Filesystem to pass to `mkspiffs` when creating Filesystem-image.

**Requirement:** *Optional*

----

### OTATOOL

**Description:**

Path to Over-The-Air `espota.py` utility

Usually can be auto-detected within the parent of `TOOLS_DIR`

**Example:**

```Makefile
ESPTOOL = /Applications/Arduino.app/Contents/Java/hardware/esp8266com/esp8266/tools/espota.py
```

**Requirement:** *Optional*

----

### OTATOOL_UPLOAD_OPTS

**Description:**

Options to pass to `espota.py` when uploading/flashing HEX-binary.

**Requirement:** *Optional*

----

### OTATOOL_UPLOAD_FS_OPTS

**Description:**

Options to pass to `espota.py` when uploading/flashing SPIFFS-filesystem.

**Requirement:** *Optional*

----

### ESP_OTA_ADDR

**Description:**

IP-address to pass to `espota.py` when uploading/flashing SPIFFS-filesystem.

**Requirement:** *Optional*

----

### ESP_OTA_PORT

**Description:**

Port number to pass to `espota.py` when uploading/flashing SPIFFS-filesystem.

**Requirement:** *Optional*

----

### ESP_OTA_PWD

**Description:**

Password to pass to `espota.py` when uploading/flashing SPIFFS-filesystem.

**Requirement:** *Optional*
