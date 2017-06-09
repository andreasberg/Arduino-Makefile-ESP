# A Makefile for Arduino Sketches 

This is a very simple Makefile which knows how to build Arduino sketches for ESP8266-boards. It defines entire workflows for compiling code, flashing it to ESP8266 and even communicating through Serial monitor. You don't need to change anything in the Arduino sketches.

The Makefile is based on [Arduino-Makefile](https://github.com/sudar/Arduino-Makefile). It uses most the filestructure of Arduino-Makefile but all AVR-related is replaced with ESP equivalents (esptool, espota.py, xtensa-lx106-elf-\* ). 

The ESP-parts are mostly derived from [makeEspArduino](https://github.com/plerup/makeEspArduino) including support for SPIFFS-filesystem and Over-The-Air-uploads.

## Installation

(Only tested on MacOS)
#### MacOS

### From source

- Clone it from Github using the command `https://github.com/andreasberg/Arduino-Makefile-ESP.git`
- Check the [usage section](https://github.com/andreasberg/Arduino-Makefile#usage) in this readme about setting usage options

## Requirements

### Arduino IDE

You need to have the Arduino IDE. You can either install it through the
installer or download the distribution zip file and extract it.

The latest release of the Arduino IDE can be downloaded from [here](https://github.com/arduino/Arduino/releases).

### ESP8266 core for Arduino 

The core sources, libraries and tools required for building skecthes for ESP8266-based boards.

The installation method is described under [Using git version](https://github.com/esp8266/Arduino#using-git-version).

## Usage

Download a copy of this repo somewhere to your system.

Create a Makefile (see [Makefile.example](Makefile.example)) in the same directory as the sketch and set ARDMK_DIR to point to the location where you downloaded this repo.

After which:

```make
   make upload
```

Useful Variables:
- `ARDMK_DIR`   - Path where the `*.mk` are present.
- `BOARD_TAG` - Type of board, for a list see boards.txt or `make show_boards`
- `MONITOR_PORT` - The port where your Arduino is plugged in.
- `ARDUINO_DIR` - Path to Arduino installation. 
- `TOOLS_DIR` - Path where the esp tools chain binaries are present. 

The list of all variables that can be overridden is available at [arduino-mk-esp-vars.md](arduino-mk-esp-vars.md) file.

## Including Libraries

You need to specify a space separated list of libraries that are needed for your sketch in the variable `ARDUINO_LIBS`.

```make
	ARDUINO_LIBS = Wire SoftwareSerial
```

The libraries will be searched for in the following places in the following order.

- `/libraries` directory inside your sketchbook directory. Sketchbook directory will be auto detected from your Arduino preference file. You can also manually set it through `ARDUINO_SKETCHBOOK`.
- `/libraries` directory inside your Arduino directory, which is read from `ARDUINO_DIR`.
- `/libraries` directory inside your ESP8266 directory, which is read from `ARDUINO_PLATFORM_LIB_PATH` .

The libraries inside user directories will take precedence over libraries present in Arduino core directory.

Autodetection of libraries is not currently supported

## esptool & espota.py

To upload compiled files, `esptool` or `espota.py` is used. This Makefile tries to find these tools below `ARDUINO_DIR`/hardware/esp8266com/esp8266/tools. 

## Limitations / Know Issues / TODO's

- Verification of HEX-binary size is not implemented
- .pde file not supported yet
- More than one .ino or .pde file is not supported yet
- Add support for Linux and Windows OSes
- Add support for ESP32-boards

If you find an issue or have an idea for a feature then log them in the [issue tracker](https://github.com/andreasberg/Arduino-Makefile-ESP/issues/)

## Credits

Credits to original creators of [Arduino-Makefile](https://github.com/sudar/Arduino-Makefile#credits) ([Martin Oldfield](http://mjo.tc/atelier/2009/02/arduino-cli.html),[Sudar Muthu](http://hardwarefun.com/tutorials/compiling-arduino-sketches-using-makefile),[Simon John](https://github.com/sej7278) et [al.](https://github.com/sudar/Arduino-Makefile/graphs/contributors)) 

as well as credits to [Peter Lerup](https://github.com/plerup) for the "official" [makefile](https://github.com/plerup/makeEspArduino) for ESP8266 and ESP32 Arduino projects.  

## Similar works
- [makeEspArduino](https://github.com/plerup/makeEspArduino) 
