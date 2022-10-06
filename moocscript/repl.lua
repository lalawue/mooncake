local Core = require("moocscript.core")
local Utils = require("moocscript.utils")
local M = { __tn = 'M', __tk = 'class', __st = nil }
do
	local __st = nil
	local __ct = M
	__ct.__ct = __ct
	__ct.isKindOf = function(c, a) return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false end
	-- declare class var and methods
	__ct._config = { shebang = false, fi_scope = { ["*"] = true } }
	function __ct:loadString(text)
		local ret, emsg = Core.toAST(self._config, text)
		if not (ret) then
			Utils.debug(emsg)
			return false
		end
		ret, emsg = Core.toLua(self._config, ret)
		if not (ret) then
			Utils.debug(emsg)
			return false
		end
		ret, emsg = (loadstring or load)(ret)
		if not (ret) then
			Utils.debug(emsg)
			return false
		end
		ret()
		return true
	end
	function __ct:checkPaired(input_text)
		local paired = 0
		for i = 1, input_text:len() do
			local ch = string.char(input_text:byte(i))
			local __s = ch
			if __s == '[' or __s == '(' or __s == '{' then
				paired = paired + 1
			elseif __s == ']' or __s == ')' or __s == '}' then
				paired = paired - 1
			end
		end
		return paired <= 0
	end
	function __ct:start()
		Utils.debug(Core.version())
		Utils.debug('> export * -- default global variable')
		local input_text = "export *"
		while true do
			if self:loadString(input_text) then
				io.write("> ")
			end
			input_text = ''
			repeat
				input_text = input_text ..  (input_text:len() > 0 and '\n' or '')
				input_text = input_text .. (io.read() or '')
			until self:checkPaired(input_text)
		end
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<class M: %p>", t) end,
		__index = function(t, k)
			local v = __ct[k]
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
	}
	setmetatable(__ct, {
		__tostring = function() return "<class M>" end,
		__index = function(t, k)
			local v = __st and __st[k]
			if v ~= nil then rawset(__ct, k, v) end
			return v
		end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(rawget(__ct,'init')) == 'function' and __ct.init(ins,...) == false then return nil end
			return ins
		end,
	})
end
return M
