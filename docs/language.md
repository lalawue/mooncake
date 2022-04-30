
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

- always declare variable as `local`, unless using `export` keyword
- using `{` and `}` instead of keyword `do`, `then`, `end` to seperate code block
- support `guard` keyword, which must transfer control at scope end
- support `switch` keyword, you can `case` a lot of conditions at a time
- support `continue` keyword, implemented by `goto`, available in Lua 5.2 and LuaJIT
- support `defer` keyword in function scope, including anonymous function
- support `class` and `struct` for simpler Object Oriented programming
- support `extension` keyword for extend class/struct
- support `import` keyword for `require` a lot of sub modules at once
- support anonymous function form `{ in }` likes in Swift
- support expression in string like `print("5 + 3 = \(5 + 3)")`

## Forbiden words

for MoonCake compiles to Lua eventually, so it holds all the Lua keywords, but some are forbiden, they can not use as keyword nor variable names:

- end
- function
- then

forget them at this language.

# Content

MoonCake using internal variable like `__name` with double `_` to accomplish some functionality, so please avoiding variable name like this.

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
-- print("Hello, world " .. tostring(600 + 60 + 6) .. " !")
print("Hello, world \(600 + 60 + 6) !")
-- Hello, world 666 !
```

## Comment

support single and multi line comment.

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

default is local scope, unless using `export` keyword.

you can export variable, function, table, class and struct.

```lua
-- local a = 10
-- b = 11
a = 10
export b = 11
```

you can use `local` to shadow existed variable, like in Lua

```lua
local b = 10
```

and when using global variable defined in another library not export before, will cause undefined variable error.

### export *

you can `export *` all current scope variables, for case using with setfenv or debug.setupvalue(), redefined _ENV in runtime

```lua
--[[
  function call() {
    return variable_not_in_current_file
  }
]]
fn call() {
  export *
  return variable_not_in_curernt_file
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
    "nil",
    "true",
    "false",
```

### operators

`+=`, `-=`, `*=`, `/=`, `//=`, `^=`, `%=`, `&=`, `|=`, `>>=`, `<<=`, `..=`, `or=`, `and=` operators was added for convenient as expended form

```lua
--[[
  a = a + 100
]]
a += 100
```


## Table

likes in Lua, plus bare key support number and string, if key and value are same lexical identifier, just `=key` to name it,
add paired `[` and `]` when you need expression key.

```lua
--[[
local a = 3
local tbl = { 1, "2", 3 + 5, ["5"] = 6, [8] = '28', a = a, [next(_G)] = 'what' }
]]
a = 3
tbl = {
  1,
  "2",
  3 + 5,
  "5" = 6,
  8 = '28',
  =a,
  [next(_G)] = 'what'
}
```

## Function

function definition has shorten keyword `fn`, and holding codes with paired `{` and `}`, the origin `function`, `end` became forbidden words.

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

but recommended using `class` or `struct` keyword to achive these, for a better object oriented style.

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

another is more like in Swift, just a sugar, using keyword `in` inside curly braces

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
--[[
  local a = function()end
  local b = function()end
]]
a = fn(){}
b = {in} -- or { _ in }
```

### defer

`defer` is a keyword to perform some work before leaving function scope, not like Swift in all scope.

and defer only take effect after its definition, with the latest defer block will perform first, just last in first out (LIFO), like in stack.

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
        local __df={};
        local __dr=function() local __t=__df; for __i=#__t, 1, -1 do __t[__i]() end;end;
        local fp = io.open("record", "w")
        if fp == nil then
                return -1
        end
        __df[#__df+1] = function()
                fp:close()
                -- do not return anything
        end
        -- write something
        if a < 5 then
                return 5, __dr()
        end
        -- write something
        -- return nil
        __dr()
  end
]]
```

if you return anything inside defer block, will cause parser error.

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

support `for`, `while`, `repeat` ... `until`, likes in Lua

### for

just replace `do`, `end` with `{` and `}`, keyword `end` is forbidden.

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

likes in Lua, until expression can use variable defined after `repeat`

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

support keyword `if`, `elseif`, `else`, change `then`, `end` to `{` and `}`

```lua
--[[
  if true then
  end
]]
if true {
}
```

`else` example

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

or `elseif` example

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

`guard` is a sugar of `if not`, and it will check last `break`/`continue`/`goto`/`return` keyword in scope end for transfer control.

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

`switch` is a sugar of `if .. then ... elseif .. then .. else .. end`, condition expression of switch will only evaluate once.

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
  local __s = animal
  if __s == 'dog' or __s == 'cat' then
          print("can run")
  elseif __s == 'bird' then
          print("can fly")
  else
          print("can swim")
  end
]]
```

### continue

`continue` implemented by `goto`, not supoprt in Lua 5.1

```lua
for i=1, 10 {
  if i < 5 {
    continue
  }
}
--[[
  for i = 1, 10 do
    if i < 5 then
      goto __c1
    end
    ::__c1::
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

- variable __tn, __tk, __ct, __st (only inherit from other class)
- method isKindOf
- method init / deinit (if defined)

`init`, `deinit` will added when you defined, `deinit` will be called when collectgarbage, but `deinit` will cause instance creation a bit slower.

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
	local __st = nil
	local __cn = "Animal"
	local __ct = Animal
	__ct.__tn = __cn
	__ct.__tk = 'class'
	__ct.__ct = __ct
	__ct.__st = __st
	__ct.isKindOf = function(c, a) return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false end
	-- declare struct var and methods
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<class %s: %p>", __cn, t) end,
		__index = function(t, k)
			local v = __ct[k]
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
	}
	setmetatable(__ct, {
		__tostring = function() return "<class " .. __cn .. ">" end,
		__index = function(_, k)
			local v = __st and __st[k]
			if v ~= nil then rawset(__ct, k, v) end
			return v
		end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(ins.init) == 'function' and ins:init(...) == false then return nil end
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
	local __st = Animal
	local __cn = "Bird"
	local __ct = Bird
	assert(type(__st) == "table" and type(__st.__ct) == "table")
	for k, v in pairs(__st) do __ct[k] = v end
	__ct.__tn = __cn
	__ct.__tk = 'class'
	__ct.__ct = __ct
	__ct.__st = __st
	-- declare struct var and methods
	__ct.wing_count = 2
	function __ct:init(count)
		self.wing_count = count
	end
	function __ct:featherColor()
		return "dark"
	end
	function __ct.hasWings()
		return true
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<class %s: %p>", __cn, t) end,
		__index = function(t, k)
			local v = __ct[k]
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__sub = function(a, b)
			return a.wing_count - b.wing_count
		end,
	}
	setmetatable(__ct, {
		__tostring = function() return "<class " .. __cn .. ">" end,
		__index = function(_, k)
			local v = __st and __st[k]
			if v ~= nil then rawset(__ct, k, v) end
			return v
		end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(ins.init) == 'function' and ins:init(...) == false then return nil end
			return ins
		end,
		__add = function(a, b)
			return a.wing_count + b.wing_count
		end,
	})
end
```

in `init` function, you can return `false` to create a nil instance for caller, cause creation failure.

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

- `self` refers to class instance, you can use it in instance method, likes in Lua
- `Self` refers to class itself in class scope, including variable definition
- `Super` refers to super calss in class scope, including variable definition

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

- variable __tn, __tk, __ct
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
	local __cn = "Car"
	local __ct = Car
	__ct.__tn = __cn
	__ct.__tk = 'struct'
	__ct.__ct = __ct
	-- declare struct var and methods
	__ct._wheel_count = 4
	function __ct:init(wheel_count)
		self._wheel_count = wheel_count
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<struct %s: %p>", __cn, t) end,
		__index = function(t, k)
			local v = rawget(__ct, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,
		__add = function(a, b)
			return a._wheel_count + b._wheel_count
		end,
	}
	Car = setmetatable({}, {
		__tostring = function() return "<struct " .. __cn .. ">" end,
		__index = function(_, k) return rawget(__ct, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(__ct, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(ins.init) == 'function' and ins:init(...) == false then return nil end
			return ins
		end,
	})
end

```

create instance likes class, and you can use `self` or `Self` in instance method or static method.

## Extension

`extension` is the only way to extend class/struct variable/method, the limitation is can not add metamethod.

- support extend class from struct, or extend struct from class
- define new variable/method for class/struct
- can extend class/struct multiple times

```lua
class ClsA {
  name = Self.__tn
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

the last `extension` keyword will expand as

```lua
do
	local __et = ClsA
	local __ct = StructA
	assert(type(__ct) == "table" and type(__ct.__ct) == "table")
	__ct = __ct.__ct
	assert(type(__et) == "table" and type(__et.__ct) == "table")
	for k, v in pairs(__et.__ct) do
		if __ct[k] == nil and (k:len() < 2 or (k:sub(1, 2) ~= "__" and k ~= "__st" and k ~= "isKindOf")) then
			__ct[k] = v
		end
	end
	-- declare struct var and methods
	function __ct:fullName()
		return "struct base: " .. self:getName()
	end
	-- declare end
end
```

## Import

`import` keyword provide a convenient way to require module and its sub modules

```lua
-- require("moocscript.core")
import "moocscript.core"
```

or require to local variable

```lua
-- local core = require("moocscript.core")
import core from "moocscript.core"
```

or only load sub modules

```lua
--[[
  local toAST, toLua
  do
  	local __l = require("moocscript.core")
  	toAST, toLua = __l.toAST, __l.toLua
  end
]]
import toAST, toLua from "moocscript.core" {}
```

and you can load and rename sub modules

```lua
--[[
  local toast, tolua
  do
  	local __l = require("moocscript.core")
  	toast, tolua = __l.toAST, __l.toLua
  end
]]
import toast, tolua from "moocscript.core" { toAST, toLua }
```

you can perform these rules to a table

```lua
-- local insert, remove = table.insert, table.remove
import insert, remove from table {}
```

## Errors

there are two phase for generate Lua code, first it parse source to AST, then translate AST to Lua code, so some error may happen in these phase.

### parse

using source `examples/error/parse_error.mooc` for example

```lua
a = 123.23.23
--[[
Error: malformed number
File: examples/error/parse_error.mooc
Line: 1 (Pos: 10)
Source: a = 123.23.23
                  ^
]]
```

run the source will cause parse error, the right way is using '=' instead of ':' after tbl.

parse error only contains file name, line number and the source line, for it use farthest match position for indicating, sometimes it can not show the right place.

### compile

when we got AST, there are some restriction to generate Lua code, for example

- break should inside loop
- guard should transfer control in the scope end
- defer should inside function

using source `examples/error/compile_error.mooc` for example

```lua
a += 10
--[[
Error: undefined variable
File: examples/error/compile_error.mooc
Line: 1 (Pos: 0)
Source: a += 10
        ^
]]
```

## Debug

you should debug generated .lua source, not .mooc source
