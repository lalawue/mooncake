
# MoonCake

MoonCake was a bit Swift like language compares to Lua, main difference are

- always declare variable as 'local', unless using 'export' keyword, otherwise will cause `undefined` assertion
- using parentheses '{' and '}' instead of keyword 'do', 'then', 'end' to seperate code block, can easily folding code block in VSCode
- support 'guard' keyword, which must transfer control at the block end
- support 'switch' keyword, you can 'case' a lot of conditions at a time
- support 'continue' keyword, implemented by 'goto', available in Lua 5.2 and LuaJIT, also has the limitation where the 'goto' has
- support 'defer' keyword in function scope, including anonymous function
- support 'class' and 'struct' for simpler Object Oriented programming
- support 'import' keyword for simpler 'require' a lot of sub modules
- can declare anonymous function as '{ _ in }' style, a bit like in Swift

## Forbiden words

for MoonCake compiles to Lua eventually, so it holds all the Lua keywords, but some are forbiden, they can not use as keyword nor variable names:

- end
- function
- then

forget them at this language.

# Content

* String / Number
* Comment
* Assigment & Scope
* Table
* Function
  * fn
  * anonymous
  * defer
* Do statement
* Loop
  * for
  * while
  * repeat / until
* Flow Control
  * if
  * guard
  * switch
  * continue
  * break
  * goto
* Class
* Struct
* Extension
* Import
