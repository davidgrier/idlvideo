IDLDIR = /usr/local/IDL
PRODIR = $(IDLDIR)/idlvideo
LIBDIR = $(PRODIR)

VERSION = 1.0.0
RELEASE = 1

CIDESC = --pkgname=idlvideo \
	--pkgversion=$(VERSION) \
	--pkgrelease=$(RELEASE) \
	--pkglicense=GPL \
	--maintainer=david.grier@nyu.edu \
	--provides=idlvideo \
	--nodoc

CIOPTS = -D --install=yes $(CIDESC)

all: 
	make -C lib

deb: all
	sudo checkinstall $(CIOPTS)

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
