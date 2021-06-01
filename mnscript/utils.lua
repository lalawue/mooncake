--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local Utils = {}
do
	local __stype__ = nil
	local __clsname__ = "Utils"
	local __clstype__ = Utils
	__clstype__.classname = __clsname__
	__clstype__.classtype = __clstype__
	__clstype__.supertype = __stype__
	__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end
	__clstype__.isMemberOf = function(cls, a) return cls.classtype == a end
	-- declare struct var and methods
	function __clstype__.serializeTable(t, p, c, s)
		local n = 0
		for i, v in next, t do
			n = n + 1
		end
		local ti = 1
		local e = n > 0
		local str = ""
		local _table = Utils.serializeTable
		c = c or {  }
		p = p or 1
		s = s or string.rep
		local function _format(v, is_table)
			local out = (type(v) == "string" and ('"' .. v .. '"')) or (type(v) == "number" and ('[' .. tostring(v) .. ']')) or tostring(v)
			return is_table and (c[v][2] >= p) and _table(v, p + 1, c, s) or (type(v) == "string" and ('"' .. v .. '"') or tostring(v))
		end
		c[t] = { t, 0 }
		for i, v in next, t do
			local typ_i, typ_v = type(i) == 'table', type(v) == 'table'
			c[i], c[v] = (not c[i] and typ_i) and { i, p } or c[i], (not c[v] and typ_v) and { v, p } or c[v]
			str = str .. s('  ', p) .. '[' .. _format(i, typ_i) .. '] = ' .. _format(v, typ_v) .. (ti < n and ',' or '') .. '\n'
			ti = ti + 1
		end
		return ('{' .. (e and '\n' or '')) .. str .. (e and s('  ', p - 1) or '') .. '}'
	end
	function __clstype__.split(self, sep, max, regex)
		assert(sep ~= "")
		assert(max == nil or max >= 1)
		local record = {  }
		if self:len() > 0 then
			local plain = not regex
			max = max or -1
			local field, start = 1, 1
			local first, last = self:find(sep, start, plain)
			while first and max ~= 0 do
				record[field] = self:sub(start, first - 1)
				field = field + 1
				start = last + 1
				first, last = self:find(sep, start, plain)
				max = max - 1
			end
			record[field] = self:sub(start)
		else
			record[1] = ""
		end
		return record
	end
	function __clstype__.set(tbl)
		local s = {  }
		for _, v in ipairs(tbl) do
			s[v] = true
		end
		return s
	end
	-- declare after set()
	__clstype__.blank_set = Utils.set({ " ", "\t", "\n", "\r" })
	function __clstype__.trim(self)
		local i = 1
		local j = self:len()
		local blank_set = Utils.blank_set
		while true do
			if blank_set[self:sub(i, i)] then
				i = i + 1
			elseif blank_set[self:sub(j, j)] then
				j = j - 1
			else
				return self:sub(i, j)
			end
		end
		return self
	end
	function __clstype__.seqReduce(tbl, init, func)
		for i, v in ipairs(tbl) do
			init = func(init, i, v)
		end
		return init
	end
	__clstype__.read_option = _VERSION == "Lua 5.1" and "*a" or "a"
	function __clstype__.readFile(file_path)
		local f = io.open(file_path, "rb")
		if not f then
			return 
		end
		local data = f:read(Utils.read_option)
		f:close()
		return data
	end
	function __clstype__.writeFile(file_path, content)
		local f = io.open(file_path, "wb")
		if not f then
			return 
		end
		f:write(content)
		f:close()
		return true
	end
	function __clstype__.debug(str)
		io.write(str .. "\n")
	end
	function __clstype__.dump(t)
		Utils.debug(Utils.serializeTable(t))
	end
	-- position line in content
	function __clstype__.posLine(content, lpos, cpos)
		assert(type(content) == "string", "Invalid content")
		assert(type(lpos) == "number", "Invalid pos")
		local ln_num = 1
		for _ in content:sub(1, lpos):gmatch("\n") do
			ln_num = ln_num + 1
		end
		local num = ln_num
		local ln_content = ""
		for line in content:gmatch("([^\n]*)\n?") do
			if num == 1 then
				ln_content = line
				break
			end
			num = num - 1
		end
		return { line = ln_num, message = ln_content }
	end
	-- declare end
	local __ins_mt__ = {
		__tostring = function() return "instance of " .. __clsname__ end,
		__index = function(t, k)
			local v = rawget(t, k)
			if v ~= nil then return v end
			v = __clstype__[k]
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
	}
	setmetatable(__clstype__, {
		__tostring = function() return "class " .. __clsname__ end,
		__index = function(_, k)
			local v = rawget(__clstype__, k)
			return ((v ~= nil) and v) or (__stype__ and __stype__[k])
		end,
		__newindex = function() end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt__)
			return ins
		end,
	})
end
return Utils
