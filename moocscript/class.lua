--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local fType = type
local fAssert = assert
local fRawSet = rawset
local function dummy_init()
end
-- create or inherit mooc_class from Lua side
local function newMoocClass(cls_name, super_type)
	if not (fType(cls_name) == "string") then
		return nil
	end
	if not (super_type == nil or fType(super_type) == "table") then
		return nil
	end
	local cls_type = {  }
	cls_type.typename = cls_name
	cls_type.typekind = 'class'
	cls_type.classtype = cls_type
	cls_type.supertype = super_type
	if not super_type then
		cls_type.isKindOf = function(cls, a)
			return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false
		end
	end
	cls_type.init = dummy_init
	local ins_mt = { ["__tostring"] = function()
		return "instance of " .. cls_name
	end, ["__index"] = function(t, k)
		local v = cls_type[k]
		if v ~= nil then
			fRawSet(t, k, v)
		end
		return v
	end }
	setmetatable(cls_type, { ["__tostring"] = function()
		return "class " .. cls_name
	end, ["__index"] = function(_, k)
		local v = super_type and super_type[k]
		if v ~= nil then
			fRawSet(cls_type, k, v)
		end
		return v
	end, ["__call"] = function(_, ...)
		local ins = setmetatable({  }, ins_mt)
		if ins:init(...) == false then
			return nil
		end
		return ins
	end })
	return cls_type
end
return setmetatable({  }, { ["__call"] = function(_, ...)
	return newMoocClass(...)
end })
