
ROOT=.
include deps/readies/mk/defs

BINDIR=$(BINROOT)/src

#---------------------------------------------------------------------------------------------- 

ifeq ($(CUDA),1)
DEPS_FLAGS=
else
DEPS_FLAGS=cpu
endif

TARGET=$(BINDIR)/redisai.so

#---------------------------------------------------------------------------------------------- 

.PHONY: all clean deps fetch pack setup

all: build

include $(MK)/rules

#---------------------------------------------------------------------------------------------- 

#ifeq ($(wildcard $(BINDIR)/Makefile),)
#endif

$(BINDIR)/Makefile : CMakeLists.txt
	$(SHOW)cd $(BINDIR); \
	rel=`python -c "import os; print os.path.relpath('$(PWD)', '$$PWD')"`; \
	cmake -DDEPS_PATH=$$rel/deps $$rel

build: bindirs $(TARGET)

$(TARGET): bindirs deps $(BINDIR)/Makefile
	$(SHOW)$(MAKE) -C $(BINDIR)
	$(SHOW)cd bin; ln -sf ../$(TARGET) $(notdir $(TARGET))

clean:
ifeq ($(ALL),1)
	$(SHOW)rm -rf $(BINROOT)
else
	$(SHOW)$(MAKE) -C $(BINDIR) clean
endif

#---------------------------------------------------------------------------------------------- 

setup:
	@echo System setup...
	$(SHOW)./deps/readies/bin/getpy2
	$(SHOW)./system-setup.py

fetch deps:
	$(SHOW)./get_deps.sh $(DEPS_FLAGS)

#----------------------------------------------------------------------------------------------

pack: BINDIR
	$(SHOW)INTO=$(INTO) BRANCH=$(BRANCH) ./pack.sh

BINDIR: bindirs
	$(SHOW)echo $(BINDIR)>BINDIR

#----------------------------------------------------------------------------------------------

define HELP

make setup # install packages required for build
make fetch # download and prepare dependant modules
make build # build everything
make clean # remove build artifacts
make pack  # create installation packages
make test  # run tests


endef

help:
	$(file >/tmp/help,$(HELP))
	@cat /tmp/help
	@rm -f /tmp/help
