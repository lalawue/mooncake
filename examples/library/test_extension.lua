local MoocLib = require("moocscript.class")

-- create ClassA with no inherit
local ClassA = MoocLib.newMoocClass("A")

function ClassA:getName()
        return tostring(self)
end

-- create StructB
local StructB, RawStructB = MoocLib.newMoocStruct('B')

function RawStructB:sayHi()
        return 'Say Hi from StructB'
end

local b1 = StructB()
print(b1:sayHi())

local ExtStructB = MoocLib.extentMoocClassStruct(StructB, ClassA)

function ExtStructB:sayHi()
        return 'Say Hi from Ext ' .. self:getName()
end

function ExtStructB:goodBye()
        return 'Goodby'
end

local b2 = StructB()
print(b2:sayHi())
print(b2:goodBye())
-- Say Hi from StructB
-- Say Hi from Ext <struct B: 0x0004de50>
-- Goodby