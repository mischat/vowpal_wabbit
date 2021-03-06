COMPILER = g++
UNAME := $(shell uname)

ifeq ($(UNAME), FreeBSD)
LIBS = -l boost_program_options	-l pthread -l z -l compat -l allreduce
BOOST_INCLUDE = /usr/local/include
BOOST_LIBRARY = /usr/local/lib
else
LIBS = -l boost_program_options -l pthread -l z -l allreduce
BOOST_INCLUDE = /usr/include
BOOST_LIBRARY = /usr/local/lib
endif

ARCH = $(shell test `g++ -v 2>&1 | tail -1 | cut -d ' ' -f 3 | cut -d '.' -f 1,2` \< 4.3 && echo -march=nocona || echo -march=native)

#LIBS = -l boost_program_options-gcc34 -l pthread -l z

OPTIM_FLAGS = -O3 -fomit-frame-pointer -ffast-math -fno-strict-aliasing
ifeq ($(UNAME), FreeBSD)
WARN_FLAGS = -Wall
else
WARN_FLAGS = -Wall -pedantic
endif

# for normal fast execution.
FLAGS = $(ARCH) $(WARN_FLAGS) $(OPTIM_FLAGS) -D_FILE_OFFSET_BITS=64 -I $(BOOST_INCLUDE) #-DVW_LDA_NO_SSE

# for profiling
#FLAGS = -Wall $(ARCH) -ffast-math -D_FILE_OFFSET_BITS=64 -I $(BOOST_INCLUDE) -pg -g

# for valgrind
#FLAGS = -Wall $(ARCH) -ffast-math -D_FILE_OFFSET_BITS=64 -I $(BOOST_INCLUDE) -g -O0

BINARIES = vw active_interactor
MANPAGES = vw.1

all:	vw spanning_tree 

%.1:	%
	help2man --no-info --name="Vowpal Wabbit -- fast online learning tool" ./$< > $@

export

spanning_tree: 
	cd cluster; $(MAKE); cd ..

vw:
	cd vowpalwabbit; $(MAKE); cd ..

.FORCE:

test: .FORCE
	@echo "vw running test-suite..."
	@(cd test && ./RunTests -f -E 0.001 ../vowpalwabbit/vw ../vowpalwabbit/vw)

install: $(BINARIES)
	cp $(BINARIES) /usr/local/bin; cd cluster; $(MAKE) install

clean:
	cd vowpalwabbit; $(MAKE) clean; cd ..; cd cluster; $(MAKE) clean; cd ..
