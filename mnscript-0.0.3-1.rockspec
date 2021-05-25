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
build = {
   type = "builtin",
   modules = {
      ["core.mn_compile"] = "core/mn_compile.lua",
      ["core.mn_core"] = "core/mn_core.lua",
      ["core.mn_loader"] = "core/mn_loader.lua",
      ["core.mn_parser"] = "core/mn_parser.lua",
      ["core.mn_utils"] = "core/mn_utils.lua",
   }
}
