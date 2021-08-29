package = "mooncake"
version = "scm-1"
source = {
   url = "git+https://github.com/lalawue/mooncake",
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
   "lpeg >= 1.0.2",
   "luafilesystem >= 1.5"
}
build = {
   type = "builtin",
   modules = {
      ["moocscript.compile"] = "moocscript/compile.lua",
      ["moocscript.core"] = "moocscript/core.lua",
      ["moocscript.parser"] = "moocscript/parser.lua",
      ["moocscript.utils"] = "moocscript/utils.lua",
      ["moocscript.class"] = "moocscript/class.lua",
   },
   install = {
      bin = {
         "bin/moocscript"
      }
   }
}
