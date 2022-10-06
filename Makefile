#
# by lalawue, 2021/05/25

.PHONY : all
.PHONY : test
.PHONY : out
.PHONY : install
.PHONY : uninstall

NAME=moocscript
SUFX=mooc
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

all:
	@echo "Usage:"
	@echo "\t $ make test \t# $(NAME) busted"
	@echo "\t $ make out \t# make gen then ./out/$(NAME) busted"
	@echo "\t $ make gen \t# generate .lua from .mooc into ./out"
	@echo "\t $ make install \t# please edit Makefile first"
	@echo "\t $ make uninstall \t# please edit Makefile first"

test:
	rm -f *.out
	rm -rf out/
	echo 'package.path="./?.lua" -- auto generated by Makefile' > spec/aaa_spec.lua
	busted

out: gen
	echo 'package.path="./out/?.lua" -- auto generated by Makefile' > spec/aaa_spec.lua
	busted

gen:
	rm -f *.out
	rm -rf out/
	mkdir -p $(ODIR)
	$(CS) $(NAME)/compile.$(SUFX) > $(ODIR)/compile.lua
	$(CS) $(NAME)/core.$(SUFX) > $(ODIR)/core.lua
	$(CS) $(NAME)/parser.$(SUFX) > $(ODIR)/parser.lua
	$(CS) $(NAME)/utils.$(SUFX) > $(ODIR)/utils.lua
	$(CS) $(NAME)/class.$(SUFX) > $(ODIR)/class.lua
	$(CS) $(NAME)/repl.$(SUFX) > $(ODIR)/repl.lua

MN_DIR=$(INSTALL_LUA_PATH)/$(NAME)/
MN_BIN=$(INSTALL_BIN_PATH)/$(NAME)

install:
	@echo 'Please edit Makefile first !!!'
#	rm -rf $(MN_DIR)
#	mkdir -p $(MN_DIR)
#	echo "#!$(INSTALL_LUA_EXEC)\n" > $(MN_BIN)
#	echo "package.path = package.path .. \";$(INSTALL_LUA_PATH)/?.lua;\"" >> $(MN_BIN)
#	cat bin/$(NAME) | grep -v '#!' >> $(MN_BIN)
#	cp -a $(NAME)/*.lua $(MN_DIR)
#	chmod +x $(MN_BIN)

uninstall:
	@echo 'Please edit Makefile first !!!'
#	rm -f $(MN_BIN)
#	rm -rf $(MN_DIR)

clean:
	rm -f *.out
	rm -rf out/