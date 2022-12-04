

# Library Interface

- [Library Interface](#library-interface)
  - [Core Library](#core-library)
    - [require .mooc from Lua](#require-mooc-from-lua)
    - [dofile / loadfile / loadstring / loadbuffer](#dofile--loadfile--loadstring--loadbuffer)
    - [control compile step](#control-compile-step)
    - [other interface](#other-interface)
  - [Class Library](#class-library)
    - [create / inherit mooc class from Lua](#create--inherit-mooc-class-from-lua)
    - [create mooc struct from Lua](#create-mooc-struct-from-lua)
    - [extent class / struct from Lua](#extent-class--struct-from-lua)
  - [Standalone Library](#standalone-library)
    - [skeleton](#skeleton)


you can get these examples code from `examples/library` direcotry.

## Core Library

### require .mooc from Lua

just `require("moocscript.core")` before you load any .mooc module

create exp_lib.mooc for example

```lua
-- exp_lib.mooc
return { pr = print }
```

then create test_lib.lua to require('exp_lib'), and run as '$ lua test_lib.lua'

```lua
-- test_lib.lua
require("moocscript.core")
local lib = require("exp_lib")
lib.pr("Hello, world")
-- Hello, world
```

### dofile / loadfile / loadstring / loadbuffer

these interface likes in Lua, use exp_lib.mooc created before, then create test_core.lua, content below shows usage

```lua
-- test_core.lua
local MoocCore = require("moocscript.core")

local f = MoocCore.loadfile("exp_lib.mooc")
print("loadfile", f, f(), f().pr == print)

local d = MoocCore.dofile("exp_lib.mooc")
print("dofile", d, d.pr == print)

local l = MoocCore.loadstring("return { pr = print }")
print("loadstring", l, l().pr == print)

local ret, s = MoocCore.loadbuffer("fn abc() {}")
print("loadsbuffer", ret)
print(s)
-- loadfile        function: 0x00078ff8    table: 0x00078be8       true
-- dofile          table: 0x0005a538       true
-- loadstring      function: 0x0005b110    true
-- loadsbuffer	true
-- local function abc()
-- end
```

### control compile step

here shows how to get AST and generate Lua code, create test_step.lua, and run as `lua test_step.lua exp_lib.mooc`

use exp_lib.mooc created before

```lua
-- test_step.lua
local Utils = require("moocscript.utils")
local MoocCore = require("moocscript.core")

-- get filename
local fname = ...
if fname == nil or fname:len() <=0 then
        print("Usage: lua test_step.lua exp_lib.mooc")
        os.exit(0)
end

-- first load file
local text = Utils.readFile(fname)

-- setup config, for error indicating
local config = { fname = fname }

-- get ast
local res, emsg = MoocCore.toAST(config, text)
if res then
        print("--- ast")
        Utils.dump(res.ast)
else
        print("error:", emsg)
        os.exit(0)
end

-- get Lua source
local code, emsg = MoocCore.toLua(config, res)
if code then
        print("--- code")
        print(code)
else
        print("error:", emsg)
end
```

### other interface

these interfaces from `require("moocscript.core")`:

- removeloader(): you can remove .mooc loader form VM
- appendloader(): add .mooc loader to VM
- version(): show MoonCake version
- loaded(): return loaded state
- clearProj(): clear global export, using in project config
- require(): only require `.mooc` file in `package.path`, using in web environment

## Class Library

### create / inherit mooc class from Lua

you can create / inherit mooc class from Lua side, but has limitations,
can not create class or instance metamethod outside class definition.

you can create `init` function, but `deinit` function.

```lua
-- test_class.lua
local MoocLib = require("moocscript.class")

-- create ClassA with no inherit
local ClassA = MoocLib.newMoocClass("A")

-- will be called when create ClassA's instance with ClassA(...)
function ClassA:init(...)
        print('init ' .. tostring(self))
end

function ClassA:getName()
        return tostring(self)
end

-- create ClassC inherit from ClassA
local ClassC = MoocLib.newMoocClass("C", ClassA)

-- getName inherit from ClassA
function ClassC:sayHi()
        print('hello ' .. self:getName())
end

local c = ClassC()
c:sayHi()
-- init <class C: 0x0004c440>
-- hello <class C: 0x0004c440>
```

if super type `ClassA` was not a mooc class, ClassC is nil, and will cause runtime error.

### create mooc struct from Lua

like create mooc class

```lua
-- test_struct.lua
local MoocLib = require("moocscript.class")

-- create StructA
local StructA, RawStructA = MoocLib.newMoocStruct("A")

-- using RawStructA to create your new function or variable
function RawStructA:init(...)
        print(tostring(self) .. ' init ' .. (... or ''))
end

local a = StructA('1')
-- <struct A: 0x0004dac0> init 1

StructA.try_newindex = 1
print(StructA.try_newindex)
-- nil

a.try_newindex = 1
print(a.try_newindexs)
-- nil
```

### extent class / struct from Lua

you can extent class / struct by raw table

```lua
-- test_extension.lua
local MoocLib = require("moocscript.class")

-- create ClassA with no inherit
local ClassA = MoocLib.newMoocClass("A")

function ClassA:getName()
        return tostring(self)
end

-- create StructB
local StructB, RawStructB = MoocLib.newMoocStruct('B')

function RawStructB:sayHi()
        return 'Say Hi from StructB'
end

local b1 = StructB()
print(b1:sayHi())

local ExtStructB = MoocLib.extentMoocClassStruct(StructB, ClassA)

function ExtStructB:sayHi()
        return 'Say Hi from Ext ' .. self:getName()
end

function ExtStructB:goodBye()
        return 'Goodby'
end

local b2 = StructB()
print(b2:sayHi())
print(b2:goodBye())
-- Say Hi from StructB
-- Say Hi from Ext <struct B: 0x0004de50>
-- Goodby
```

## Standalone Library

just combined `utils`, `parser`, `compiler`, `core`, `class` libraries into one, only load once for web environment.

it's a special verison, now add `fengari` key word for using inside [Fengari](https://fengari.io/) Lua VM in browser.

### skeleton

you can use it in other Lua VM.

for example, get seperated `utils`, `parser`, `compiler`, `core`, `class` libraries:

```lua
local MoocLib = require("out/web/moocscript-web")
for k, v in pairs(MoocLib) do
        print(k, v)
end
-- parser	table: 0x010a033dc8
-- core	table: 0x010a055478
-- compiler	table: 0x010a054b80
-- class	table: 0x010a0555d8
-- utils	<class Utils>
```