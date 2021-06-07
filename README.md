
[![MIT licensed][1]][2]


[1]: https://img.shields.io/badge/license-MIT-blue.svg
[2]: LICENSE

## MoonCake

MoonCake was a Swift like programming language that compiles into Lua, runs on Lua 5.1 and above, including LuaJIT.

The wiki contains language detail.

## Install

recommend install from [LuaRocks](https://luarocks.org/)

```sh
$ luarocks install mooncake
```

or edit Makefile for a custom one, then

```sh
$ vi Makefile
$ make install
```

and with minimal requirement

- lua >= 5.1
- lpeg >= 1.0.2
- luafilesystem >= 1.5 ( only if you need project compile )

## Test

using [busted](https://olivinelabs.com/busted/), running from project dir

```sh
$ luarocks install busted
$ busted
●●●●●●●●●●●●●●●●●●...
180 successes / 0 failures / 0 errors / 0 pending : 0.306014 seconds
```

you can install [LuaCov](https://keplerproject.github.io/luacov/) to get code coverage report

```sh
$ luarocks install luacov
$ busted -c
$ luacov
$ cat luacov.report.out | grep 'moocscript/'
...
moocscript/compile.lua                                            1118 9      99.20%
moocscript/core.lua                                               83   1      98.81%
moocscript/parser.lua                                             234  2      99.15%
moocscript/utils.lua                                              98   4      96.08%
...
```

## Editor Support

search extension MoonCake in [VSCode](https://code.visualstudio.com/)