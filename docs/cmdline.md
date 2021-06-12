
- [CommandLine Usage](#commandline-usage)
  - [running source](#running-source)
  - [print AST](#print-ast)
  - [print Lua code](#print-lua-code)
  - [project config](#project-config)
  
# CommandLine Usage

get all options with option '-h' or leave it blank

```sh
$ moocscript
Usage: [OPTIONS] SOURCE.[lua|mooc]
        '' load SOURCE and run
        -h print help
        -a print AST
        -s print Lua code
        -p generate Lua code with project config
        -v version
```

## running source

you can directly running .lua or .mooc

```sh
$ moocscript FILE.lua
```

or

```sh
$ moocscript FILE.mooc
```

and only support .lua or .mooc files

## print AST

using option '-a' to get AST table

```sh
$ moocscript -a FILE.mooc
```

for example, create 'do.mooc' with content

```lua
do {
        print("Hello, world!")
}
```

and run as

```sh
$ moocscript -a do.mooc
{
  [1] = {
    ["body"] = {
      [1] = {
        [1] = {
          ["pos"] = 12,
          ["etype"] = "lvar",
          ["value"] = "print"
        },
        [2] = {
          ["op"] = "(",
          [1] = {
            [1] = {
              ["pos"] = 29,
              ["etype"] = "string",
              ["value"] = "Hello, world !"
            }
          }
        },
        ["stype"] = "("
      }
    },
    ["stype"] = "do"
  }
}
```

the output can use as a Lua table directly, there is little different between using from inside, for 'etype' string value, ignore '"', "'", '[[', but using '"', that is trivial.

the AST shows details about source file

- 'stype' means statement
- 'etype' means expression
- 'pos' means position, offsets from file beginning
- 'op' means operator
- 'body' for statements holds code block, another statments

and here shows part of it.

## print Lua code

for example

```sh
$ moocscript -s do.mooc
do
        print("Hello, world !")
end
```

## project config

you can output Lua source before running, and the output Lua source will not require any MoonCake component.

you can take a look at 'examples/proj/proj_config.mooc' for example.

```
return {
    {
        name : "proj first",
        proj_export : "exp_export.mooc",
        proj_dir : "examples",
        proj_out : "out"
    },
    {
        name : "proj second",
        proj_export : "exp_export.mooc",
        proj_dir : "examples",
        proj_out : "out"
    },
}%
```

here shows two project config, or two source directory.

- 'name' entry no meanings for MoonCake
- 'proj_export' for export variable declared forward
- 'proj_dir' is the input directory
- 'proj_out' is the output directory

in project mode, MoonCake will travel proj_dir recursively, translate all .mooc file to .lua into 'proj_out' directory, the travel order will not as it running, a required calling order,
maybe it will meet many global variable before declared, and it will cause error.

you should declare these global names in 'proj_export' file before.

running 'examples/proj/proj_config.mooc' for example

```sh
$ moocscript -p examples/proj/proj_config.mooc
---
proj: [proj first]
from: [examples]
 to : [out]
 DIR 'out/error'
examples/error/compile_error.mooc:1: defer { <not in function 'defer'>
 ERR 'out/error/compile_error.mooc':
parse error examples/error/parse_error.mooc:2:   name = "table"
 ERR 'out/error/parse_error.mooc':
FILE 'out/exp_all.lua'
FILE 'out/exp_cdef.lua'
FILE 'out/exp_class.lua'
...
```

the output is quite straight forward, 'ERR' means compile error, before it shows error details.

