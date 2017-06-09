## Makefile for BasicOTA 

SRCDIR := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
ARDMK_DIR := $(SRCDIR)/../..

# include Common.mk now we know where it is
include $(ARDMK_DIR)/Common.mk

#set the board tag, run 'make show_boards' to show available boards
BOARD_TAG=generic

#extra library path if needed
#USER_LIB_PATH := $(SRCDIR)/libraries

# List all libraries(filenames) needed (searched for in all known library paths) 
ARDUINO_LIBS=ArduinoOTA ESP8266WiFi ESP8266mDNS

include $(ARDMK_DIR)/ArduinoESP.mk
