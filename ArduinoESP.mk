########################################################################
#
# Makefile for compiling Arduino sketches from command line
# System part (i.e. project independent)
#
# Copyright (C) 2012 Sudar <http://sudarmuthu.com>, based on
# M J Oldfield work: https://github.com/mjoldfield/Arduino-Makefile
#
# Copyright (C) 2010,2011,2012 Martin Oldfield <m@mjo.tc>, based on
# work that is copyright Nicholas Zambetti, David A. Mellis & Hernando
# Barragan.
#
# This file is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 2.1 of the
# License, or (at your option) any later version.
#
# Adapted from Arduino 0011 Makefile by M J Oldfield
#
# Original Arduino adaptation by mellis, eighthave, oli.keller
#
# Current version: 1.5.2
#
# Refer to HISTORY.md file for complete history of changes
#
########################################################################
#
# PATHS YOU NEED TO SET UP
#
# We need to worry about three different sorts of files:
#
# 1. The directory where the *.mk files are stored
#    => ARDMK_DIR
#
# 2. Things which are always in the Arduino distribution e.g.
#    boards.txt, libraries, etc.
#    => ARDUINO_DIR
#
# 3. Things which might be bundled with the Arduino distribution, but
#    might come from the system. Most of the toolchain is like this:
#    on Linux it is supplied by the system.
#    => TOOLS_DIR
#
# Having set these three variables, we can work out the rest assuming
# that things are canonically arranged beneath the directories defined
# above.
#
# On the Mac with IDE 1.0 you might want to set:
#
#   ARDUINO_DIR   = /Applications/Arduino.app/Contents/Resources/Java
#   ARDMK_DIR     = /usr/local
#
# On the Mac with IDE 1.5+ you might want to set:
#
#   ARDUINO_DIR   = /Applications/Arduino.app/Contents/Java
#   ARDMK_DIR     = /usr/local
#
# On Linux, you might prefer:
#
#   ARDUINO_DIR   = /usr/share/arduino
#   ARDMK_DIR     = /usr/share/arduino
#   TOOLS_DIR = /usr
#
# On Windows declare this environmental variables using the windows
# configuration options. Control Panel > System > Advanced system settings
# Also take into account that when you set them you have to add '\' on
# all spaces and special characters.
# ARDUINO_DIR and TOOLS_DIR have to be relative and not absolute.
# This are just examples, you have to adapt this variables accordingly to
# your system.
#
#   ARDUINO_DIR   =../../../../../Arduino
#   TOOLS_DIR =../../../../../Arduino/hardware/tools/avr
#   ARDMK_DIR     = /cygdrive/c/Users/"YourUser"/Arduino-Makefile
#
# On Windows it is highly recommended that you create a symbolic link directory
# for avoiding using the normal directories name of windows such as
# c:\Program Files (x86)\Arduino
# For this use the command mklink on the console.
#
#
# You can either set these up in the Makefile, or put them in your
# environment e.g. in your .bashrc
#
# If you don't specify these, we can try to guess, but that might not work
# or work the way you want it to.
#
# If you'd rather not see the configuration output, define ARDUINO_QUIET.
#
########################################################################
#
# DEPENDENCIES
#
#  to reset a board the (python)  pySerial program is used.
#  please install it prior to continue.
#
########################################################################
#
# STANDARD ARDUINO WORKFLOW
#
# Given a normal sketch directory, all you need to do is to create
# a small Makefile which defines a few things, and then includes this one.
#
# For example:
#
#       ARDUINO_LIBS = Ethernet SPI
#       BOARD_TAG    = uno
#       MONITOR_PORT = /dev/cu.usb*
#
#       include /usr/share/arduino/Arduino.mk
#
# Hopefully these will be self-explanatory but in case they're not:
#
#    ARDUINO_LIBS - A list of any libraries used by the sketch (we
#                   assume these are in $(ARDUINO_DIR)/hardware/libraries
#                   or your sketchbook's libraries directory)
#
#    MONITOR_PORT - The port where the Arduino can be found (only needed
#                   when uploading)
#
#    BOARD_TAG    - The tag for the board e.g. uno or mega
#                   'make show_boards' shows a list
#
# If you have your additional libraries relative to your source, rather
# than in your "sketchbook", also set USER_LIB_PATH, like this example:
#
#        USER_LIB_PATH := $(realpath ../../libraries)
#
# If you've added the Arduino-Makefile repository to your git repo as a
# submodule (or other similar arrangement), you might have lines like this
# in your Makefile:
#
#        ARDMK_DIR := $(realpath ../../tools/Arduino-Makefile)
#        include $(ARDMK_DIR)/Arduino.mk
#
# In any case, once this file has been created the typical workflow is just
#
#   $ make upload
#
# All of the object files are created in the build-{BOARD_TAG} subdirectory
# All sources should be in the current directory and can include:
#  - at most one .pde or .ino file which will be treated as C++ after
#    the standard Arduino header and footer have been affixed.
#  - any number of .c, .cpp, .s and .h files
#
# Included libraries are built in the build-{BOARD_TAG}/libs subdirectory.
#
# Besides make upload, there are a couple of other targets that are available.
# Do make help to get the complete list of targets and their description
#
########################################################################
#
# SERIAL MONITOR
#
# The serial monitor just invokes the GNU screen program with suitable
# options. For more information see screen (1) and search for
# 'character special device'.
#
# The really useful thing to know is that ^A-k gets you out!
#
# The fairly useful thing to know is that you can bind another key to
# escape too, by creating $HOME{.screenrc} containing e.g.
#
#    bindkey ^C kill
#
# If you want to change the baudrate, just set MONITOR_BAUDRATE. If you
# don't set it, it tries to read from the sketch. If it couldn't read
# from the sketch, then it defaults to 9600 baud.
#
########################################################################

arduino_output =
# When output is not suppressed and we're in the top-level makefile,
# running for the first time (i.e., not after a restart after
# regenerating the dependency file), then output the configuration.
ifndef ARDUINO_QUIET
    ifeq ($(MAKE_RESTARTS),)
        ifeq ($(MAKELEVEL),0)
            arduino_output = $(info $(1))
        endif
    endif
endif

RELEASE=1

########################################################################
# Makefile distribution path

ifndef ARDMK_DIR
    # presume it's the same path to our own file
    ARDMK_DIR := $(realpath $(dir $(realpath $(lastword $(MAKEFILE_LIST)))))
else
    # show_config_variable macro is defined in Common.mk file and is not available yet.
    # Let's define a variable to know that user specified ARDMK_DIR
    ARDMK_DIR_MSG = USER
endif

# include Common.mk now we know where it is
include $(ARDMK_DIR)/Common.mk

# show_config_variable macro is available now. So let's print config details for ARDMK_DIR
ifndef ARDMK_DIR_MSG
    $(call show_config_variable,ARDMK_DIR,[COMPUTED],(relative to $(notdir $(lastword $(MAKEFILE_LIST)))))
else
    $(call show_config_variable,ARDMK_DIR,[USER])
endif


########################################################################
# Default TARGET to pwd (ex Daniele Vergini)

ifndef TARGET
    space :=
    space +=
    TARGET = $(notdir $(subst $(space),_,$(CURDIR)))
endif

########################################################################
# Arduino version number

ifndef ARDUINO_VERSION
    # Remove all the decimals, remove anything before/including ":", remove anything after/including "+" and finally grab the last 5 bytes.
    # Works for 1.0 and 1.0.1 and 1.6.10 and debian-style 2:1.0.5+dfsg2-4
    VERSION_FILE := $(ARDUINO_DIR)/lib/version.txt
    AUTO_ARDUINO_VERSION := $(shell [ -e $(VERSION_FILE) ] && cat $(VERSION_FILE) | sed -e 's/^[0-9]://g' -e 's/[.]//g' -e 's/\+.*//g' | head -c5)
    ifdef AUTO_ARDUINO_VERSION
        ARDUINO_VERSION = $(AUTO_ARDUINO_VERSION)
        $(call show_config_variable,ARDUINO_VERSION,[AUTODETECTED])
    else
        ARDUINO_VERSION = 100
        $(call show_config_variable,ARDUINO_VERSION,[DEFAULT])
    endif
else
    $(call show_config_variable,ARDUINO_VERSION,[USER])
endif

########################################################################
# architecture - defaults to esp8266
ifndef ARCHITECTURE
    ARCHITECTURE = esp8266
    $(call show_config_variable,ARCHITECTURE,[DEFAULT])
else
    $(call show_config_variable,ARCHITECTURE,[USER])
endif

########################################################################
# vendor - defaults to esp8266com
ifndef ARDMK_VENDOR
	ARDMK_VENDOR = esp8266com
    $(call show_config_variable,ARDMK_VENDOR,[DEFAULT])
else
    $(call show_config_variable,ARDMK_VENDOR,[USER])
endif

########################################################################
# filepath to boards.txt and platform.txt 
ifndef BOARDS_TXT
    BOARDS_TXT  = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/boards.txt
    $(call show_config_variable,BOARDS_TXT,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,BOARDS_TXT,[USER])
endif

ifndef PLATFORM_TXT
    PLATFORM_TXT  = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/platform.txt
    $(call show_config_variable,PLATFORM_TXT,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,PLATFORM_TXT,[USER])
endif

########################################################################
# boards.txt parsing

ifndef BOARD_TAG
	# Default: Generic ESP8266 Module
    BOARD_TAG   = generic
    $(call show_config_variable,BOARD_TAG,[DEFAULT])
else
    # Strip the board tag of any extra whitespace, since it was causing the makefile to fail
    # https://github.com/sudar/Arduino-Makefile/issues/57
    BOARD_TAG := $(strip $(BOARD_TAG))
    $(call show_config_variable,BOARD_TAG,[USER])
endif

ifndef PARSE_BOARD
    # result = $(call PARSE_BOARD, 'boardname', 'parameter')
    #PARSE_BOARD = $(shell grep -v "^\#" "$(BOARDS_TXT)" | grep -e "^$(1).$(2)\w*" | cut -d = -f 2- )
    PARSE_BOARD = $(shell grep -Ev '^\#' $(BOARDS_TXT) | grep -E "^[ \t]*$(1).$(2)=" | cut -d = -f 2 | cut -d : -f 2)
endif

ifndef BOARD
	BOARD  := $(call PARSE_BOARD,$(BOARD_TAG),build.board)
	ifndef BOARD
		BOARD = ESP8266_ESP01
		$(call show_config_variable,BOARD,[DEFAULT])
	else
        $(call show_config_variable,BOARD,[BOARDS_TXT],(from build.board))
	endif
endif


########################################################################
# platform.txt parsing

ifndef PARSE_PLATFORM
    # result = $(call PARSE_PLATFORM, 'parameter')
    PARSE_PLATFORM = $(shell grep -v "^\#" "$(PLATFORM_TXT)" | grep -e "^$(1)\w*" | cut -d = -f 2- )
endif


########################################################################
# Arduino Sketchbook folder

ifndef ARDUINO_SKETCHBOOK
    ifndef ARDUINO_PREFERENCES_PATH
        ifeq ($(shell expr $(ARDUINO_VERSION) '>' 150), 1)
            AUTO_ARDUINO_PREFERENCES := $(firstword \
                $(call dir_if_exists,$(HOME)/.arduino15/preferences.txt) \
                $(call dir_if_exists,$(HOME)/Library/Arduino15/preferences.txt) )
        else
            AUTO_ARDUINO_PREFERENCES := $(firstword \
                $(call dir_if_exists,$(HOME)/.arduino/preferences.txt) \
                $(call dir_if_exists,$(HOME)/Library/Arduino/preferences.txt) )
        endif

        ifdef AUTO_ARDUINO_PREFERENCES
           ARDUINO_PREFERENCES_PATH = $(AUTO_ARDUINO_PREFERENCES)
           $(call show_config_variable,ARDUINO_PREFERENCES_PATH,[AUTODETECTED])
        endif

    else
        $(call show_config_variable,ARDUINO_PREFERENCES_PATH,[USER])
    endif

    ifneq ($(ARDUINO_PREFERENCES_PATH),)
        ARDUINO_SKETCHBOOK := $(shell grep --max-count=1 --regexp='sketchbook.path=' \
                                          $(ARDUINO_PREFERENCES_PATH) | \
                                     sed -e 's/sketchbook.path=//' )
    endif

    ifneq ($(ARDUINO_SKETCHBOOK),)
        $(call show_config_variable,ARDUINO_SKETCHBOOK,[AUTODETECTED],(from arduino preferences file))
    else
        ARDUINO_SKETCHBOOK := $(firstword \
            $(call dir_if_exists,$(HOME)/sketchbook) \
            $(call dir_if_exists,$(HOME)/Documents/Arduino) )
        $(call show_config_variable,ARDUINO_SKETCHBOOK,[DEFAULT])
    endif
else
    $(call show_config_variable,ARDUINO_SKETCHBOOK,[USER])
endif

########################################################################
# Arduino and system paths

########################################################################
# command names and default flags

ifndef CC_NAME
	# if boards.txt gets modified, look there, else look in platform.txt or finally hard code it
    CC_NAME := $(call PARSE_BOARD,$(BOARD_TAG),compiler.c.cmd)
    ifndef CC_NAME
    	CC_NAME := $(call PARSE_PLATFORM,compiler.c.cmd)
	    ifndef CC_NAME
	    	CC_NAME := xtensa-lx106-elf-gcc
            $(call show_config_variable,CC_NAME,[DEFAULT])
	    else
            $(call show_config_variable,CC_NAME,[PLATFORM_TXT],(from compiler.c.cmd))
            # read CFLAGS from same location (ignoring any unexpanded variables {*})
            CFLAGS ?= $(patsubst {%},,$(call PARSE_PLATFORM,compiler.c.flags))
            $(call show_config_variable,CFLAGS,[PLATFORM_TXT],(from compiler.c.flags))
	    endif
    else
        $(call show_config_variable,CC_NAME,[BOARDS_TXT],(from compiler.c.cmd))
        CFLAGS ?= $(call PARSE_BOARD,$(BOARD_TAG),compiler.c.flags)
        $(call show_config_variable,CFLAGS,[BOARDS_TXT],(from compiler.c.flags))
    endif
else
    $(call show_config_variable,CC_NAME,[USER])
endif

ifndef CXX_NAME
	# if boards.txt gets modified, look there, else look in platform.txt or finally hard code it
    CXX_NAME := $(call PARSE_BOARD,$(BOARD_TAG),compiler.cpp.cmd)
    ifndef CXX_NAME
    	CXX_NAME := $(call PARSE_PLATFORM,compiler.cpp.cmd)
	    ifndef CXX_NAME
	    	CXX_NAME := xtensa-lx106-elf-g++
            $(call show_config_variable,CXX_NAME,[DEFAULT])
	    else
            $(call show_config_variable,CXX_NAME,[PLATFORM_TXT],(from compiler.cpp.cmd))
            # read CXXFLAGS from same location (ignoring any unexpanded variables {*})
            CXXFLAGS ?= $(patsubst {%},,$(call PARSE_PLATFORM,compiler.cpp.flags))
            $(call show_config_variable,CXXFLAGS,[PLATFORM_TXT],(from compiler.cpp.flags))
	    endif
    else
        $(call show_config_variable,CXX_NAME,[BOARDS_TXT],(from compiler.cpp.cmd))
        CXXFLAGS ?= $(call PARSE_BOARD,$(BOARD_TAG),compiler.cpp.flags)
        $(call show_config_variable,CXXFLAGS,[BOARDS_TXT],(from compiler.cpp.flags))
    endif
else
    $(call show_config_variable,CXX_NAME,[USER])
endif

ifndef AS_NAME
	# if boards.txt gets modified, look there, else look in platform.txt or finally hard code it
    AS_NAME := $(call PARSE_BOARD,$(BOARD_TAG),compiler.S.cmd)
    ifndef AS_NAME
    	AS_NAME := $(call PARSE_PLATFORM,compiler.S.cmd)
	    ifndef AS_NAME
	    	AS_NAME := xtensa-lx106-elf-g++
            $(call show_config_variable,AS_NAME,[DEFAULT])
	    else
            $(call show_config_variable,AS_NAME,[PLATFORM_TXT],(from compiler.S.cmd))
            # read ASFLAGS from same location (ignoring any unexpanded variables {*})
            ASFLAGS ?= $(patsubst {%},,$(call PARSE_PLATFORM,compiler.S.flags))
            $(call show_config_variable,ASFLAGS,[PLATFORM_TXT],(from compiler.S.flags))
	    endif
    else
        $(call show_config_variable,AS_NAME,[BOARDS_TXT],(from compiler.S.cmd))
        ASFLAGS ?= $(call PARSE_BOARD,$(BOARD_TAG),compiler.S.flags)
        $(call show_config_variable,ASFLAGS,[BOARDS_TXT],(from compiler.S.flags))
    endif
else
    $(call show_config_variable,AS_NAME,[USER])
endif

ifndef OBJCOPY_NAME
    OBJCOPY_NAME := xtensa-lx106-elf-objcopy
    $(call show_config_variable,OBJCOPY_NAME,[DEFAULT])
endif

ifndef OBJDUMP_NAME
    OBJDUMP_NAME := xtensa-lx106-elf-objdump
    $(call show_config_variable,OBJDUMP_NAME,[DEFAULT])
endif

ifndef AR_NAME
	# if boards.txt gets modified, look there, else look in platform.txt or finally hard code it
    AR_NAME := $(call PARSE_BOARD,$(BOARD_TAG),compiler.ar.cmd)
    ifndef AR_NAME
    	AR_NAME := $(call PARSE_PLATFORM,compiler.ar.cmd)
	    ifndef AR_NAME
	    	AR_NAME := xtensa-lx106-elf-ar
            $(call show_config_variable,AR_NAME,[DEFAULT])
	    else
            $(call show_config_variable,AR_NAME,[PLATFORM_TXT],(from compiler.ar.cmd))
            # read ARFLAGS from same location (ignoring any unexpanded variables {*})
            ARFLAGS ?= $(patsubst {%},,$(call PARSE_PLATFORM,compiler.ar.flags))
            $(call show_config_variable,ARFLAGS_STD,[PLATFORM_TXT],(from compiler.ar.flags))
	    endif
    else
        $(call show_config_variable,AR_NAME,[BOARDS_TXT],(from compiler.ar.cmd))
        ARFLAGS := $(call PARSE_BOARD,$(BOARD_TAG),compiler.ar.flags)
        $(call show_config_variable,ARFLAGS,[BOARDS_TXT],(from compiler.ar.flags))
    endif
else
    $(call show_config_variable,AR_NAME,[USER])
endif

ifndef SIZE_NAME
    SIZE_NAME := xtensa-lx106-elf-size
    $(call show_config_variable,SIZE_NAME,[DEFAULT])
else
	$(call show_config_variable,SIZE_NAME,[USER])
endif

ifndef NM_NAME
    NM_NAME := xtensa-lx106-elf-nm
    $(call show_config_variable,NM_NAME,[DEFAULT])
else
	$(call show_config_variable,NM_NAME,[USER])
endif

ifndef TOOLS_DIR
    CHECK_TOOLS_DIR := $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/tools
	ifneq (,$(wildcard $(CHECK_TOOLS_DIR)/xtensa-lx106-elf/bin/$(CC_NAME)))
        TOOLS_DIR := $(CHECK_TOOLS_DIR)
        $(call show_config_variable,TOOLS_DIR,[COMPUTED],(from ARDUINO_DIR,ARDMK_VENDOR and ARCHITECTURE))
    else
        echo $(error No tools directory found)
    endif 
else
    $(call show_config_variable,TOOLS_DIR,[USER])
endif #ndef TOOLS_DIR

ifndef TOOLS_PATH
    TOOLS_PATH    = $(TOOLS_DIR)/xtensa-lx106-elf/bin
endif

ifndef ARDUINO_LIB_PATH
    ARDUINO_LIB_PATH = $(ARDUINO_DIR)/libraries
    $(call show_config_variable,ARDUINO_LIB_PATH,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,ARDUINO_LIB_PATH,[USER])
endif

ifndef ARDUINO_PLATFORM_LIB_PATH
    ARDUINO_PLATFORM_LIB_PATH = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/libraries
    $(call show_config_variable,ARDUINO_PLATFORM_LIB_PATH,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,ARDUINO_PLATFORM_LIB_PATH,[USER])
endif

ifndef ARDUINO_VAR_PATH
    ARDUINO_VAR_PATH  = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/variants
    $(call show_config_variable,ARDUINO_VAR_PATH,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,ARDUINO_VAR_PATH,[USER])
endif

########################################################################
# Miscellaneous

ifndef USER_LIB_PATH
    USER_LIB_PATH = $(ARDUINO_SKETCHBOOK)/libraries
    $(call show_config_variable,USER_LIB_PATH,[DEFAULT],(in user sketchbook))
else
    $(call show_config_variable,USER_LIB_PATH,[USER])
endif

ifndef PRE_BUILD_HOOK
    PRE_BUILD_HOOK = pre-build-hook.sh
    $(call show_config_variable,PRE_BUILD_HOOK,[DEFAULT])
else
    $(call show_config_variable,PRE_BUILD_HOOK,[USER])
endif

# If NO_CORE is set, then we don't have to parse boards.txt file
# But the user might have to define MCU, F_CPU etc
ifeq ($(strip $(NO_CORE)),)

    ifndef CORE
        CORE = $(call PARSE_BOARD,$(BOARD_TAG),build.core)
        $(call show_config_variable,CORE,[BOARDS_TXT],(from build.core))
    else
        $(call show_config_variable,CORE,[USER])
    endif

    # Which variant ? This affects the include path
    ifndef VARIANT
        VARIANT := $(call PARSE_BOARD,$(BOARD_TAG),menu.(chip|cpu).$(BOARD_SUB).build.variant)
        ifndef VARIANT
            VARIANT := $(call PARSE_BOARD,$(BOARD_TAG),build.variant)
        endif
        $(call show_config_variable,VARIANT,[BOARDS_TXT],(from build.variant))
    else
        $(call show_config_variable,VARIANT,[USER])
    endif

	ifndef F_CPU
        SPEEDS := $(call PARSE_BOARD,"$(BOARD_TAG),menu.CpuFrequency.*.build.f_cpu") # Obtain sequence of supported frequencies.
        # SPEEDS := $(shell printf "%d\n" $(SPEEDS) | sort -g) # Sort it, just in case. Printf to re-append newlines so that sort works. | Sort doesn't work, OSX prob?
        # F_CPU := $(lastword $(SPEEDS)) # List is sorted in ascending order. Take the fastest speed.
        F_CPU := $(firstword $(SPEEDS))
        $(call show_config_variable,F_CPU,[BOARDS_TXT],(from *.build.f_cpu))
        #$(info "speeds is " $(SPEEDS))  # Good for debugging
	endif

    ifndef HEX_MAXIMUM_SIZE
        HEX_MAXIMUM_SIZE := $(call PARSE_BOARD,$(BOARD_TAG),upload.maximum_size)
        $(call show_config_variable,HEX_MAXIMUM_SIZE,[BOARDS_TXT],(from upload.maximum_size))
    endif

    ifndef ESP_FLASHSIZE
    	# Obtain sequence of supported flash sizes by locating unique *.build.flash_size -keys.
        FLASH_SIZES := $(shell grep -Ev '^\#' $(BOARDS_TXT) | grep -E "^[ \t]*$(BOARD_TAG).menu.FlashSize.*.build.flash_size=" | cut -d = -f 1 | cut -d . -f 4)
        #$(info "flash_sizes is " $(FLASH_SIZES))  # Good for debugging
    	# Select first one as default
    	FLASH_SIZE := $(firstword $(FLASH_SIZES))
        ESP_FLASHSIZE := $(call PARSE_BOARD,$(BOARD_TAG),menu.FlashSize.$(FLASH_SIZE).build.flash_size)

    	# eg.LINKER_SCRIPTS = "-Teagle.flash.4m1m.ld"
    	ifndef LINKER_SCRIPTS 
            FLASH_LD := $(call PARSE_BOARD,$(BOARD_TAG),menu.FlashSize.$(FLASH_SIZE).build.flash_ld)
            ifneq (,$(strip $(FLASH_LD)))
            	LINKER_SCRIPTS := "-T$(strip $(FLASH_LD))"
            endif
            $(call show_config_variable,LINKER_SCRIPTS,[BOARDS_TXT],(from *.build.flash_ld))
    	else
            $(call show_config_variable,LINKER_SCRIPTS,[USER],(from *.build.f_cpu))
    	endif

    endif
endif

# Everything gets built in here (include BOARD_TAG now)
ifndef OBJDIR
    OBJDIR = build-$(BOARD_TAG)
    ifdef BOARD_SUB
        OBJDIR = build-$(BOARD_TAG)-$(BOARD_SUB)
    endif
    $(call show_config_variable,OBJDIR,[COMPUTED],(from BOARD_TAG))
else
    $(call show_config_variable,OBJDIR,[USER])
endif

# Now that we have ARDUINO_DIR, ARDMK_VENDOR, ARCHITECTURE and CORE,
# we can set ARDUINO_CORE_PATH.
ifndef ARDUINO_CORE_PATH
    ifeq ($(strip $(CORE)),)
        ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/cores/arduino
        $(call show_config_variable,ARDUINO_CORE_PATH,[DEFAULT])
    else
        ARDUINO_CORE_PATH = $(ALTERNATE_CORE_PATH)/cores/$(CORE)
        ifeq ($(wildcard $(ARDUINO_CORE_PATH)),)
            ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/cores/$(CORE)
            $(call show_config_variable,ARDUINO_CORE_PATH,[COMPUTED],(from ARDUINO_DIR, BOARD_TAG and boards.txt))
        else
            $(call show_config_variable,ARDUINO_CORE_PATH,[COMPUTED],(from ALTERNATE_CORE_PATH, BOARD_TAG and boards.txt))
        endif
    endif
else
    $(call show_config_variable,ARDUINO_CORE_PATH,[USER])
endif


########################################################################
# Local sources

LOCAL_C_SRCS    ?= $(wildcard *.c)
LOCAL_CPP_SRCS  ?= $(wildcard *.cpp)
LOCAL_CC_SRCS   ?= $(wildcard *.cc)
LOCAL_PDE_SRCS  ?= $(wildcard *.pde)
LOCAL_INO_SRCS  ?= $(wildcard *.ino)
LOCAL_AS_SRCS   ?= $(wildcard *.S)
LOCAL_SRCS      = $(LOCAL_C_SRCS)   $(LOCAL_CPP_SRCS) \
		$(LOCAL_CC_SRCS)   $(LOCAL_PDE_SRCS) \
		$(LOCAL_INO_SRCS) $(LOCAL_AS_SRCS)
LOCAL_OBJ_FILES = $(LOCAL_C_SRCS:.c=.c.o)   $(LOCAL_CPP_SRCS:.cpp=.cpp.o) \
		$(LOCAL_CC_SRCS:.cc=.cc.o)   $(LOCAL_PDE_SRCS:.pde=.pde.o) \
		$(LOCAL_INO_SRCS:.ino=.ino.o) $(LOCAL_AS_SRCS:.S=.S.o)
LOCAL_OBJS      = $(patsubst %,$(OBJDIR)/%,$(LOCAL_OBJ_FILES))

ifeq ($(words $(LOCAL_SRCS)), 0)
    $(error At least one source file (*.ino, *.pde, *.cpp, *c, *cc, *.S) is needed)
endif

# CHK_SOURCES is used by flymake
# flymake creates a tmp file in the same directory as the file under edition
# we must skip the verification in this particular case
ifeq ($(strip $(CHK_SOURCES)),)
    ifeq ($(strip $(NO_CORE)),)

        # Ideally, this should just check if there are more than one file
        ifneq ($(words $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS)), 1)
            ifeq ($(words $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS)), 0)
                $(call show_config_info,No .pde or .ino files found. If you are compiling .c or .cpp files then you need to explicitly include Arduino header files)
            else
                #TODO: Support more than one file. https://github.com/sudar/Arduino-Makefile/issues/49
                $(error Need exactly one .pde or .ino file. This makefile doesn't support multiple .ino/.pde files yet)
            endif
        endif

    endif
endif

# core sources
ifeq ($(strip $(NO_CORE)),)
    ifdef ARDUINO_CORE_PATH
        CORE_C_SRCS     = $(wildcard $(ARDUINO_CORE_PATH)/*.c)
        CORE_C_SRCS    += $(wildcard $(ARDUINO_CORE_PATH)/libb64/*.c)
        CORE_C_SRCS    += $(wildcard $(ARDUINO_CORE_PATH)/spiffs/*.c)
        CORE_C_SRCS    += $(wildcard $(ARDUINO_CORE_PATH)/umm_malloc/*.c)
        CORE_CPP_SRCS   = $(wildcard $(ARDUINO_CORE_PATH)/*.cpp)
        CORE_AS_SRCS    = $(wildcard $(ARDUINO_CORE_PATH)/*.S)

        ifneq ($(strip $(NO_CORE_MAIN_CPP)),)
            CORE_CPP_SRCS := $(filter-out %main.cpp, $(CORE_CPP_SRCS))
            $(call show_config_info,NO_CORE_MAIN_CPP set so core library will not include main.cpp,[MANUAL])
        endif

        CORE_OBJ_FILES  = $(CORE_C_SRCS:.c=.c.o) $(CORE_CPP_SRCS:.cpp=.cpp.o) $(CORE_AS_SRCS:.S=.S.o)
        CORE_OBJS       = $(patsubst $(ARDUINO_CORE_PATH)/%,  \
                $(OBJDIR)/core/%,$(CORE_OBJ_FILES))
    endif
else
    $(call show_config_info,NO_CORE set so core library will not be built,[MANUAL])
endif


########################################################################
# Determine ARDUINO_LIBS automatically
## This algorithm sed's through the includes in the .ino file and looks for 
## directories named the same. Only some libs match, many are named differently and missed 
## 
## TODO: make better algorithm, this on does a poor job, set ARDUINO_LIBS manually for now
# ifndef ARDUINO_LIBS
#     # automatically determine included libraries
#     ARDUINO_LIBS += $(filter $(notdir $(wildcard $(ARDUINO_DIR)/libraries/*)), \
#         $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
#     ARDUINO_LIBS += $(filter $(notdir $(wildcard $(ARDUINO_SKETCHBOOK)/libraries/*)), \
#         $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
#     ARDUINO_LIBS += $(filter $(notdir $(wildcard $(USER_LIB_PATH)/*)), \
#         $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
#     ARDUINO_LIBS += $(filter $(notdir $(wildcard $(ARDUINO_PLATFORM_LIB_PATH)/*)), \
#         $(shell sed -ne 's/^ *\# *include *[<\"]\(.*\)\.h[>\"]/\1/p' $(LOCAL_SRCS)))
# endif

########################################################################
# Serial monitor (just a screen wrapper)

# Quite how to construct the monitor command seems intimately tied
# to the command we're using (here screen). So, read the screen docs
# for more information (search for 'character special device').

ifeq ($(strip $(NO_CORE)),)
    ifndef MONITOR_BAUDRATE
        ifeq ($(words $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS)), 1)
            SPEED = $(shell egrep -h 'Serial.begin *\([0-9]+\)' $(LOCAL_PDE_SRCS) $(LOCAL_INO_SRCS) | sed -e 's/[^0-9]//g'| head -n1)
            MONITOR_BAUDRATE = $(findstring $(SPEED),300 1200 2400 4800 9600 14400 19200 28800 38400 57600 115200)
        endif

        ifeq ($(MONITOR_BAUDRATE),)
            MONITOR_BAUDRATE = 9600
            $(call show_config_variable,MONITOR_BAUDRATE,[ASSUMED])
        else
            $(call show_config_variable,MONITOR_BAUDRATE,[DETECTED], (in sketch))
        endif
    else
        $(call show_config_variable,MONITOR_BAUDRATE, [USER])
    endif

    ifndef MONITOR_CMD
        MONITOR_CMD = screen
    endif
endif

########################################################################
# Include Arduino Header file

ifndef ARDUINO_HEADER
    # We should check for Arduino version, not just the file extension
    # because, a .pde file can be used in Arduino 1.0 as well
    ifeq ($(shell expr $(ARDUINO_VERSION) '<' 100), 1)
        ARDUINO_HEADER=WProgram.h
    else
        ARDUINO_HEADER=Arduino.h
    endif
endif

########################################################################
# Rules for making stuff

# The name of the main targets
TARGET_HEX = $(OBJDIR)/$(TARGET).bin
TARGET_ELF = $(OBJDIR)/$(TARGET).elf
#TARGET_EEP = $(OBJDIR)/$(TARGET).eep
TARGET_FS = $(OBJDIR)/$(TARGET).spiffs
CORE_LIB   = $(OBJDIR)/libcore.a

# Names of executables - chipKIT needs to override all to set paths to PIC32
# tools, and we can't use "?=" assignment because these are already implicitly
# defined by Make (e.g. $(CC) == cc).
ifndef OVERRIDE_EXECUTABLES
    CC      = $(TOOLS_PATH)/$(CC_NAME)
    CXX     = $(TOOLS_PATH)/$(CXX_NAME)
    AS      = $(TOOLS_PATH)/$(AS_NAME)
    OBJCOPY = $(TOOLS_PATH)/$(OBJCOPY_NAME)
    OBJDUMP = $(TOOLS_PATH)/$(OBJDUMP_NAME)
    AR      = $(TOOLS_PATH)/$(AR_NAME)
    SIZE    = $(TOOLS_PATH)/$(SIZE_NAME)
    NM      = $(TOOLS_PATH)/$(NM_NAME)
endif

REMOVE  = rm -rf
MV      = mv -f
CAT     = cat
ECHO    = printf
MKDIR   = mkdir -p

# recursive wildcard function, call with params:
#  - start directory (finished with /) or empty string for current dir
#  - glob pattern
# (taken from http://blog.jgc.org/2011/07/gnu-make-recursive-wildcard-function.html)
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

# functions used to determine various properties of library
# called with library path. Needed because of differences between library
# layouts in arduino 1.0.x and 1.5.x.
# Assuming new 1.5.x layout when there is "src" subdirectory in main directory
# and library.properties file

# Gets include flags for library
get_library_includes = $(if $(and $(wildcard $(1)/src), $(wildcard $(1)/library.properties)), \
                           -I$(1)/src, \
                           $(addprefix -I,$(1) $(wildcard $(1)/utility)))

# Gets all sources with given extension (param2) for library (path = param1)
# for old (1.0.x) layout looks in . and "utility" directories
# for new (1.5.x) layout looks in src and recursively its subdirectories
get_library_files  = $(if $(and $(wildcard $(1)/src), $(wildcard $(1)/library.properties)), \
                        $(call rwildcard,$(1)/src/,*.$(2)), \
                        $(wildcard $(1)/*.$(2) $(1)/utility/*.$(2)))

#$(info "USER_LIB_PATH is " $(USER_LIB_PATH))
#$(info "ARDUINO_LIBS is " $(ARDUINO_LIBS))

# General arguments
USER_LIBS      := $(sort $(wildcard $(patsubst %,$(USER_LIB_PATH)/%,$(ARDUINO_LIBS))))
USER_LIB_NAMES := $(patsubst $(USER_LIB_PATH)/%,%,$(USER_LIBS))

# Let user libraries override system ones.
SYS_LIBS       := $(sort $(wildcard $(patsubst %,$(ARDUINO_LIB_PATH)/%,$(filter-out $(USER_LIB_NAMES),$(ARDUINO_LIBS)))))
SYS_LIB_NAMES  := $(patsubst $(ARDUINO_LIB_PATH)/%,%,$(SYS_LIBS))

ifdef ARDUINO_PLATFORM_LIB_PATH
    PLATFORM_LIBS       := $(sort $(wildcard $(patsubst %,$(ARDUINO_PLATFORM_LIB_PATH)/%,$(filter-out $(USER_LIB_NAMES),$(ARDUINO_LIBS)))))
    PLATFORM_LIB_NAMES  := $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%,%,$(PLATFORM_LIBS))
endif

# Error here if any are missing.
LIBS_NOT_FOUND = $(filter-out $(USER_LIB_NAMES) $(SYS_LIB_NAMES) $(PLATFORM_LIB_NAMES),$(ARDUINO_LIBS))
ifneq (,$(strip $(LIBS_NOT_FOUND)))
    ifdef ARDUINO_PLATFORM_LIB_PATH
        $(error The following libraries specified in ARDUINO_LIBS could not be found (searched USER_LIB_PATH, ARDUINO_LIB_PATH and ARDUINO_PLATFORM_LIB_PATH): $(LIBS_NOT_FOUND))
    else
        $(error The following libraries specified in ARDUINO_LIBS could not be found (searched USER_LIB_PATH and ARDUINO_LIB_PATH): $(LIBS_NOT_FOUND))
    endif
endif


SYS_INCLUDES        := $(foreach lib, $(SYS_LIBS),  $(call get_library_includes,$(lib)))
USER_INCLUDES       := $(foreach lib, $(USER_LIBS), $(call get_library_includes,$(lib)))
LIB_C_SRCS          := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),c))
LIB_CPP_SRCS        := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),cpp))
LIB_AS_SRCS         := $(foreach lib, $(SYS_LIBS),  $(call get_library_files,$(lib),S))
USER_LIB_CPP_SRCS   := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),cpp))
USER_LIB_C_SRCS     := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),c))
USER_LIB_AS_SRCS    := $(foreach lib, $(USER_LIBS), $(call get_library_files,$(lib),S))
LIB_OBJS            = $(patsubst $(ARDUINO_LIB_PATH)/%.c,$(OBJDIR)/libs/%.c.o,$(LIB_C_SRCS)) \
                      $(patsubst $(ARDUINO_LIB_PATH)/%.cpp,$(OBJDIR)/libs/%.cpp.o,$(LIB_CPP_SRCS)) \
                      $(patsubst $(ARDUINO_LIB_PATH)/%.S,$(OBJDIR)/libs/%.S.o,$(LIB_AS_SRCS))
USER_LIB_OBJS       = $(patsubst $(USER_LIB_PATH)/%.cpp,$(OBJDIR)/userlibs/%.cpp.o,$(USER_LIB_CPP_SRCS)) \
                      $(patsubst $(USER_LIB_PATH)/%.c,$(OBJDIR)/userlibs/%.c.o,$(USER_LIB_C_SRCS)) \
                      $(patsubst $(USER_LIB_PATH)/%.S,$(OBJDIR)/userlibs/%.S.o,$(USER_LIB_AS_SRCS))

ifdef ARDUINO_PLATFORM_LIB_PATH
    PLATFORM_INCLUDES     := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_includes,$(lib)))
    PLATFORM_LIB_CPP_SRCS := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),cpp))
    PLATFORM_LIB_C_SRCS   := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),c))
    PLATFORM_LIB_AS_SRCS  := $(foreach lib, $(PLATFORM_LIBS), $(call get_library_files,$(lib),S))
    PLATFORM_LIB_OBJS     := $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%.cpp,$(OBJDIR)/platformlibs/%.cpp.o,$(PLATFORM_LIB_CPP_SRCS)) \
                             $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%.c,$(OBJDIR)/platformlibs/%.c.o,$(PLATFORM_LIB_C_SRCS)) \
                             $(patsubst $(ARDUINO_PLATFORM_LIB_PATH)/%.S,$(OBJDIR)/platformlibs/%.S.o,$(PLATFORM_LIB_AS_SRCS))

endif

ALL_INCLUDES      += -I$(ARDUINO_CORE_PATH) -I$(ARDUINO_VAR_PATH)/$(VARIANT) $(SYS_INCLUDES) $(PLATFORM_INCLUDES) $(USER_INCLUDES) 

# Dependency files
DEPS                = $(LOCAL_OBJS:.o=.d) $(LIB_OBJS:.o=.d) $(PLATFORM_OBJS:.o=.d) $(USER_LIB_OBJS:.o=.d) $(CORE_OBJS:.o=.d)

ifndef DEBUG_FLAGS
    DEBUG_FLAGS = -O0 -g
endif

# Using += instead of =, so that CPPFLAGS can be set per sketch level
CPPFLAGS += -D__ets__ -DICACHE_FLASH -U__STRICT_ANSI__  
CPPFLAGS += "-I$(TOOLS_DIR)/sdk/include" "-I$(TOOLS_DIR)/sdk/lwip/include" "-I$(TOOLS_DIR)/sdk/libc/xtensa-lx106-elf/include"
CPPFLAGS += -w -DF_CPU=$(F_CPU) -DLWIP_OPEN_SRC -DARDUINO=$(ARDUINO_VERSION) -DARDUINO_$(BOARD) -DARDUINO_BOARD=\"$(BOARD)\" -DESP8266

# xtensa-gcc version that we can do maths on
CC_VERNUM = $(shell $(CC) -dumpversion | sed 's/\.//g')

ifndef CFLAGS_STD
    #CFLAGS_STD      = -std=gnu99
    CFLAGS_STD = 
    $(call show_config_variable,CFLAGS_STD,[DEFAULT])
else
    $(call show_config_variable,CFLAGS_STD,[USER])
endif

ifndef CXXFLAGS_STD
    #CXXFLAGS_STD      = -std=gnu++11
    CXXFLAGS_STD = 
    $(call show_config_variable,CXXFLAGS_STD,[DEFAULT])
else
    $(call show_config_variable,CXXFLAGS_STD,[USER])
endif

CFLAGS        += $(CFLAGS_STD) $(ALL_INCLUDES)
CXXFLAGS      += $(CXXFLAGS_STD) $(ALL_INCLUDES)
#ASFLAGS       += 
LDFLAGS       += -g $(COMP_WARNINGS) -Os -nostdlib -Wl,--no-check-sections -u call_user_start -u _printf_float -u _scanf_float 
LDFLAGS       += -Wl,-static -Wl,-Map,$(OBJDIR)/$(TARGET).map -Wl,--cref "-L$(TOOLS_DIR)/sdk/lib" "-L$(TOOLS_DIR)/sdk/ld" "-L$(TOOLS_DIR)/sdk/libc/xtensa-lx106-elf/lib" 
LDFLAGS       += $(LINKER_SCRIPTS)
LDFLAGS       += -Wl,--gc-sections -Wl,-wrap,system_restart_local -Wl,-wrap,spi_flash_read 
SIZEFLAGS     ?= -C

# for backwards compatibility, grab ARDUINO_PORT if the user has it set
# instead of MONITOR_PORT
MONITOR_PORT ?= $(ARDUINO_PORT)

ifneq ($(strip $(MONITOR_PORT)),)
    ifeq ($(CURRENT_OS), WINDOWS)
        # Expect MONITOR_PORT to be '1' or 'com1' for COM1 in Windows. Split it up
        # into the two styles required: /dev/ttyS* for ard-reset-arduino and com*
        # for avrdude. This also could work with /dev/com* device names and be more
        # consistent, but the /dev/com* is not recommended by Cygwin and doesn't
        # always show up.
        COM_PORT_ID = $(subst com,,$(MONITOR_PORT))
        COM_STYLE_MONITOR_PORT = com$(COM_PORT_ID)
        DEVICE_PATH = /dev/ttyS$(shell awk 'BEGIN{ print $(COM_PORT_ID) - 1 }')
    else
        # set DEVICE_PATH based on user-defined MONITOR_PORT or ARDUINO_PORT
        DEVICE_PATH = $(MONITOR_PORT)
    endif
    $(call show_config_variable,DEVICE_PATH,[COMPUTED],(from MONITOR_PORT))
else
    # If no port is specified, try to guess it from wildcards.
    # Will only work if the Arduino is the only/first device matched.
    DEVICE_PATH = $(firstword $(wildcard \
			/dev/ttyACM? /dev/ttyUSB? /dev/tty.usbserial* /dev/tty.usbmodem* /dev/tty.wchusbserial*))
    $(call show_config_variable,DEVICE_PATH,[AUTODETECTED])
endif

ifndef FORCE_MONITOR_PORT
    $(call show_config_variable,FORCE_MONITOR_PORT,[DEFAULT])
else
    $(call show_config_variable,FORCE_MONITOR_PORT,[USER])
endif

ifdef FORCE_MONITOR_PORT
    # Skips the DEVICE_PATH existance check.
    get_monitor_port = $(DEVICE_PATH)
else
    # Returns the Arduino port (first wildcard expansion) if it exists, otherwise it errors.
    ifeq ($(CURRENT_OS), WINDOWS)
        get_monitor_port = $(COM_STYLE_MONITOR_PORT)
    else
        get_monitor_port = $(if $(wildcard $(DEVICE_PATH)),$(firstword $(wildcard $(DEVICE_PATH))),$(error Arduino port $(DEVICE_PATH) not found!))
    endif
endif

# Command for esp_size: do $(call esp_size,elffile)
#esp_size = $(SIZE) -A $(1) | perl -e "$$MEM_USAGE" "^(?:\.irom0\.text|\.text|\.data|\.rodata|)\s+([0-9]+).*" "^(?:\.data|\.rodata|\.bss)\s+([0-9]+).*"
esp_size = $(SIZE) -A $(1) | perl -e "$$MEM_USAGE" "^(?:\.irom0\.text|\.text|\.data|\.rodata|)\s+([0-9]+).*" "^(?:\.data|\.rodata|\.bss)\s+([0-9]+).*" "^(?:\.data|)\s+([0-9]+).*" "^(?:\.rodata|)\s+([0-9]+).*" "^(?:\.bss|)\s+([0-9]+).*" "^(?:\.text|)\s+([0-9]+).*" "^(?:\.irom0\.text|)\s+([0-9]+).*"

ifneq (,$(strip $(ARDUINO_LIBS)))
    $(call arduino_output,-)
    $(call show_config_info,ARDUINO_LIBS =)
endif

ifneq (,$(strip $(USER_LIB_NAMES)))
    $(foreach lib,$(USER_LIB_NAMES),$(call show_config_info,  $(lib),[USER]))
endif

ifneq (,$(strip $(SYS_LIB_NAMES)))
    $(foreach lib,$(SYS_LIB_NAMES),$(call show_config_info,  $(lib),[SYSTEM]))
endif

ifneq (,$(strip $(PLATFORM_LIB_NAMES)))
    $(foreach lib,$(PLATFORM_LIB_NAMES),$(call show_config_info,  $(lib),[PLATFORM]))
endif

# either calculate parent dir from arduino dir, or user-defined path
ifndef BOOTLOADER_PARENT
    BOOTLOADER_PARENT = $(ARDUINO_DIR)/hardware/$(ARDMK_VENDOR)/$(ARCHITECTURE)/bootloaders
    $(call show_config_variable,BOOTLOADER_PARENT,[COMPUTED],(from ARDUINO_DIR))
else
    $(call show_config_variable,BOOTLOADER_PARENT,[USER])
endif

########################################################################
# Bootloader tool ESPTOOL

ifndef ESP_FLASH_MODE
	ESP_FLASH_MODE := $(call PARSE_BOARD,$(BOARD_TAG),build.flash_mode)
	ifeq (,$strip($(ESP_FLASH_MODE)))
		ESP_FLASH_MODE = qio
	endif
endif

ifndef ESP_FLASH_FREQ
	ESP_FLASH_FREQ := $(call PARSE_BOARD,$(BOARD_TAG),build.flash_freq)
    #$(info $(ESP_FLASH_FREQ))
	ifeq (,$strip($(ESP_FLASH_FREQ)))
		ESP_FLASH_FREQ = 40
	endif
endif

ifndef ESP_UPLOAD_SPEED
	ESP_UPLOAD_SPEED := $(call PARSE_BOARD,$(BOARD_TAG),upload.speed)
	ifeq (,$strip($(ESP_UPLOAD_SPEED)))
		ESP_UPLOAD_SPEED = 115200
	endif
endif

ifndef ESP_UPLOAD_RESETMETHOD
	ESP_UPLOAD_RESETMETHOD := $(call PARSE_BOARD,$(BOARD_TAG),upload.resetmethod)
	ifeq (,$strip($(ESP_UPLOAD_RESETMETHOD)))
		ESP_UPLOAD_RESETMETHOD = 115200
	endif
endif

ESP_OTA_ADDR ?= 192.168.1.1
ESP_OTA_PORT ?= 8266
ESP_OTA_PWD ?= ""
FS_DIR ?= $(CURDIR)/data

ifndef ESPTOOL
    ESPTOOL          := $(TOOLS_DIR)/esptool/esptool
    ifeq (,$(wildcard $(ESPTOOL)))
    	$(error ESPTOOL not found at $(ESPTOOL))
    endif
    $(call show_config_variable,ESPTOOL,[COMPUTED])
endif

ifndef ESPTOOL_OPTS
	ESPTOOL_OPTS := 
endif

ifndef ESPTOOL_UPLOAD_OPTS
	ESPTOOL_UPLOAD_OPTS := -v -cd $(ESP_UPLOAD_RESETMETHOD) -cb $(MONITOR_BAUDRATE) -cp "$(DEVICE_PATH)" -ca 0x00000 
endif

ifndef ESPTOOL_UPLOAD_FS_OPTS
	ESPTOOL_UPLOAD_FS_OPTS := -v -cd $(ESP_UPLOAD_RESETMETHOD) -cb $(MONITOR_BAUDRATE) -cp "$(DEVICE_PATH)" -ca 0x100000
endif

ifndef OTATOOL
    OTATOOL          := $(TOOLS_DIR)/espota.py
    ifeq (,$(wildcard $(OTATOOL)))
    	$(warning OTATOOL not found at $(OTATOOL))
    endif
    $(call show_config_variable,OTATOOL,[COMPUTED])
endif

ifndef OTATOOL_UPLOAD_OPTS
	OTATOOL_UPLOAD_OPTS := -i $(ESP_OTA_ADDR) -p $(ESP_OTA_PORT) -a $(ESP_OTA_PWD)
endif

ifndef OTATOOL_UPLOAD_FS_OPTS
	OTATOOL_UPLOAD_FS_OPTS := $(OTATOOL_UPLOAD_OPTS) -s
endif

ifndef FSTOOL
	FSTOOL := $(TOOLS_DIR)/mkspiffs/mkspiffs
endif

ifndef FSTOOL_OPTS
	FSTOOL_OPTS := -b 8192 -s 0x2FB000
endif

########################################################################
# Tools version info
ARDMK_VERSION = 1.5
$(call show_config_variable,ARDMK_VERSION,[COMPUTED])

CC_VERSION := $(shell $(CC) -dumpversion)
$(call show_config_variable,CC_VERSION,[COMPUTED],($(CC_NAME)))

# end of config output
$(call show_separator)

# Implicit rules for building everything (needed to get everything in
# the right directory)
#
# Rather than mess around with VPATH there are quasi-duplicate rules
# here for building e.g. a system C++ file and a local C++
# file. Besides making things simpler now, this would also make it
# easy to change the build options in future

# library sources
$(OBJDIR)/libs/%.c.o: $(ARDUINO_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/libs/%.cpp.o: $(ARDUINO_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/libs/%.S.o: $(ARDUINO_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.c.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.cpp.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/platformlibs/%.S.o: $(ARDUINO_PLATFORM_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.cpp.o: $(USER_LIB_PATH)/%.cpp
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.c.o: $(USER_LIB_PATH)/%.c
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/userlibs/%.S.o: $(USER_LIB_PATH)/%.S
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

ifdef COMMON_DEPS
    COMMON_DEPS := $(COMMON_DEPS) $(MAKEFILE_LIST)
else
    COMMON_DEPS := $(MAKEFILE_LIST)
endif

# normal local sources
$(OBJDIR)/%.c.o: %.c $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

# $(OBJDIR)/%.cc.o: %.cc $(COMMON_DEPS) | $(OBJDIR)
# 	@$(MKDIR) $(dir $@)
# 	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.cpp.o: %.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -w -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.S.o: %.S $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.s.o: %.s $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

# the pde -> o file
# $(OBJDIR)/%.pde.o: %.pde $(COMMON_DEPS) | $(OBJDIR)
# 	@$(MKDIR) $(dir $@)
# 	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# the ino -> o file
$(OBJDIR)/%.ino.o: %.ino $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -w $(CPPFLAGS) $(CXXFLAGS) -x c++ -include $(ARDUINO_CORE_PATH)/Arduino.h $< -o $@

# generated assembly
$(OBJDIR)/%.s: %.pde $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -S -fverbose-asm $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.s: %.ino $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -include $(ARDUINO_HEADER) -MMD -S -fverbose-asm $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/%.s: %.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -x c++ -MMD -S -fverbose-asm $(CPPFLAGS) $(CXXFLAGS) $< -o $@

# core files
$(OBJDIR)/core/%.c.o: $(ARDUINO_CORE_PATH)/%.c $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(OBJDIR)/core/%.cpp.o: $(ARDUINO_CORE_PATH)/%.cpp $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CXX) -MMD -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(OBJDIR)/core/%.S.o: $(ARDUINO_CORE_PATH)/%.S $(COMMON_DEPS) | $(OBJDIR)
	@$(MKDIR) $(dir $@)
	$(CC) -MMD -c $(CPPFLAGS) $(ASFLAGS) $< -o $@

$(OBJDIR)/%.bin: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(ESPTOOL) $(ESPTOOL_OPTS) -eo "$(BOOTLOADER_PARENT)/eboot/eboot.elf" -bo "$@" \
	    -bm $(ESP_FLASH_MODE) -bf $(ESP_FLASH_FREQ) -bz $(ESP_FLASHSIZE) -bs .text \
	    -bp 4096 -ec -eo "$<" -bs .irom0.text -bs .text -bs .data -bs .rodata -bc -ec
	@$(ECHO) '\n'
	$(call esp_size,$<)
	# TODO: add size verification
# various object conversions
# $(OBJDIR)/%.hex: $(OBJDIR)/%.elf $(COMMON_DEPS)
# 	@$(MKDIR) $(dir $@)
# 	$(OBJCOPY) -O ihex -R .eeprom $< $@
# 	@$(ECHO) '\n'
# 	$(call avr_size,$<,$@)
# ifneq ($(strip $(HEX_MAXIMUM_SIZE)),)
# 	@if [ `$(SIZE) $@ | awk 'FNR == 2 {print $$2}'` -le $(HEX_MAXIMUM_SIZE) ]; then touch $@.sizeok; fi
# else
# 	@$(ECHO) "Maximum flash memory of $(BOARD_TAG) is not specified. Make sure the size of $@ is less than $(BOARD_TAG)\'s flash memory"
# 	@touch $@.sizeok
# endif

# $(OBJDIR)/%.eep: $(OBJDIR)/%.elf $(COMMON_DEPS)
# 	@$(MKDIR) $(dir $@)
# 	@$(ECHO) "test1"
# 	-$(OBJCOPY) -j .eeprom --set-section-flags=.eeprom='alloc,load' \
# 		--no-change-warnings --change-section-lma .eeprom=0 -O ihex $< $@
# 	@$(ECHO) "test2"

$(OBJDIR)/%.lss: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(OBJDUMP) -h --source --demangle --wide $< > $@

$(OBJDIR)/%.sym: $(OBJDIR)/%.elf $(COMMON_DEPS)
	@$(MKDIR) $(dir $@)
	$(NM) --size-sort --demangle --reverse-sort --line-numbers $< > $@

########################################################################
# Explicit targets start here

all: 		$(TARGET_ELF) $(TARGET_HEX)

# Rule to create $(OBJDIR) automatically. All rules with recipes that
# create a file within it, but do not already depend on a file within it
# should depend on this rule. They should use a "order-only
# prerequisite" (e.g., put "| $(OBJDIR)" at the end of the prerequisite
# list) to prevent remaking the target when any file in the directory
# changes.
$(OBJDIR): pre-build
		$(MKDIR) $(OBJDIR)

pre-build:
		$(call runscript_if_exists,$(PRE_BUILD_HOOK))

$(TARGET_ELF): 	$(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS)
		$(CC) $(LDFLAGS) -o $@ -Wl,--start-group $(LOCAL_OBJS) $(CORE_LIB) $(OTHER_OBJS) $(OTHER_LIBS) -lc -lm -Wl,--end-group 
$(CORE_LIB):	$(CORE_OBJS) $(LIB_OBJS) $(PLATFORM_LIB_OBJS) $(USER_LIB_OBJS)
		$(AR) cru $@ $(CORE_OBJS) $(LIB_OBJS) $(PLATFORM_LIB_OBJS) $(USER_LIB_OBJS)

$(TARGET_FS): 
		$(FSTOOL) $(FSTOOL_OPTS) -c $(FS_DIR) $(TARGET_FS) 

fs:		$(TARGET_FS)

upload:		$(TARGET_HEX) 
		$(ESPTOOL) $(ESPTOOL_UPLOAD_OPTS) -cf $(TARGET_HEX)

upload_fs:		$(TARGET_FS) 
		$(ESPTOOL) $(ESPTOOL_UPLOAD_FS_OPTS) -cf $(TARGET_FS)

upload_ota:		$(TARGET_HEX) 
		$(OTATOOL) $(OTATOOL_UPLOAD_OPTS) -f $(TARGET_HEX)

upload_fs_ota:		$(TARGET_FS) 
		$(OTATOOL) $(OTATOOL_UPLOAD_FS_OPTS) -f $(TARGET_FS)

clean::
		$(REMOVE) $(OBJDIR)

size:	$(TARGET_HEX)
		$(call esp_size,$(TARGET_ELF))

show_boards:
		@$(CAT) $(BOARDS_TXT) | grep -E '^[a-zA-Z0-9_\-]+.name' | sort -uf | sed 's/.name=/:/' | column -s: -t

show_submenu:
	@$(CAT) $(BOARDS_TXT) | grep -E '[a-zA-Z0-9_\-]+.menu.(cpu|chip).[a-zA-Z0-9_\-]+=' | sort -uf | sed 's/.menu.\(cpu\|chip\)./:/' | sed 's/=/:/' | column -s: -t

monitor:
ifeq ($(MONITOR_CMD), 'putty')
	ifneq ($(strip $(MONITOR_PARAMS)),)
	$(MONITOR_CMD) -serial -sercfg $(MONITOR_BAUDRATE),$(MONITOR_PARAMS) $(call get_monitor_port)
	else
	$(MONITOR_CMD) -serial -sercfg $(MONITOR_BAUDRATE) $(call get_monitor_port)
	endif
else ifeq ($(MONITOR_CMD), picocom)
		$(MONITOR_CMD) -b $(MONITOR_BAUDRATE) $(MONITOR_PARAMS) $(call get_monitor_port)
else ifeq ($(MONITOR_CMD), cu)
		$(MONITOR_CMD) -l $(call get_monitor_port) -s $(MONITOR_BAUDRATE)
else
		$(MONITOR_CMD) $(call get_monitor_port) $(MONITOR_BAUDRATE)
endif

disasm: $(OBJDIR)/$(TARGET).lss
		@$(ECHO) "The compiled ELF file has been disassembled to $(OBJDIR)/$(TARGET).lss\n\n"

symbol_sizes: $(OBJDIR)/$(TARGET).sym
		@$(ECHO) "A symbol listing sorted by their size have been dumped to $(OBJDIR)/$(TARGET).sym\n\n"

verify_size:
	$(error Not implemented yet)
ifeq ($(strip $(HEX_MAXIMUM_SIZE)),)
	@$(ECHO) "\nMaximum flash memory of $(BOARD_TAG) is not specified. Make sure the size of $(TARGET_HEX) is less than $(BOARD_TAG)\'s flash memory\n\n"
endif
	@if [ ! -f $(TARGET_HEX).sizeok ]; then echo >&2 "\nThe size of the compiled binary file is greater than the $(BOARD_TAG)'s flash memory. \
See http://www.arduino.cc/en/Guide/Troubleshooting#size for tips on reducing it."; false; fi

generate_assembly: $(OBJDIR)/$(TARGET).s
		@$(ECHO) "Compiler-generated assembly for the main input source has been dumped to $(OBJDIR)/$(TARGET).s\n\n"

generated_assembly: generate_assembly
		@$(ECHO) "\"generated_assembly\" target is deprecated. Use \"generate_assembly\" target instead\n\n"

help_vars:
		@$(CAT) $(ARDMK_DIR)/arduino-mk-vars.md

help:
		@$(ECHO) "\nAvailable targets:\n\
  make                   - compile the code\n\
  make upload            - upload\n\
  make upload_ota        - upload Over-The-Air\n\
  make fs                - create binary image of filesystem\n\
  make upload_fs         - upload filesystem (TODO)\n\
  make upload_fs_ota     - upload filesystem Over-The-Air\n\
  make clean             - remove all our dependencies\n\
  make depends           - update dependencies\n\
  make show_boards       - list all the boards defined in boards.txt\n\
  make show_submenu      - list all board submenus defined in boards.txt\n\
  make monitor           - connect to the Arduino's serial port\n\
  make size              - show the size of the compiled output (relative to\n\
                           resources, if you have a patched avr-size).\n\
  make verify_size       - verify that the size of the final file is less than\n\
                           the capacity of the micro controller.\n\
  make symbol_sizes      - generate a .sym file containing symbols and their\n\
                           sizes.\n\
  make disasm            - generate a .lss file that contains disassembly\n\
                           of the compiled file interspersed with your\n\
                           original source code.\n\
  make generate_assembly - generate a .s file containing the compiler\n\
                           generated assembly of the main sketch.\n\
  make help_vars         - print all variables that can be overridden\n\
  make help              - show this help\n\
"
	@$(ECHO) "Please refer to $(ARDMK_DIR)/Arduino.mk for more details.\n"

.PHONY: all upload upload_ota fs upload_fs upload_fs_ota \
        clean depends size show_boards monitor disasm symbol_sizes generated_assembly \
        generate_assembly verify_size burn_bootloader help pre-build

# added - in the beginning, so that we don't get an error if the file is not present
-include $(DEPS)

# Convert memory information
define MEM_USAGE
$$fp = shift;
$$rp = shift;
$$datap = shift;
$$rodatap = shift;
$$bssp = shift;
$$textp = shift;
$$irom0textp = shift;

while (<>) {
  $$r += $$1 if /$$rp/;
  $$f += $$1 if /$$fp/;
  $$data += $$1 if /$$datap/;;
  $$rodata += $$1 if /$$rodatap/;
  $$bss += $$1 if /$$bssp/;
  $$text += $$1 if /$$textp/;
  $$irom0text += $$1 if /$$irom0textp/;
}
print "\nMemory usage\n";
#print sprintf("  %-6s %6d bytes\n" x 2 ."\n", "Ram:", $$r, "Flash:", $$f);
print sprintf("  %-6s %6d bytes\n", "Ram:", $$r);
print sprintf("    %-12s %6d bytes\n" x 3 , ".data:", $$data, ".rodata:", $$rodata, ".bss:", $$bss);
print sprintf("  %-6s %6d bytes\n", "Flash:", $$f);
print sprintf("    %-12s %6d bytes\n" x 4 ."\n", ".data:", $$data, ".rodata:", $$rodata, ".text:", $$text, ".irom0.text:", $$irom0text);
endef
export MEM_USAGE