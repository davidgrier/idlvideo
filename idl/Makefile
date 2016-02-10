FILES = dgghwvideo__define.pro \
	dgggrvideo__define.pro \
	dgggrvob__define.pro \
	idlsnap.pro

INSTALL = install
DESTINATION = pro

all: install

clean:

install:
	sudo $(INSTALL) -d $(DESTINATION)
	sudo $(INSTALL) -m 644 $(FILES) $(DESTINATION)

uninstall:
	sudo rm $(DESTINATION)/$(FILES)
	sudo rmdir $(DESTINATION)

docs: $(FILES)
	@rm -rf docs
	idl makedocs
