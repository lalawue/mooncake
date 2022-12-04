
- [CommandLine Usage](#commandline-usage)
  - [running source](#running-source)
  - [print AST](#print-ast)
  - [print Lua code](#print-lua-code)
  - [enter REPL env](#enter-repl-env)
  - [project config](#project-config)

# CommandLine Usage

get help with option '-h' or leave it blank

```sh
$ moocscript
Usage: [OPTIONS] SOURCE.[lua|mooc]
        '' load SOURCE and run
        -h print help
        -a print AST
        -s print Lua code
        -i enter REPL
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
          [1] = {
            ["pos"] = 14,
            ["etype"] = "var",
            ["value"] = "print"
          },
          [2] = {
            [1] = {
              ["pos"] = 20,
              ["etype"] = "const",
              ["value"] = "Hello, world!"
            },
            ["etype"] = "("
          },
          ["etype"] = "exp"
        },
        ["stype"] = "("
      }
    },
    ["stype"] = "do"
  }
}
```

the output can use as a Lua table directly, there is little different between using from inside, for 'etype' string value, ignore ", ', [[, but using ", that is trivial.

the AST shows details about source file

- 'stype' means statement
- 'etype' means expression
- 'pos' means position, offsets from file beginning
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

## enter REPL env

you can play with it without an editor:

```sh
$ ./bin/moocscript -i
moocscript v0.7.20221006, Lua 5.4
> export * -- default global variable
> class Person {
	name = ''
	fn init(name) {
		self.name = name
	}
	fn intro() {
		return "My name is \(self.name)"
	}
}
> peter = Person("Peter")
> print(peter:intro())
My name is peter
```

## project config

you can output Lua source before running, and the output Lua source will not require any MoonCake component.

project buildling requires `luafilesystem` (lfs)

you can take a look at 'examples/proj/proj_config.mooc' for example.

```
return {
    {
        name = "proj first",
        proj_export = "exp_export.mooc",
        proj_dir = "examples",
        proj_out = "out",
        fn_filter = { in_path in
            return true
        },
        fn_after = { out_path, lua_source_string in
            return lua_source_string
        }
    },
    {
        name = "proj second",
        proj_export = "exp_export.mooc",
        proj_dir = "examples",
        proj_out = "out"
    },
}
```

here shows two project config, or two source directory.

- `name` entry no meanings for MoonCake
- `proj_export` for export variable declared forward as global variable
- `proj_dir` is the input directory
- `proj_out` is the output directory
- `fn_filter` will filter in path, return false if you do not want to copy or output Lua source
- `fn_after` will be called after Lua code generated and before write to out path, you can modify output content here

in project mode, MoonCake will travel proj_dir recursively, translate all .mooc file to .lua into `proj_out` directory, the travel order will not as it running, a required calling order, maybe it will meet many global variable before declared, and it will cause error.

you should declare these global names in 'proj_export' file before.

running 'examples/proj/proj_config.mooc' for example

```sh
$ moocscript -p examples/proj/proj_config.mooc
---
proj: [proj first]
from: [examples]
 to : [out]
 on : filter
 on : after
 DIR 'out/error'
Error: defer only support function scope
File: examples/error/compile_error.mooc
Line: 1 (Pos: 0)
Source: defer {
        ^
 ERR 'out/error/compile_error.mooc':
```

the output is quite straight forward, 'ERR' means compile error, before it shows error details.

any error will stop project building.
