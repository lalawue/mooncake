local MoocLib = require("moocscript.class")

-- create ClassA with no inherit
local ClassA = MoocLib.newMoocClass("A")

-- will be called when create ClassA's instance with ClassA(...)
function ClassA:init(...)
        print('init ' .. tostring(self))
end

function ClassA:getName()
        return tostring(self)
end

-- create ClassC inherit from ClassA
local ClassC = MoocLib.newMoocClass("C", ClassA)

-- getName inherit from ClassA
function ClassC:sayHi()
        print('hello ' .. self:getName())
end

local c = ClassC()
c:sayHi()
-- init <class C: 0x0004c440>
-- hello <class C: 0x0004c440>