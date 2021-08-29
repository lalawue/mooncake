
- [MoonCake](#mooncake)
  - [Forbiden words](#forbiden-words)
- [Content](#content)
  - [String](#string)
  - [Comment](#comment)
  - [Assigment & Scope](#assigment--scope)
    - [export *](#export-)
    - [global names](#global-names)
    - [operators](#operators)
  - [Table](#table)
  - [Function](#function)
    - [fn](#fn)
    - [anonymous](#anonymous)
    - [defer](#defer)
  - [Do statement](#do-statement)
  - [Loop](#loop)
    - [for](#for)
    - [while](#while)
    - [repeat / until](#repeat--until)
  - [Flow Control](#flow-control)
    - [if](#if)
    - [guard](#guard)
    - [switch](#switch)
    - [continue](#continue)
    - [break](#break)
    - [goto](#goto)
  - [Class](#class)
    - [self / Self / Super](#self--self--super)
    - [metamethod](#metamethod)
  - [Struct](#struct)
  - [Extension](#extension)
  - [Import](#import)
  - [Errors](#errors)
    - [parse](#parse)
    - [compile](#compile)
  - [Debug](#debug)

# MoonCake

MoonCake was a bit Swift like language that compiles to Lua, and compares to Lua, main difference are

- always declare variable as 'local', unless using 'export' keyword
- using '{' and '}' instead of keyword 'do', 'then', 'end' to seperate code block
- support 'guard' keyword, which must transfer control at the scope end
- support 'switch' keyword, you can 'case' a lot of conditions at a time
- support 'continue' keyword, implemented by 'goto', available in Lua 5.2 and LuaJIT
- support 'defer' keyword in function scope, including anonymous function
- support 'class' and 'struct' for simpler Object Oriented programming
- support 'extension' keyword for extend class/struct
- support 'import' keyword for simpler 'require' a lot of sub modules
- can declare anonymous function as '{ _ in }' form, a bit like in Swift

## Forbiden words

for MoonCake compiles to Lua eventually, so it holds all the Lua keywords, but some are forbiden, they can not use as keyword nor variable names:

- end
- function
- then

forget them at this language.

# Content

MoonCake using internal variable like '_\_name__' to accomplish some functionality, so please avoiding define variable like this.

## String

support Lua single string form, or multi-line string form, you can put paired '=' inside '[[' and ']]'.

```lua
print('Hello, world !')
print("Hello, world !")
print([[Hello,
   world !]])
```
  
and support another form can contains expression likes in Swift

```lua
-- print("Hello, world " .. tostring(6 * 100 + 6 * 10 + 6) .. " !")
print("Hello, world \(600 + 60 + 6) !")
-- Hello, world 666 !
```

## Comment

support single and multi line comment, but has limitations.

only support comment in seperate line, not support mixed comment with another keyword in one line, except table definition.

```lua
-- comment in seperate line
--[[
  multi line comment
]]
tbl = {
  10 --- comment ok
}
```

## Assigment & Scope

default is local scope, unless using 'export' keyword.

you can export variable, function, table, class and struct.

```lua
-- local a = 10
-- b = 11
a = 10
export b = 11
```

you can use 'local' to shadow existed variable, like in Lua

```lua
local b = 10
```

and when using global variable defined in another library not export before, will cause undefined variable error.

### export *

you can `export *` all current scope variables, for case using with setfenv or debug.setupvalue(), redefined _ENV in runtime

```lua
--[[
  function call() {
    return outer_variable
  }
]]
fn call() {
  export *
  return outer_variable
}
```

### global names

these global names are pre-defined:

```lua
    "_G",
    "_VERSION",
    "_ENV",
    "assert",
    "collectgarbage",
    "coroutine",
    "debug",
    "dofile",
    "error",
    "getfenv",
    "getmetatable",
    "io",
    "ipairs",
    "jit",
    "load",
    "loadfile",
    "loadstring",
    "math",
    "module",
    "next",
    "os",
    "package",
    "pairs",
    "pcall",
    "print",
    "rawequal",
    "rawget",
    "rawlen",
    "rawset",
    "require",
    "select",
    "setfenv",
    "setmetatable",
    "string",
    "table",
    "tonumber",
    "tostring",
    "type",
    "unpack",
    "xpcall",
```

### operators

"*=", "/=", "%=", "+=", "-=", "..=", "or=", "and=", "^=" operators was added for convenient as expended form

```lua
--[[
  a = a + 100
]]
a += 100
```


## Table

likes in Lua, and you can use ':' or '=' between key and value.

```lua
--[[
  local a = 3
  local tbl = {
    1,
    "2",
    ["3"] = 4,
    ["7"] = 6
  }
]]
a = 3
tbl = {
  1,
  "2",
  "3" : 4,
  ["5"] = 6
}
```

'[' and ']' can always treat key as expression, otherwise, in some cases, it will defined as table literal index, for example

```lua
--[[
  local a = 10
  tbl = {
    a = 10,  -- tbl.a = 10
    [a] = 10 -- [10] = 10
  }
]]
a = 10
tbl = {
  a : 10,  -- tbl.a = 10
  [a] : 10 -- [10] = 10
}
```

if key and value with same literal name, you can define table as

```lua
--[[
local value1 = 10
local value2 = 11
tbl = {
  value1 = value1,
  value2 = value2
}
]]
value1 = 10
value2 = 11
tbl = {
  :value1,
  =value2
}
```

when using ':' to seperate key and value, there will be some confuse between method call like 'A:call()' in table, it will cause it as array value.

so **keep space** before or after ':' to avoid this.


## Function

function definition has shorten keyword 'fn', and holding codes with paired '{' and '}', the origin 'function', 'end' became forbidden words.

there are two types function call, likes

```lua
print("1st type function call come with paired '(' and ')'", "and speperate with ,")
print. "2nd type function call come after . and only accept 1 string or table"
print .{ "2nd type function call table parameter" }
```

beside this, function definition likes in Lua

### fn

you can define function as local or global

```lua
--[[
  local function add(a, b)
    return a + b
  end
  function sub(a, b)
    return a - b
  end
]]
fn add(a, b) {
  return a + b  
}
export fn sub(a, b) {
  return a - b
}
```

or define function as table keys

```lua
--[[
  local Bird = {}

  function Bird.fly()
  end

  function Bird:eat()
  end
]]
Bird = {}

fn Bird.fly() {  
}

fn Bird:eat() {
}
```

but recommended using 'class' or 'struct' keyword to achive these, for a better object oriented style.

### anonymous

there are two forms to define anonymous function, one is

```lua
--[[
  local add = function(a, b)
    return a + b
  end
]]
add = fn(a, b) {
  return a + b
}
```

another is more like in Swift, just a sugar, using keyword 'in' inside curly braces

```lua
--[[
  local add = function(a, b)
    return a + b
  end
]]
add = { a, b in
  return a + b
}
```

the later form looks more suitable as anonymous callback function, but don't forget to return result.

so, shortest empty anonymous function can defined as

```lua
a = fn(){}
b = {in} -- or { _ in }
```

### defer

'defer' is a keyword to perform some work after function scope exist, not like Swift in all scope.

and defer only take effect after its definition, with the latest defer block will perform first, just last in first out, like in stack.

```lua
fn test(a) {
        fp = io.open("record", "w")
        if fp == nil {
                return -1
        }
        defer {
                fp:close()
                -- do not return anything
        }
        -- write something
        if a < 5 {
                return 5
        }
        -- write something
        -- return nil
}
--[[
  local function test(a)
        local __df_fns__ = {}
        local __df_run__ = function() local t=__df_fns__; for i=#t, 1, -1 do t[i]() end; end
        local fp = io.open("record", "w")
        if fp == nil then
                return -1
        end
        __df_fns__[#__df_fns__ + 1] = function()
                fp:close()
                -- do not return anything
        end
        -- write something
        if a < 5 then
                return 5, __df_run__()
        end
        -- write something
        -- return nil
        __df_run__()
  end
]]
```

and do not return anything in defer block, for it will became the last return element in some cases.

## Do statement

it can hold a lexical scope for variables.

```lua
--[[
  do
    local a = 10
    -- other statement
  end
]]
do {
  a = 10
  -- other statement
}
```

## Loop

support for, while, repeat until, likes in Lua

### for

just replace 'do', 'end' with '{' and '}', keyword 'end' is forbidden.

```lua
--[[
  for i=1, 5, 1 do

  end
]]
for i=1, 5, 1 {  

}
```

another form

```lua
--[[
  for i, v in ipairs(tbl) do

  end
]]
for i, v in ipairs(tbl) {  

}
```

### while

likes in Lua

```lua
--[[
  while true do

  end
]]
while true {

}
```

### repeat / until

likes in Lua, until expression can use variable defined after 'repeat'

```lua
--[[
  repeat

  until true
]]
repeat {

} until true
```

## Flow Control

### if

support keyword if, elseif, else, change 'then', 'end' to '{', '}'

```lua
--[[
  if true then
  end
]]
if true {
}
```

'else' example

```lua
--[[
  if false then
  else
  end
]]
if false {
} else {
}
```

or 'elseif' example

```lua
--[[
  if false then
  elseif false then
  else
  end
]]
if false {

} elseif false {

} else {

}
```


### guard

'guard' likes 'if not' sugar, and it will check last break/goto/return keyword for transfer control

```lua
--[[
  if not (true) then
    return
  end  
]]
guard true else {
  return
}
```


### switch

'switch' is a sugar of 'if .. then ... elseif .. then .. else .. end', expression after switch will only evaluate once.

```lua
switch animal {
  case 'dog', 'cat':
    print("can run")
  case 'bird':
    print("can fly")
  default:
    print("can swim")
}
--[[
  local __sw__ = animal
  if __sw__ == ('dog') or __sw__ == ('cat') then
          print("can run")
  elseif __sw__ == ('bird') then
          print("can fly")
  else
          print("can swim")
  end
]]
```

### continue

'continue' implemented by 'goto', not supoprt Lua 5.1

```lua
for i=1, 10 {
  if i < 5 {
    continue
  }
}
--[[
  for i = 1, 10 do
    if i < 5 then
      goto __continue1__
    end
    ::__continue1__::
  end
]]
```

### break

just likes in Lua

```lua
--[[
  for i=1, 10 do
    if i == 2 then
      break
    end
  end
]]
for i=1, 10 {
  if i == 2 {
    break
  }
}
```


### goto

not support Lua 5.1

```lua
--[[
  for i=1, 10 do
    if i==2 then
      goto label_end
    end
  end
  ::label_end::
]]
for i=1, 10 {
  if i == 2 {
    goto label_end
  }
}
::label_end::
```

## Class

something like in normal Lua table with variable and method defined, but unified them in class definition.

in class, you can

- defined class variable
- defined static/instance method
- defined static/instance metamethod

the instance will copy when visit, and variables and methods below are pre-defined:

- variable typename, typekind, classtype, supertype (only inherit from other class)
- method isKindOf
- method init / deinit (if defined)

'init', 'deinit' will added when you defined, 'deinit' will be called when collectgarbage, but 'deinit' will cause instance creation a bit slower.

actually, static method will expand as 'function table.name()', and instance method will be 'function table:name()'.

exmaples:

```swift
class Animal {
}
```

will expand as Lua code

```lua
local Animal = {}
do
        local __stype__ = nil
        local __clsname__ = "Animal"
        local __clstype__ = Animal
        __clstype__.typename = __clsname__
        __clstype__.typekind = 'class'
        __clstype__.classtype = __clstype__
        __clstype__.supertype = __stype__
        __clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end
        -- declare var and methods
        -- declare end
        local __ins_mt__ = {
                __tostring = function() return "instance of " .. __clsname__ end,
                __index = function(t, k)
                        local v = __clstype__[k]
                        if v ~= nil then rawset(t, k, v) end
                        return v
                end,
        }
        setmetatable(__clstype__, {
                __tostring = function() return "class " .. __clsname__ end,
                __index = function(_, k)
                        local v = __stype__ and __stype__[k]
                        if v ~= nil then rawset(__clstype__, k, v) end
                        return v
                end,
                __call = function(_, ...)
                        local ins = setmetatable({}, __ins_mt__)
                        return ins
                end,
        })
end
```

you can inherit class, and use 'self' in instance method

```swift
class Bird : Animal {

  wing_count = 2

  fn init(count) {
    self.wing_count = count
  }
  
  fn featherColor() {
    return "dark"
  }

  static fn hasWings() {
    return true
  }

  fn __sub(a, b) {
    return a.wing_count - b.wing_count
  }

  static fn __add(a, b) {
    return a.wing_count + b.wing_count
  }
}
```

will expand to Lua code

```lua
local Bird = {}
do
        local __stype__ = Animal
        local __clsname__ = "Bird"
        local __clstype__ = Bird
        assert(type(__stype__) == "table" and __stype__.typekind == "class")
        for k, v in pairs(__stype__) do __clstype__[k] = v end
        __clstype__.typename = __clsname__
        __clstype__.typekind = 'class'
        __clstype__.classtype = __clstype__
        __clstype__.supertype = __stype__
        -- declare var and methods
        __clstype__.wing_count = 2
        function __clstype__:init(count)
                self.wing_count = count
        end
        function __clstype__:featherColor()
                return "dark"
        end
        function __clstype__.hasWings()
                return true
        end
        -- declare end
        local __ins_mt__ = {
                __tostring = function() return "instance of " .. __clsname__ end,
                __index = function(t, k)
                        local v = __clstype__[k]
                        if v ~= nil then rawset(t, k, v) end
                        return v
                end,
                __sub = function(a, b)
                        return a.wing_count - b.wing_count
                end,
        }
        setmetatable(__clstype__, {
                __tostring = function() return "class " .. __clsname__ end,
                __index = function(_, k)
                        local v = __stype__ and __stype__[k]
                        if v ~= nil then rawset(__clstype__, k, v) end
                        return v
                end,
                __call = function(_, ...)
                        local ins = setmetatable({}, __ins_mt__)
                        if ins:init(...) == false then return nil end
                        return ins
                end,
                __add = function(a, b)
                        return a.wing_count + b.wing_count
                end,
        })
end
```

in 'init' function, you can return 'false' to create a nil instance for caller, cause creation failure.

you can add variable/method to class or instance at anytime, likes other normal Lua table, but class/instance will copy not exist key/value from super/class when they visited.

so if you modified original definition after running awhile, some of them can not update and run as expected.

you can create instance from class like

```lua
a = Bird(2)
b = Bird(4)
print(b - a)
-- 2
```

### self / Self / Super

- 'self' refers to class instance, you can use it in instance method, likes in Lua
- 'Self' refers to class itself in class scope, including variable definition
- 'Super' refers to super calss in class scope, including variable definition

you can visit defined variable in sequence as what you write in the source.

```lua
class Example {
  _name = "example"
  _full_name = "for " .. Self._name

  static fn getFullName() {
    return Self._full_name
  }
}
print(Example.getFullName())
-- for example
```

### metamethod

only support these class/instance metamethod, and some of them only take effect in latest Lua version.

```lua
  "__add",
  "__band",
  "__bnot",
  "__bor",
  "__bxor",
  "__close",
  "__concat",
  "__div",
  "__eq",
  "__idiv",
  "__le",
  "__len",
  "__lt",
  "__metatable",
  "__mod",
  "__mode",
  "__mul",
  "__name",
  "__pairs",
  "__pow",
  "__shl",
  "__shr",
  "__sub",
  "__unm"
```

## Struct

struct is a limited Lua table with variable and method defined, the limitation is

- can not inherit from another struct/class
- can not create/remove keys after definition (even in init() function)

you can change its value after definition, and likes in class, you can

- defined struct variable
- defined static/instance method
- defined static/instance metamethod

the instance will copy when visit, variables and methods below are pre-defined:

- variable typename, typekind, classtype
- method init / deinit (if defined) 

examples:

```lua
struct Car {
  _wheel_count = 4

  fn init(wheel_count) {
    self._wheel_count = wheel_count
  }

  fn __add(a, b) {
    return a._wheel_count + b._wheel_count
  }
}
```

will expanded to Lua code

```lua
local Car = {}
do
        local __clsname__ = "Car"
        local __clstype__ = Car
        __clstype__.typename = __clsname__
        __clstype__.typekind = 'struct'
        __clstype__.classtype = __clstype__
        -- declare var and methods
        __clstype__._wheel_count = 4
        function __clstype__:init(wheel_count)
                self._wheel_count = wheel_count
        end
        -- declare end
        local __ins_mt__ = {
                __tostring = function() return "one of " .. __clsname__ end,
                __index = function(t, k)
                        local v = rawget(__clstype__, k)
                        if v ~= nil then rawset(t, k, v) end
                        return v
                end,
                __newindex = function(t, k, v) if rawget(__clstype__, k) ~= nil then rawset(t, k, v) end end,
                __add = function(a, b)
                        return a._wheel_count + b._wheel_count
                end,
        }
        Car = setmetatable({}, {
                __tostring = function() return "struct " .. __clsname__ end,
                __index = function(_, k) return rawget(__clstype__, k) end,
                __newindex = function(_, k, v) if v ~= nil and rawget(__clstype__, k) ~= nil then rawset(__clstype__, k, v) end end,
                __call = function(_, ...)
                        local ins = setmetatable({}, __ins_mt__)
                        if ins:init(...) == false then return nil end
                        return ins
                end,
        })
end
```

create instance likes class, and you can use 'self' or 'Self' in instance method or static method.

## Extension

'extension' is the only way to extend class/struct variable/method, the limitation is can not override exist variable/method, can not add metamethod.

- support extend class from struct, or extend struct from class
- define new variable/method for class/struct
- can extend class/struct multiple times

```lua
class ClsA {
  name = Self.typename
}

struct StructA {
  fn getName() {
    return self.name or "none"
  }
}

extension StructA : ClsA {
  fn fullName() {
    return "struct base: " .. self:getName()
  }
}

a = StructA()
print(a:fullName())
-- struct base: ClsA
```

the last 'extension' keyword will expand as

```lua
do
        local __extype__ = ClsA
        local __clstype__ = StructA
        assert(type(__clstype__) == "table" and type(__clstype__.classtype) == "table")
        __clstype__ = __clstype__.classtype
        assert(type(__extype__) == "table" and type(__extype__.classtype) == "table")
        for k, v in pairs(__extype__.classtype) do
                if __clstype__[k] == nil and k:sub(1, 2) ~= "__" and k ~= "supertype" and k ~= "isKindOf" then
                        __clstype__[k] = v
                end
        end
        -- declare var and methods
        function __clstype__:fullName()
                return "struct base: " .. self:getName()
        end
        -- declare end
en
```

## Import

'import' keyword provide a convenient way to require module and its sub modules

```lua
-- require("lpeg")
import "lpeg"
```

or require to local variable

```lua
-- local lpeg = require("lpeg")
import lpeg from "lpeg"
```

or only load sub modules

```lua
-- local P, R, S
-- do
--      local __lib__ = require("lpeg")
--      P, R, S = __lib__.P, __lib__.R, __lib__.S
-- end
import P, R, S from "lpeg" {}
```

and you can load and rename sub modules

```lua
-- local p, r, s
-- do
--      local __lib__ = require("lpeg")
--      p, r, s = __lib__.P, __lib__.R, __lib__.S
-- end
import p, r, s from "lpeg" { P, R, S }
```

you can perform these rules to a table

```lua
-- local insert, remove = table.insert, table.remove
import insert, remove from table {}
```

## Errors

there are two phase for generate Lua code, first it parse source to generate AST, then translate AST to Lua code, so some error may happen in these phase.

### parse

using source 'examples/error/parse_error.mooc' for example

```lua
tbl = {
  name = "table"
}
-- parse error examples/error/parse_error.mooc:2:   name = "table"
```

run the source will cause parse error, the right way is using ':' instead of '=' to seperate table key and value.

parse error only contains file name, line number and the source line, for it use farthest match position for indicating, sometimes it can not show the right place.

### compile

when we got AST, there are some restriction to generate Lua code, for example

- break should inside loop
- guard should transfer control in the scope end
- defer should inside function

using source 'examples/error/compile_error.mooc' for example

```lua
defer {
}
-- examples/error/compile_error.mooc:1: defer { <not in function 'defer'>
```

## Debug

you should debug generated .lua source, not .mooc