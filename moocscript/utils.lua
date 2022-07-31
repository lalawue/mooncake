local ipairs = ipairs
local Utils = { __tn = 'Utils', __tk = 'struct' }
do
	local __ct = Utils
	__ct.__ct = __ct
	-- declare struct var and methods
	function __ct.printValue(v)
		local tv = type(v)
		if tv == "string" then
			local first = v:sub(1, 1)
			if first == '"' or first == "'" or first == '[' then
				return v
			else 
				return '"' .. v .. '"'
			end
		else 
			return tostring(v)
		end
	end
	function __ct.format(c, p, v, is_table)
		return is_table and (c[v][2] >= p) and Utils.serializeTable(v, p + 1, c) or Utils.printValue(v)
	end
	function __ct.serializeTable(t, p, c)
		local n = 0
		for i, v in next, t do
			n = n + 1
		end
		local ti = 1
		local e = n > 0
		local str = ""
		local _table = Utils.serializeTable
		local _format = Utils.format
		local _srep = string.rep
		c = c or {  }
		p = p or 1
		c[t] = { t, 0 }
		for i, v in next, t do
			local typ_i, typ_v = type(i) == 'table', type(v) == 'table'
			c[i], c[v] = (not c[i] and typ_i) and { i, p } or c[i], (not c[v] and typ_v) and { v, p } or c[v]
			str = str .. _srep('  ', p) .. '[' .. _format(c, p, i, typ_i) .. '] = ' .. _format(c, p, v, typ_v) .. (ti < n and ',' or '') .. '\n'
			ti = ti + 1
		end
		return ('{' .. (e and '\n' or '')) .. str .. (e and _srep('  ', p - 1) or '') .. '}'
	end
	function __ct.split(self, sep, max, regex)
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
	function __ct.set(tbl)
		local s = {  }
		for _, v in ipairs(tbl) do
			s[v] = true
		end
		return s
	end
	__ct.blank_set = Utils.set({ " ", "\t", "\n", "\r" })
	function __ct.trim(self)
		local i = 1
		local j = self:len()
		local blank_set = Utils.blank_set
		while i <= j do
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
	function __ct.seqReduce(tbl, init, func)
		for i, v in ipairs(tbl) do
			init = func(init, i, v)
		end
		return init
	end
	__ct.read_option = _VERSION == "Lua 5.1" and "*a" or "a"
	function __ct.readFile(file_path)
		local f, err = io.open(file_path, "rb")
		if not f then
			return nil, err
		end
		local data = f:read(Utils.read_option)
		f:close()
		return data
	end
	function __ct.writeFile(file_path, content)
		local f = io.open(file_path, "wb")
		if not f then
			return 
		end
		f:write(content)
		f:close()
		return true
	end
	function __ct.copy(it)
		local ot = {  }
		for k, v in pairs(it) do
			ot[k] = v
		end
		return ot
	end
	function __ct.suffix(str)
		for i = str:len(), 1, -1 do
			if str:sub(i, i) == '.' then
				return str:sub(i + 1, str:len())
			end
		end
		return ""
	end
	function __ct.debug(str)
		io.write(str .. "\n")
	end
	function __ct.dump(t)
		Utils.debug(Utils.serializeTable(t))
	end
	function __ct.posLine(content, lpos)
		assert(type(content) == "string", "Invalid content")
		assert(type(lpos) == "number", "Invalid pos")
		local ln_lnum = 1
		for _ in content:sub(1, lpos):gmatch("\n") do
			ln_lnum = ln_lnum + 1
		end
		local lnum = ln_lnum
		local ln_content = ""
		local lcount = 0
		for line in content:gmatch("([^\n]*\n?)") do
			if lnum == 1 then
				ln_content = line
				break
			end
			lnum = lnum - 1
			lcount = lcount + line:len()
		end
		return { line = ln_lnum, column = lpos - lcount, message = ln_content:gsub('[\n\r]', '') }
	end
	function __ct.errorMessage(content, pos, msg, fname)
		local ct = Utils.posLine(content, pos)
		return string.format("Error: %s\nFile: %s\nLine: %d (Pos: %d)\nSource: %s\n%s", msg, fname or '_', ct.line, pos, ct.message, string.rep(' ', 8) .. ct.message:gsub('[^%s]', ' '):sub(1, math.max(0, ct.column)) .. '^')
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<struct Utils: %p>", t) end,
		__index = function(t, k)
			local v = rawget(__ct, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,
	}
	Utils = setmetatable({}, {
		__tostring = function() return "<struct Utils>" end,
		__index = function(_, k) return rawget(__ct, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(__ct, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(rawget(__ct,'init')) == 'function' and __ct.init(ins,...) == false then return nil end
			return ins
		end,
	})
end
return Utils
