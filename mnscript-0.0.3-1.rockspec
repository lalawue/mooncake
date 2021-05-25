package = "mnscript"
version = "0.0.3-1"
source = {
   url = "git+https://gitee.com/lalawue/mnscript"
}
description = {
   summary = "MNScript is Swift like programming language compiles to Lua",
   detailed = "MNScript is Swift like programming language compiles to Lua",
   homepage = "https://gitee.com/lalawue/mnscript",
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
      ["mnscript.cmdline"] = "mnscript/cmdline.lua",      
      ["mnscript.compile"] = "mnscript/compile.lua",
      ["mnscript.core"] = "mnscript/core.lua",
      ["mnscript.parser"] = "mnscript/parser.lua",
      ["mnscript.utils"] = "mnscript/utils.lua",
   },
   install = {
      bin = {
         "bin/mnscript"
      }
   }
}
