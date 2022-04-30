local MoocCore = require("moocscript.core")

local f = MoocCore.loadfile("exp_lib.mooc")
print("loadfile", f, f(), f().pr == print)

local d = MoocCore.dofile("exp_lib.mooc")
print("dofile", d, d.pr == print)

local l = MoocCore.loadstring("return { pr = print }")
print("loadstring", l, l().pr == print)

-- loadfile        function: 0x00078ff8    table: 0x00078be8       true
-- dofile          table: 0x0005a538       true
-- loadstring      function: 0x0005b110    true