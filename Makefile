SRCDIR=src
BINDIR=bin
COPYDIR=copy
COBCFLAGS=-x -free

NewProjectMakerCobol: $(SRCDIR)/main.cob
	mkdir -p $(BINDIR)
	cobc $(COBCFLAGS) -x -o $(BINDIR)/$@ $(SRCDIR)/main.cob

.PHONY: clean
clean:
	rm -f $(BINDIR)/*