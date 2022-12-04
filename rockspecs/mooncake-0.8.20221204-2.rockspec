package = "mooncake"
version = "0.8.20221204-2"
source = {
   url = "git+https://github.com/lalawue/mooncake",
   tag = "0.8.20221204",
}
description = {
   summary = "Swift like programming language compiles to Lua",
   detailed = [[
   	See https://github.com/lalawue/mooncake for more information.
   ]],
   homepage = "https://github.com/lalawue/mooncake",
   license = "MIT/X11",
   maintainer = "lalawue <suchaaa@gmail.com>"
}
dependencies = {
   "lua >= 5.1",
}
build = {
   type = "builtin",
   modules = {
      ["moocscript.compiler"] = "moocscript/compiler.lua",
      ["moocscript.core"] = "moocscript/core.lua",
      ["moocscript.parser"] = "moocscript/parser.lua",
      ["moocscript.utils"] = "moocscript/utils.lua",
      ["moocscript.class"] = "moocscript/class.lua",
      ["moocscript.repl"] = "moocscript/repl.lua",
   },
   install = {
      bin = {
         "bin/moocscript"
      }
   }
}
