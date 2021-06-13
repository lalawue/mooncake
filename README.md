
[![MIT licensed][1]][2]


[1]: https://img.shields.io/badge/license-MIT-blue.svg
[2]: LICENSE

## MoonCake

MoonCake was a Swift like programming language that compiles into Lua, runs on Lua 5.1 and above, including LuaJIT.

recommand install and running first, or get more straight expressions from 'examples/' dir.

before dig into detials about the language and usage

- [The Language](docs/language.md)
- [CommandLine Usage](docs/cmdline.md)
- [Library Interface](docs/library.md)

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

or just run as playground in project root dir, but need [LPeg](http://www.inf.puc-rio.br/~roberto/lpeg/) installed, and in Lua's package.cpath

```sh
$ ./bin/moocscript
```

with requirement

- [Lua](https://www.lua.org/) >= 5.1 **OR** [LuaJIT](https://luajit.org/) >= 2.0
- [LPeg](http://www.inf.puc-rio.br/~roberto/lpeg/) >= 1.0.2
- [LuaFileSystem](http://keplerproject.github.io/luafilesystem/) >= 1.5 ( only if you need project compile )

## Running

check install first

```sh
$ moocscript -v
moocscript v0.3.20210612, Lua 5.3, LPeg 1.0.2
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

project config example is examples/proj/proj_config.mooc

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
moocscript/compile.lua                                            1157 12     98.97%
moocscript/core.lua                                               76   1      98.70%
moocscript/parser.lua                                             119  0      100.00%
moocscript/utils.lua                                              119  12     90.84%
...
```

## Editor Support

support VSCode extension in release page mooncake-0.3.20210613.vsix.