#
# by lalawue, 2021/05/25

.PHONY : all
.PHONY : test
.PHONY : out

OLIB=export LUA_PATH="./out/?.lua;"
ODIR=out/mnscript
CS=./bin/mnscript -s

all:
	@echo "Usage:"
	@echo "\t $ make test \t# mnscript busted -c"
	@echo "\t $ make out  \t# self hosted mnscript busted -c"

test:
	rm -f *.out
	rm -rf out/
	busted -c

out:
	rm -f *.out
	rm -rf out/
	mkdir -p $(ODIR)
	$(CS) mnscript/cmdline.mn > $(ODIR)/cmdline.lua	
	$(CS) mnscript/compile.mn > $(ODIR)/compile.lua
	$(CS) mnscript/core.mn > $(ODIR)/core.lua
	$(CS) mnscript/parser.mn > $(ODIR)/parser.lua
	$(CS) mnscript/utils.mn > $(ODIR)/utils.lua
	$(OLIB) && busted -c

clean:
	rm -f *.out
	rm -rf out/ 
