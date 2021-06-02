#
# by lalawue, 2021/05/25

.PHONY : all
.PHONY : test
.PHONY : out
.PHONY : install
.PHONY : uninstall

OLIB=export LUA_PATH="./out/?.lua;"
ODIR=out/mnscript
CS=./bin/mnscript -s

#
# edit path before install

# bin/mnscript
INSTALL_BIN_PATH=/usr/local/bin
# Lua/LuaJIT interpreter
INSTALL_LUA_EXEC=/usr/local/bin/lua
# for store mnscript core *.lua
INSTALL_LUA_PATH=/usr/local/opt/mnscript
# lpeg.so and lfs.so location
INSTALL_LUA_CPATH=/usr/local/lib/lua/5.1

all:
	@echo "Usage:"
	@echo "\t $ make test \t# mnscript busted -c"
	@echo "\t $ make out  \t# self hosted mnscript busted -c"
	@echo "\t $ make install \t# please edit Makefile first"
	@echo "\t $ make uninstall"

test:
	rm -f *.out
	rm -rf out/
	busted -c

out:
	rm -f *.out
	rm -rf out/
	mkdir -p $(ODIR)
	$(CS) mnscript/compile.mn > $(ODIR)/compile.lua
	$(CS) mnscript/core.mn > $(ODIR)/core.lua
	$(CS) mnscript/parser.mn > $(ODIR)/parser.lua
	$(CS) mnscript/utils.mn > $(ODIR)/utils.lua
	$(OLIB) && busted -c

MN_DIR=$(INSTALL_LUA_PATH)/mnscript/
MN_BIN=$(INSTALL_BIN_PATH)/mnscript

install:
	rm -rf $(MN_DIR)
	mkdir -p $(MN_DIR)
	echo "#!$(INSTALL_LUA_EXEC)\n" > $(MN_BIN)
	echo "local _mn_path=\"$(INSTALL_LUA_PATH)\"" >> $(MN_BIN)
	echo "package.cpath = package.cpath .. \";$(INSTALL_LUA_CPATH)/?.so;\"" >> $(MN_BIN)
	echo "package.path = package.path .. \";$(INSTALL_LUA_PATH)/?.lua;\"" >> $(MN_BIN)
	cat bin/mnscript | grep -v '#!' >> $(MN_BIN)
	cp -a mnscript/*.lua $(MN_DIR)
	chmod +x $(MN_BIN)

uninstall:
	rm -f $(MN_BIN)
	rm -rf $(MN_DIR)

clean:
	rm -f *.out
	rm -rf out/