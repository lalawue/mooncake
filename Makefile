#
# by lalawue, 2021/05/25

.PHONY : all
.PHONY : test
.PHONY : out
.PHONY : install
.PHONY : uninstall

NAME=moocscript
SUFX=mooc
OLIB=export LUA_PATH="./out/?.lua;"
ODIR=out/$(NAME)
CS=./bin/$(NAME) -s

#
# edit path before install

# bin/$(NAME)
INSTALL_BIN_PATH=/usr/local/bin
# Lua/LuaJIT interpreter
INSTALL_LUA_EXEC=/usr/local/bin/lua
# for store $(NAME) core *.lua
INSTALL_LUA_PATH=/usr/local/opt/$(NAME)
# lpeg.so and lfs.so location
INSTALL_LUA_CPATH=/usr/local/lib/lua/5.1

all:
	@echo "Usage:"
	@echo "\t $ make test \t# $(NAME) busted"
	@echo "\t $ make out  \t# self hosted $(NAME) busted"
	@echo "\t $ make install \t# please edit Makefile first"
	@echo "\t $ make uninstall"

test:
	rm -f *.out
	rm -rf out/
	busted

out:
	rm -f *.out
	rm -rf out/
	mkdir -p $(ODIR)
	$(CS) $(NAME)/compile.$(SUFX) > $(ODIR)/compile.lua
	$(CS) $(NAME)/core.$(SUFX) > $(ODIR)/core.lua
	$(CS) $(NAME)/parser.$(SUFX) > $(ODIR)/parser.lua
	$(CS) $(NAME)/utils.$(SUFX) > $(ODIR)/utils.lua
	$(CS) $(NAME)/class.$(SUFX) > $(ODIR)/class.lua
	$(OLIB) && busted

MN_DIR=$(INSTALL_LUA_PATH)/$(NAME)/
MN_BIN=$(INSTALL_BIN_PATH)/$(NAME)

install:
	rm -rf $(MN_DIR)
	mkdir -p $(MN_DIR)
	echo "#!$(INSTALL_LUA_EXEC)\n" > $(MN_BIN)
	echo "package.cpath = package.cpath .. \";$(INSTALL_LUA_CPATH)/?.so;\"" >> $(MN_BIN)
	echo "package.path = package.path .. \";$(INSTALL_LUA_PATH)/?.lua;\"" >> $(MN_BIN)
	cat bin/$(NAME) | grep -v '#!' >> $(MN_BIN)
	cp -a $(NAME)/*.lua $(MN_DIR)
	chmod +x $(MN_BIN)

uninstall:
	rm -f $(MN_BIN)
	rm -rf $(MN_DIR)

clean:
	rm -f *.out
	rm -rf out/