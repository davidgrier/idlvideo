IDLDIR = /usr/local/IDL
PRODIR = $(IDLDIR)/idlvideo
LIBDIR = $(PRODIR)

all: 
	make -C lib

install: all
	make -C idl install DESTINATION=$(PRODIR)
	make -C lib install DESTINATION=$(LIBDIR)

uninstall:
	make -C idl uninstall DESTINATION=$(PRODIR)
	make -C lib uninstall DESTINATION=$(LIBDIR)

docs:
        make -C idl docs

clean:
	make -C idl clean
	make -C lib clean
