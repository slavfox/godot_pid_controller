# Output colors
ifdef NOCOLOR
NC=
RED=
YELLOW=
GREEN=
ERROR=[ERROR]
INFO=[INFO]
$(info $(INFO) Output coloring is disabled.)
else
RED=$(shell echo -e "\033[1;31m")
YELLOW=$(shell echo -e "\033[1;33m")
GREEN=$(shell echo -e "\033[1;32m")
NC=$(shell echo -e "\033[0m")
INFO=$(GREEN)[INFO]$(NC)
ERROR=$(RED)[ERROR]$(NC)
$(info $(INFO) Output coloring is enabled. Pass NOCOLOR=true to disable.)
endif

ifndef PLATFORM
ifeq ($(OS), Windows_NT)
	PLATFORM=windows
else
ifeq ($(shell uname), Darwin)
	PLATFORM=osx
else
	PLATFORM=linux
endif
endif
endif

ifndef BITS
BITS=64
endif

ifndef TARGET
TARGET=debug
endif

ifndef NO_LLVM
LLVM="use_llvm=True"
else
LLVM=
endif

ifeq ($(PLATFORM),linux)
	build_target=bin/x11/libpidcontroller.so
else
ifeq ($(PLATFORM),windows)
	build_target=bin/win64/libpidcontroller.dll
else
ifeq ($(PLATFORM),osx)
	build_target=bin/osx/libpidcontroller.dylib
else
$(info $(ERROR) Invalid platform: $(PLATFORM))
$(error Invalid platform)
endif
endif
endif

.PHONY: all
all: $(build_target)

.PHONY: submodules
submodules: include/godot-cpp/Makefile

.PHONY: clean
clean:
	@echo -e "$(INFO) Cleaning build files"
	rm -rf src/*.os
	rm -rf include/godot-cpp/bin/

include/godot-cpp/Makefile:
	@echo -e "$(INFO) Initializing git submodules for godot_pid_controller"
	git submodule init
	@echo -e "$(INFO) Updating git submodules for godot_pid_controller"
	git submodule update
	@echo -e "$(INFO) Git submodules for godot_pid_controller successfully updated"

include/godot-cpp/godot_headers/api.json: include/godot-cpp/Makefile
	@echo -e "$(INFO) Updating git submodules for godot-cpp"
	cd include/godot-cpp; git submodule init && git submodule update
	@echo -e "$(INFO) Git submodules for godot-cpp successfully updated"


.PHONY: linux windows mac
linux: bin/x11/libpidcontroller.so
windows64: bin/win64/libpidcontroller.dll
osx: bin/osx/libpidcontroller.dylib

include/godot-cpp/bin/libgodot-cpp.linux.*: include/godot-cpp/godot_headers/api.json
	@echo -e "$(INFO) Compiling godot-cpp bindings for linux - this will take a while"
	cd include/godot-cpp; scons platform=linux generate_bindings=yes bits=$(BITS) target=$(TARGET) $(LLVM) 
	
bin/x11/libpidcontroller.so: include/godot-cpp/bin/libgodot-cpp.linux.*
	@echo -e "$(INFO) Compiling Linux plugin"
	scons platform=linux bits=$(BITS) target=$(TARGET) $(LLVM)


include/godot-cpp/bin/libgodot-cpp.windows.*: include/godot-cpp/godot_headers/api.json
	@echo -e "$(INFO) Compiling godot-cpp bindings for windows - this will take a while"
	cd include/godot-cpp; scons platform=windows generate_bindings=yes bits=$(BITS) target=$(TARGET) $(LLVM) 
	
bin/win64/libpidcontroller.dll: include/godot-cpp/bin/libgodot-cpp.windows.*
	@echo -e "$(INFO) Compiling Windows plugin - this probably doesn't work"
	scons platform=windows bits=$(BITS) target=$(TARGET) $(LLVM)


include/godot-cpp/bin/libgodot-cpp.osx.*:  include/godot-cpp/godot_headers/api.json
	@echo -e "$(INFO) Compiling godot-cpp bindings for osx - this will take a while"
	cd include/godot-cpp; scons platform=osx generate_bindings=yes bits=$(BITS) target=$(TARGET) $(LLVM) 
	
bin/osx/libpidcontroller.dylib: include/godot-cpp/bin/libgodot-cpp.osx.*
	@echo -e "$(INFO) Compiling OSX plugin - this probably doesn't work"
	scons platform=windows bits=$(BITS) target=$(TARGET) $(LLVM)


.PHONY: help
help:
	@echo -e ""
	@echo -e "$(GREEN)Godot PID Controller$(NC)"
	@echo -e "$(GREEN)====================$(NC)"
	@echo -e "\n$(YELLOW)Environment variables$(NC):"
	@echo -e "  $(GREEN)PLATFORM       $(NC)- set to \"linux\" (default), \"windows\" or \"osx\""
	@echo -e "  $(GREEN)TARGET         $(NC)- set to \"debug\" (default) or \"release\""
	@echo -e "  $(GREEN)BITS           $(NC)- set to \"64\" (default) or \"32\""
	@echo -e "  $(GREEN)NO_LLVM        $(NC)- set anything to use g++ instead of LLVM"
	@echo -e "\n$(YELLOW)Commands$(NC):"
	@echo -e "  $(GREEN)make help         $(NC)- display this message"
	@echo -e "  $(GREEN)make              $(NC)- build $(build_target) for platform: $(PLATFORM)"
	@echo -e "  $(GREEN)make linux        $(NC)- build for linux"
	@echo -e "  $(GREEN)make windows      $(NC)- build for windows"
	@echo -e "  $(GREEN)make osx          $(NC)- build for osx"
