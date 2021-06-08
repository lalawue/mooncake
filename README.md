
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

or edit Makefile for a custom install

```sh
$ vi Makefile
$ make install
```

with requirement

- lua >= 5.1
- lpeg >= 1.0.2
- luafilesystem >= 1.5 ( only if you need project compile )

## Running

check install first

```sh
$ moocscript -v
moocscript v0.3.20210612, Lua 5.1, LPeg 1.0.2
```

you can run .lua or .mooc source directly, support options below

```
$ moocscript
Usage: [OPTIONS] SOURCE.[lua|mooc]
        '' load SOURCE and run
        -h print help
        -a print AST
        -s print Lua code
        -p generate Lua code with project config
        -v version
```

project config example locates in examples/proj/proj_config.mooc

## Test

using [busted](https://olivinelabs.com/busted/), running from project dir

```sh
$ luarocks install busted
$ busted
●●●●●●●●●●●●●●●●●●...
183 successes / 0 failures / 0 errors / 0 pending : 0.298494 seconds
```

you can install [LuaCov](https://keplerproject.github.io/luacov/) to get code coverage report

```sh
$ luarocks install luacov
$ busted -c
$ luacov
$ cat luacov.report.out | grep 'moocscript/'
...
moocscript/compile.lua                                            1134 9      99.21%
moocscript/core.lua                                               84   1      98.82%
moocscript/parser.lua                                             238  2      99.17%
moocscript/utils.lua                                              98   4      96.08%
...
```

## Editor Support

search extension MoonCake in [VSCode](https://code.visualstudio.com/)