
ROOT=.
include build/mk/defs

BINDIR=$(BINROOT)/src

#---------------------------------------------------------------------------------------------- 

ifeq ($(CUDA),1)
DEPS_FLAGS=
else
DEPS_FLAGS=cpu
endif

TARGET=$(BINDIR)/redisai.so

#---------------------------------------------------------------------------------------------- 

.PHONY: all clean deps pack setup

all: build

include $(MK)/rules

#---------------------------------------------------------------------------------------------- 

#ifeq ($(wildcard $(BINDIR)/Makefile),)
#endif

$(BINDIR)/Makefile : CMakeLists.txt
	$(SHOW)cd $(BINDIR); \
	rel=`python -c "import os; print os.path.relpath('$(PWD)', '$$PWD')"`; \
	cmake -DDEPS_PATH=$$rel/deps $$rel

build: $(TARGET)

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
	$(SHOW)./system-setup.py

deps:
	$(SHOW)./get_deps.sh $(DEPS_FLAGS)

#---------------------------------------------------------------------------------------------- 

pack: BINDIR
	$(SHOW)./pack.sh $(TARGET)

BINDIR: bindirs
	$(SHOW)echo $(BINDIR)>BINDIR

#---------------------------------------------------------------------------------------------- 

# in pack: create ramp/redisai.so with RUNPATH set to /opt/redislabs/lib for RLEC compliance
rlec_runpath_fix: 
	@echo Fixing RLEC RUNPATH...
	@mkdir -p $(BINDIR)/ramp
	@cp -f $(BINDIR)/redisai.so $(BINDIR)/ramp/
	@patchelf --set-rpath $(REDIS_ENT_LIB_PATH) $(BINDIR)/ramp/redisai.so

pack: rlec_runpath_fix
	@[ ! -z `command -v redis-server` ] || { echo "Cannot find redis-server - aborting."; exit 1; }
	@[ ! -e $(REDIS_ENT_LIB_PATH) ] || { echo "$(REDIS_ENT_LIB_PATH) exists - aborting."; exit 1; }
ifeq ($(wildcard build/pyenv/.),)
	@virtualenv build/pyenv ;\
	. ./build/pyenv/bin/activate ;\
	pip install git+https://github.com/RedisLabs/RAMP
endif
	@echo "Building RAMP file ..."
	@set -e ;\
	. ./build/pyenv/bin/activate ;\
	ln -fs $(PWD)/deps/install/lib/ $(REDIS_ENT_LIB_PATH) ;\
	ramp pack -m $(PWD)/ramp.yml -o "build/redisai.{os}-{architecture}.${PACK_VER}.zip" $(BINDIR)/ramp/redisai.so 2>&1 > /dev/null ;\
	rm $(REDIS_ENT_LIB_PATH)
	@echo Done.
	@echo "Building dependencies file redisai-dependencies.${PACK_VER}.tgz ..."
	@cd deps/install/lib; \
	tar pczf ../../../build/redisai-dependencies.${PACK_VER}.tgz *.so*
	@echo Done.
