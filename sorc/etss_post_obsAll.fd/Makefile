SHELL = /bin/sh

EXEDIR = ../../exec
EXE = etss_post_obsAll

FC=${COMP}
FCFLAGS=-assume no2underscore

SRC = numlines.f defgridstns.f combineObs.f
OBJS = $(addsuffix .o,$(basename $(SRC)))

all: $(EXE)

$(EXE): $(OBJS)
	$(FC) $(OBJS) -o $(EXE)

install: $(EXE)
	mv $(EXE) $(EXEDIR)

%.o: %.f
	$(FC) $(FCFLAGS) -c $?

clean:
	rm -f *.o *.a *.bak *.mod $(EXE)
