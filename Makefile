#
# by lalawue, 2021/05/25

.PHONY : all
.PHONY : test
.PHONY : out

OUT_LIB=export LUA_PATH="./out/?.lua;"
CS_LIB=export LUA_PATH="./core/?.lua;"
CS=./bin/mnscript -s


all:
	@echo "Usage:"
	@echo "\t $ make test \t# mnscript busted -c"
	@echo "\t $ make out  \t# self hosted mnscript busted -c"

test:
	rm -f *.out
	rm -rf out/
	$(CS_LIB) && busted -c

out:
	rm -f *.out
	rm -rf out/
	mkdir out
	$(CS) core/mn_utils.mn > out/mn_utils.lua
	$(CS) core/mn_loader.mn > out/mn_loader.lua
	$(CS) core/mn_parser.mn > out/mn_parser.lua
	$(CS) core/mn_compile.mn > out/mn_compile.lua
	$(CS) core/mn_core.mn > out/mn_core.lua
	$(OUT_LIB) && busted -c

clean:
	rm -f *.out
	rm -rf out/ 
