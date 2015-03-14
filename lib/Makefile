SRCS = idlvideo.c
DLM = idlvideo.dlm
IDL = idl -quiet
INSTALL = install
DESTINATION = lib

all: library

library: $(SRCS)
	@mkdir build 2>/dev/null ||:
	@$(IDL) compile_idlvideo

install: all
	sudo $(INSTALL) -d $(DESTINATION)
	sudo $(INSTALL) *.so $(DLM) $(DESTINATION)

uninstall:
	sudo rm -rf $(DESTINATION)

clean:
	-rm $(TARGET)
	-rm build
