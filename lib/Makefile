TARGET = idlvideo
SRC = $(TARGET).c

SYS  = $(shell uname -s | tr '[:upper:]' '[:lower:]')
ARCH = $(shell uname -m)
LIBRARY = $(TARGET).$(SYS).$(ARCH).so

DLM = $(TARGET).dlm

IDL = idl -quiet
INSTALL = install
DESTINATION = lib

all: $(LIBRARY)

$(LIBRARY): $(SRC)
	@mkdir build 2>/dev/null ||:
	@$(IDL) compile_$(TARGET)

install: $(LIBRARY) $(DLM)
	sudo $(INSTALL) -d $(DESTINATION)
	sudo $(INSTALL) $(LIBRARY) $(DLM) $(DESTINATION)

uninstall:
	sudo rm -rf $(DESTINATION)

clean:
	-rm $(LIBRARY)
	-rm build
