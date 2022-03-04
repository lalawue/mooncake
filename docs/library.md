
- [Library Interface](#library-interface)
  - [require .mooc from Lua](#require-mooc-from-lua)
  - [dofile / loadfile / loadstring](#dofile--loadfile--loadstring)
  - [control compile step](#control-compile-step)
  - [create / inherit mooc class](#create--inherit-mooc-class)
  - [other interface](#other-interface)
  
# Library Interface

with library, you can

- require .mooc module from Lua
- dofile / loadfile / loadstring
- control compile step
- create / inherit mooc class from Lua

## require .mooc from Lua

just 'require("moocscript.core")' before you load any .mooc module

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

## dofile / loadfile / loadstring

these interface likes in Lua, use exp_lib.mooc created before, then create test_core.lua, the content shows these interface usage

```lua
-- test_core.lua
local MoocLib = require("moocscript.core")

local f = MoocLib.loadfile("exp_lib.mooc")
print("loadfile", f, f(), f().pr == print)

local d = MoocLib.dofile("exp_lib.mooc")
print("dofile", d, d.pr == print)

local l = MoocLib.loadstring("return { pr = print }")
print("loadstring", l, l().pr == print)
-- loadfile        function: 0x00078ff8    table: 0x00078be8       true
-- dofile          table: 0x0005a538       true
-- loadstring      function: 0x0005b110    true
```

## control compile step

here shows how to get AST and generate Lua code, create test_step.lua, and run as `lua test_step.lua exp_lib.mooc'

use exp_lib.mooc created before

```lua
-- test_step.lua
local Utils = require("moocscript.utils")
local MoocLib = require("moocscript.core")

-- first load file
local text = Utils.readFile(...)

-- setup config, for error indicating
local config = { fname = ... }

-- get ast
local res, emsg = MoocLib.toAST(config, text)
if res then
        print("--- ast")
        Utils.dump(res.ast)
else
        print("error:", emsg)
        os.exit(0)
end

-- get Lua source
local code, emsg = MoocLib.toLua(config, res)
if code then
        print("--- code")
        print(code)
else
        print("error:", emsg)
end
```

## create / inherit mooc class

you can create / inherit mooc class from Lua side, but has limitations,
can not create class or instance metamethod after class defition.

```lua
local MoocClass = require("moocscript.class")
local ClassA = require("MoocClassAForExample")

-- create ClassB with no inherit
local ClassB = MoocClass("B")

-- will be called when create ClassB's instance with ClassB(...)
function ClassB:init(...)
end

-- create ClassC inherit from ClassA
local ClassC = MoocClass("C", ClassA)

function ClassC:init(...)
end
```

if `ClassA` was not a mooc class, ClassC is nil, and will cause runtime error.

## other interface

these interfaces from `require("moocscript.core")`:

- removeloader(): you can remove .mooc loader form VM
- appendloader(): add .mooc loader to VM
- version(): show MoonCake version
- loaded(): return loaded state
- clearProj(): clear global export, used in project config