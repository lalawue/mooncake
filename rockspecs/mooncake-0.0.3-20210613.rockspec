package = "mooncake"
version = "0.0.3-20210613"
source = {
   url = "git+https://github.com/lalawue/mooncake"
}
description = {
   summary = "MoonCake is Swift like programming language compiles to Lua",
   detailed = "MoonCake is Swift like programming language compiles to Lua",
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
   },
   install = {
      bin = {
         "bin/moocscript"
      }
   }
}
