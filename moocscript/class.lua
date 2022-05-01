local fType = type
local fAssert = assert
local fRawSet = rawset
local sfmt = string.format
local function newMoocClass(cls_name, super_type)
	if not (fType(cls_name) == "string") then
		return nil
	end
	local cls_type = { __tn = cls_name, __tk = 'class', __st = super_type }
	cls_type.__ct = cls_type
	if super_type then
		assert(type(super_type) == "table" and type(super_type.__ct) == "table" and super_type.__tk == "class")
	else 
		cls_type.isKindOf = function(c, a)
			return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false
		end
	end
	local ins_mt = { __tostring = function(t)
		return sfmt("<class %s: %p>", cls_name, t)
	end, __index = function(t, k)
		local v = cls_type[k]
		if v ~= nil then
			fRawSet(t, k, v)
		end
		return v
	end }
	setmetatable(cls_type, { __tostring = function()
		return "<class " .. cls_name .. ">"
	end, __index = function(_, k)
		local v = super_type and super_type[k]
		if v ~= nil then
			fRawSet(cls_type, k, v)
		end
		return v
	end, __call = function(_, ...)
		local ins = setmetatable({  }, ins_mt)
		if type(ins.init) == 'function' and ins:init(...) == false then
			return nil
		end
		return ins
	end })
	return cls_type
end
local function newMoocStruct(cls_name)
	if not (fType(cls_name) == "string") then
		return nil
	end
	local cls_type = { __tn = cls_name, __tk = 'struct' }
	cls_type.__ct = cls_type
	local ins_mt = { __tostring = function(t)
		return sfmt("<struct %s: %p>", cls_name, t)
	end, __index = function(t, k)
		local v = rawget(cls_type, k)
		if v ~= nil then
			rawset(t, k, v)
		end
		return v
	end, __newindex = function(t, k, v)
		if rawget(cls_type, k) ~= nil then
			rawset(t, k, v)
		end
	end }
	return setmetatable({  }, { __tostring = function()
		return "<struct " .. cls_name .. ">"
	end, __index = function(_, k)
		return rawget(cls_type, k)
	end, __newindex = function(_, k, v)
		if v ~= nil and rawget(cls_type, k) ~= nil then
			rawset(cls_type, k, v)
		end
	end, __call = function(_, ...)
		local ins = setmetatable({  }, ins_mt)
		if type(ins.init) == 'function' and ins:init(...) == false then
			return nil
		end
		return ins
	end }), cls_type
end
local function extentMoocClassStruct(cls, ext)
	assert(type(cls) == "table" and type(cls.__ct) == "table" and (cls.__tk == 'class' or cls.__tk == 'struct'))
	local ct = cls.__ct
	if ext then
		assert(type(ext) == "table" and type(ext.__ct) == "table" and (ext.__tk == 'class' or ext.__tk == 'struct'))
		for k, v in pairs(ext.__ct) do
			if ct[k] == nil and (k:len() < 2 or (k:sub(1, 2) ~= "__" and k ~= "__st" and k ~= "isKindOf")) then
				ct[k] = v
			end
		end
	end
	return ct
end
return { newMoocClass = newMoocClass, newMoocStruct = newMoocStruct, extentMoocClassStruct = extentMoocClassStruct }
