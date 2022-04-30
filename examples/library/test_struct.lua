local MoocLib = require("moocscript.class")

-- create StructA
local StructA, RawStructA = MoocLib.newMoocStruct("A")

-- using RawStructA to build your new function or variable
function RawStructA:init(...)
        print(tostring(self) .. ' init ' .. (... or ''))
end

local a = StructA('1')
-- <struct A: 0x0004dac0> init 1

StructA.try_newindex = 1
print(StructA.try_newindex)
-- nil

a.try_newindex = 1
print(a.try_newindexs)
-- nil