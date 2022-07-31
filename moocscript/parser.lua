local Utils = require("moocscript.utils")
local srep = string.rep
local math_huge = math.huge
local unpack = unpack or table.unpack
local tostring = tostring
local Token = { Illegal = "illegal", Eof = "eof", Identifier = "identifier", Number = "number", String = "string", StringExprD = "string+d", StringExprS = "string+s", Comment = "comment", SheBang = "shebang", Vararg = "...", SepSemi = ";", SepComma = ",", SepDot = ".", SepColon = ":", SepLabel = "::", SepLparen = "(", SepRparen = ")", SepLbreak = "[", SepRbreak = "]", SepLcurly = "{", SepRcurly = "}", OpAssign = "=", OpMinus = "-", OpWav = "~", OpAdd = "+", OpMul = "*", OpDiv = "/", OpIdiv = "//", OpPow = "^", OpMod = "%", OpBand = "&", OpBor = "|", OpShr = ">>", OpShl = "<<", OpConcat = "..", OpLt = "<", OpLe = "<=", OpGt = ">", OpGe = ">=", OpEq = "==", OpNe = "~=", OpNb = "!=", OpNen = "#", OpAnd = "and", OpOr = "or", OpNot = "not", KwBreak = "break", KwCase = "case", KwClass = "class", KwContinue = "continue", KwDefault = "default", KwDefer = "defer", KwDo = "do", KwElse = "else", KwElseIf = "elseif", KwExport = "export", KwExtension = "extension", KwFalse = "false", KwFn = "fn", KwFor = "for", KwFrom = "from", KwGoto = "goto", KwGuard = "guard", KwIf = "if", KwImport = "import", KwIn = "in", KwLocal = "local", KwNil = "nil", KwPublic = "public", KwRepeat = "repeat", KwReturn = "return", KwStatic = "static", KwStruct = "struct", KwSwitch = "switch", KwTrue = "true", KwUntil = "until", KwWhile = "while" }
local ReservedWord = { [Token.OpAnd] = Token.OpAnd, [Token.OpOr] = Token.OpOr, [Token.OpNot] = Token.OpNot, [Token.KwBreak] = Token.KwBreak, [Token.KwCase] = Token.KwCase, [Token.KwClass] = Token.KwClass, [Token.KwContinue] = Token.KwContinue, [Token.KwDefault] = Token.KwDefault, [Token.KwDefer] = Token.KwDefer, [Token.KwDo] = Token.KwDo, [Token.KwElse] = Token.KwElse, [Token.KwElseIf] = Token.KwElseIf, [Token.KwExport] = Token.KwExport, [Token.KwExtension] = Token.KwExtension, [Token.KwFalse] = Token.KwFalse, [Token.KwFn] = Token.KwFn, [Token.KwFor] = Token.KwFor, [Token.KwFrom] = Token.KwFrom, [Token.KwGoto] = Token.KwGoto, [Token.KwGuard] = Token.KwGuard, [Token.KwIf] = Token.KwIf, [Token.KwImport] = Token.KwImport, [Token.KwIn] = Token.KwIn, [Token.KwLocal] = Token.KwLocal, [Token.KwNil] = Token.KwNil, [Token.KwPublic] = Token.KwPublic, [Token.KwRepeat] = Token.KwRepeat, [Token.KwReturn] = Token.KwReturn, [Token.KwStatic] = Token.KwStatic, [Token.KwStruct] = Token.KwStruct, [Token.KwSwitch] = Token.KwSwitch, [Token.KwTrue] = Token.KwTrue, [Token.KwUntil] = Token.KwUntil, [Token.KwWhile] = Token.KwWhile }
local CharSymbol = { [Token.SepSemi] = true, [Token.SepComma] = true, [Token.SepLparen] = true, [Token.SepRparen] = true, [Token.SepRbreak] = true, [Token.SepLcurly] = true, [Token.SepRcurly] = true, [Token.OpAdd] = true, [Token.OpMul] = true, [Token.OpPow] = true, [Token.OpMod] = true, [Token.OpBand] = true }
local ArithmeticOp = { [Token.OpAdd] = true, [Token.OpMinus] = true, [Token.OpMul] = true, [Token.OpDiv] = true, [Token.OpIdiv] = true, [Token.OpPow] = true, [Token.OpMod] = true }
local BitwiseOp = { [Token.OpBand] = true, [Token.OpBor] = true, [Token.OpWav] = true, [Token.OpShr] = true, [Token.OpShl] = true }
local RelationalOp = { [Token.OpEq] = true, [Token.OpNe] = true, [Token.OpNb] = true, [Token.OpLt] = true, [Token.OpLe] = true, [Token.OpGt] = true, [Token.OpGe] = true }
local LogicalOp = { [Token.OpAnd] = true, [Token.OpOr] = true }
local CharBlank = { [' '] = true, ['\t'] = true, ['\n'] = true, ['\r'] = true, ['\v'] = true, ['\f'] = true }
local function unp(a)
	if a then
		return unpack(a)
	end
end
local function isBinOp(t)
	return (t == Token.OpConcat) or ArithmeticOp[t] or BitwiseOp[t] or RelationalOp[t] or LogicalOp[t]
end
local function isDigit(ch)
	return ch >= '0' and ch <= '9'
end
local function isLetter(ch)
	return (ch >= 'a' and ch <= 'z') or (ch >= 'A' and ch <= 'Z')
end
local function isHex(ch)
	return (ch >= '0' and ch <= '9') or (ch >= 'a' and ch <= 'f') or (ch >= 'A' and ch <= 'F')
end
local _schar = string.char
local function schar(byte)
	if (byte >= 0 and byte <= 31) or byte == 127 then
		return ' '
	end
	return _schar(byte)
end
local QuickStack = { __tn = 'QuickStack', __tk = 'struct' }
do
	local __ct = QuickStack
	__ct.__ct = __ct
	-- declare struct var and methods
	__ct._array = {  }
	__ct._index = 0
	function __ct:reset()
		self._index = 0
	end
	function __ct:dataOp()
		return self._array, self._index
	end
	function __ct:incTop()
		self._index = self._index + 1
		local t = self._array[self._index] or {  }
		self._array[self._index] = t
		return t
	end
	function __ct:decTop()
		if not (self._index > 0) then
			return 
		end
		local t = self._array[self._index]
		self._index = self._index - 1
		return t
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<struct QuickStack: %p>", t) end,
		__index = function(t, k)
			local v = rawget(__ct, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,
	}
	QuickStack = setmetatable({}, {
		__tostring = function() return "<struct QuickStack>" end,
		__index = function(_, k) return rawget(__ct, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(__ct, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(rawget(__ct,'init')) == 'function' and __ct.init(ins,...) == false then return nil end
			return ins
		end,
	})
end
local GroupMap = { __tn = 'GroupMap', __tk = 'struct' }
do
	local __ct = GroupMap
	__ct.__ct = __ct
	-- declare struct var and methods
	__ct._gcount = 1
	__ct._imap = {  }
	__ct._atop = 0
	__ct._array = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	__ct._ret = { 0, 0, 0, 0 }
	function __ct:init(gcount)
		self._gcount = gcount
	end
	function __ct:reset()
		self._atop = 0
		self._imap = {  }
	end
	function __ct:set(key, ...)
		if not (key and select('#', ...) == self._gcount) then
			return 
		end
		local ret = self._ret
		ret[1], ret[2], ret[3], ret[4] = ...
		local base = self._atop
		for i = 1, self._gcount do
			self._array[base + i] = ret[i]
		end
		self._imap[key] = self._atop
		self._atop = self._atop + self._gcount
	end
	function __ct:get(key)
		local base = self._imap[key or self._array]
		if not (key and base) then
			return 
		end
		local ret = self._ret
		for i = 1, self._gcount do
			ret[i] = self._array[base + i]
		end
		return ret[1], ret[2], ret[3], ret[4]
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<struct GroupMap: %p>", t) end,
		__index = function(t, k)
			local v = rawget(__ct, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,
	}
	GroupMap = setmetatable({}, {
		__tostring = function() return "<struct GroupMap>" end,
		__index = function(_, k) return rawget(__ct, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(__ct, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(rawget(__ct,'init')) == 'function' and __ct.init(ins,...) == false then return nil end
			return ins
		end,
	})
end
local Lexer = { __tn = 'Lexer', __tk = 'struct' }
do
	local __ct = Lexer
	__ct.__ct = __ct
	-- declare struct var and methods
	__ct._chunk = ""
	__ct._pos = 0
	__ct._pmap = GroupMap(4)
	__ct._pstack = {  }
	__ct._ptop = 0
	__ct._err_msg = false
	function __ct:reset(chunk)
		self._chunk = chunk
		self._pos = 0
		self._pmap:reset()
		self._ptop = 0
		self._err_msg = false
	end
	function __ct:savePos()
		self._ptop = self._ptop + 1
		self._pstack[self._ptop] = self._pos
	end
	function __ct:restorePos()
		if self._ptop > 0 then
			self._pos = self._pstack[self._ptop]
			self._ptop = self._ptop - 1
		end
	end
	function __ct:clearPos()
		if self._ptop > 0 then
			self._ptop = self._ptop - 1
		end
	end
	function __ct:peekToken(advance)
		if not (self._pos < self._chunk:len()) then
			return Token.Eof
		end
		local opos = self._pos
		local token, tcontent, tpos, npos = self._pmap:get(self._pos)
		if token then
			if advance then
				self._pos = npos
			end
			return token, tcontent, tpos, opos
		else 
			self:skipSpacesComments()
			npos = self._pos
		end
		token, tcontent, tpos = Token.Illegal, nil, self._pos + 1
		local ch = self:nextChar()
		local __s = ch
		if __s == '#' then
			if '!' == self:peekChar() and self._pos == 1 then
				token = Token.SheBang
				tcontent = "#" .. self:oneLine()
			else 
				token = Token.OpNen
				tcontent = Token.OpNen
			end
		elseif __s == '-' then
			token = Token.OpMinus
			tcontent = Token.OpMinus
		elseif __s == '.' then
			if '.' == self:peekChar() then
				self._pos = self._pos + 1
				if '.' == self:peekChar() then
					self._pos = self._pos + 1
					token = Token.Vararg
					tcontent = Token.Vararg
				else 
					token = Token.OpConcat
					tcontent = Token.OpConcat
				end
			elseif isDigit(self:peekChar()) then
				token = Token.Number
				tcontent = self:oneNumber(ch)
			else 
				token = Token.SepDot
				tcontent = Token.SepDot
			end
		elseif __s == '"' or __s == "'" then
			token, tcontent = self:shortString(ch)
		elseif __s == '[' then
			local nch = self:peekChar()
			if nch == '[' or nch == '=' then
				token = Token.String
				tcontent = self:longString()
			else 
				token = Token.SepLbreak
				tcontent = Token.SepLbreak
			end
		elseif __s == '/' then
			if '/' == self:peekChar() then
				self._pos = self._pos + 1
				token = Token.OpIdiv
				tcontent = Token.OpIdiv
			else 
				token = Token.OpDiv
				tcontent = Token.OpDiv
			end
		elseif __s == '>' then
			local nch = self:peekChar()
			if nch == '>' then
				self._pos = self._pos + 1
				token = Token.OpShr
				tcontent = Token.OpShr
			elseif nch == '=' then
				self._pos = self._pos + 1
				token = Token.OpGe
				tcontent = Token.OpGe
			else 
				token = Token.OpGt
				tcontent = Token.OpGt
			end
		elseif __s == '<' then
			local nch = self:peekChar()
			if nch == '<' then
				self._pos = self._pos + 1
				token = Token.OpShl
				tcontent = Token.OpShl
			elseif nch == '=' then
				self._pos = self._pos + 1
				token = Token.OpLe
				tcontent = Token.OpLe
			else 
				token = Token.OpLt
				tcontent = Token.OpLt
			end
		elseif __s == '=' then
			if '=' == self:peekChar() then
				self._pos = self._pos + 1
				token = Token.OpEq
				tcontent = Token.OpEq
			else 
				token = Token.OpAssign
				tcontent = Token.OpAssign
			end
		elseif __s == '~' then
			if '=' == self:peekChar() then
				self._pos = self._pos + 1
				token = Token.OpNe
				tcontent = Token.OpNe
			else 
				token = Token.OpWav
				tcontent = Token.OpWav
			end
		elseif __s == '!' then
			if '=' == self:peekChar() then
				self._pos = self._pos + 1
				token = Token.OpNb
				tcontent = Token.OpNb
			end
		elseif __s == ':' then
			if ':' == self:peekChar() then
				self._pos = self._pos + 1
				token = Token.SepLabel
				tcontent = Token.SepLabel
			else 
				token = Token.SepColon
				tcontent = Token.SepColon
			end
		else
			if CharSymbol[ch] then
				token = ch
				tcontent = ch
			elseif isDigit(ch) then
				token = Token.Number
				tcontent = self:oneNumber(ch)
			elseif ch == '_' or isLetter(ch) then
				tcontent = self:oneIdentifier()
				if tcontent:len() > 0 then
					token = ReservedWord[tcontent]
					if not token then
						token = Token.Identifier
					end
				end
			elseif self._pos >= self._chunk:len() then
				token = Token.Eof
				tcontent = ""
				self._pos = npos
			end
		end
		self._pmap:set(npos, token, tcontent, tpos, self._pos)
		if not advance then
			self._pos = npos
		end
		return token, tcontent, tpos, opos
	end
	function __ct:nextTokenKind(kind)
		local t, c, p, pp = self:peekToken(true)
		if t ~= kind then
			self._pos = pp
			self._err_msg = string.format("invalid token '%s'%s, when expected '%s'", t, (t == Token.Identifier) and (' ' .. c) or '', kind)
			error("")
		end
		return t, c, p
	end
	function __ct:nextPos()
		local _, _, p = self:peekToken(true)
		return p
	end
	function __ct:oneComment()
		local s, e = self._chunk:find('%[=*%[', self._pos + 1)
		if s == self._pos + 1 then
			local count = e - s - 1
			s, e = self._chunk:find(']' .. srep('=', count) .. ']', e + 1, true)
			if not e then
				self._err_msg = "unfinished long comment near '<eof>'"
				error("")
			end
		else 
			s, e = self._chunk:find('\n', self._pos + 1)
			e = (e and e - 1) or self._chunk:len()
		end
		if e > self._pos then
			self._pos = e
		end
	end
	function __ct:shortString(sep)
		local pos = self._pos
		while true do
			local ch = self:nextChar()
			if ch:len() <= 0 or (CharBlank[ch] and ch ~= ' ') then
				self._err_msg = "unfinished string"
				error("")
			elseif ch == '\\' and self:peekChar():len() > 0 then
				if (sep == '"' or sep == "'") and self:peekChar() == '(' then
					local s, e, prefix = pos, self._pos - 1, ''
					if self:charAt(pos) ~= sep then
						s = pos + 1
						prefix = sep
					end
					local t = sep == '"' and Token.StringExprD or Token.StringExprS
					return t, (s > e) and '' or (prefix .. self._chunk:sub(s, e) .. sep), s
				end
				self._pos = self._pos + 1
			elseif ch == sep then
				local s, e = pos, self._pos
				if self:charAt(pos) == sep then
					return Token.String, self._chunk:sub(s, e), pos
				else 
					s = s + 1
					return Token.String, (s >= e) and '' or (sep .. self._chunk:sub(s, e)), pos + 1
				end
			end
		end
	end
	function __ct:longString()
		local pos = self._pos
		local ecount = 0
		while self:peekChar() == '=' do
			self._pos = self._pos + 1
			ecount = ecount + 1
		end
		if self:peekChar() ~= '[' then
			self._err_msg = "invalid long string delimiter"
			error("")
		end
		local s, e = self._chunk:find(']' .. srep('=', ecount) .. ']', self._pos + 1, true)
		if not e then
			self._err_msg = "unfinished long string near '<eof>'"
			error("")
		end
		self._pos = e
		return self._chunk:sub(pos, e)
	end
	function __ct:oneNumber(pre_char)
		local pos = self._pos
		local ntype = 1
		local ch = self:peekChar()
		if pre_char == '0' and (ch == 'x' or ch == 'X') then
			self._pos = self._pos + 1
			ntype = 0
		elseif pre_char == '.' then
			ntype = 2
		end
		while true do
			ch = self:peekChar()
			if ch:len() <= 0 then
				if ntype == 0 and self._pos - pos > 1 then
					return self._chunk:sub(pos, self._pos)
				elseif ntype == 2 and self._pos > pos then
					return self._chunk:sub(pos, self._pos)
				elseif ntype == 1 or ntype == 3 then
					return self._chunk:sub(pos, self._pos)
				else 
					break
				end
			elseif ch == '_' then
				break
			elseif ntype == 0 then
				if isHex(ch) then
					self._pos = self._pos + 1
				elseif not isLetter(ch) then
					return self._chunk:sub(pos, self._pos)
				else 
					break
				end
			elseif ntype == 1 then
				if isDigit(ch) then
					self._pos = self._pos + 1
				elseif ch == '.' then
					self._pos = self._pos + 1
					ntype = 2
				elseif ch == 'e' or ch == 'E' then
					self._pos = self._pos + 1
					ntype = 3
					local nch = self:nextChar()
					if not (isDigit(nch) or (nch == '-' and isDigit(self:nextChar()))) then
						break
					end
				elseif not isLetter(ch) then
					return self._chunk:sub(pos, self._pos)
				else 
					break
				end
			elseif ntype == 2 then
				if isDigit(ch) then
					self._pos = self._pos + 1
				elseif (ch == 'e' or ch == 'E') then
					self._pos = self._pos + 1
					ntype = 3
					local nch = self:nextChar()
					if not (isDigit(nch) or (nch == '-' and isDigit(self:nextChar()))) then
						break
					end
				elseif not isLetter(ch) and ch ~= '.' then
					return self._chunk:sub(pos, self._pos)
				else 
					break
				end
			else 
				if isDigit(ch) then
					self._pos = self._pos + 1
				elseif not isLetter(ch) then
					return self._chunk:sub(pos, self._pos)
				else 
					break
				end
			end
		end
		self._err_msg = "malformed number"
		error("")
	end
	function __ct:oneIdentifier()
		local pos = self._pos
		while true do
			local ch = self:peekChar()
			if ch == '_' or isDigit(ch) or isLetter(ch) then
				self._pos = self._pos + 1
			else 
				return self._chunk:sub(pos, self._pos)
			end
		end
	end
	function __ct:oneLine()
		local _, e = self._chunk:find('\n', self._pos + 1, true)
		e = (e and e - 1) or self._chunk:len()
		local content = self._chunk:sub(self._pos + 1, e)
		self._pos = e
		return content
	end
	function __ct:skipSpacesComments()
		while true do
			local ch = self:nextChar()
			if CharBlank[ch] then
			elseif ch == '-' and self:peekChar() == '-' then
				self._pos = self._pos + 1
				self:oneComment()
			else 
				self._pos = self._pos -  (ch:len() > 0 and 1 or 0)
				break
			end
		end
	end
	function __ct:charAt(i)
		if not (i < self._chunk:len()) then
			return ""
		end
		return schar(self._chunk:byte(i))
	end
	function __ct:peekChar()
		if not (self._pos < self._chunk:len()) then
			return ""
		end
		return schar(self._chunk:byte(self._pos + 1))
	end
	function __ct:nextChar()
		if not (self._pos < self._chunk:len()) then
			return ""
		end
		self._pos = self._pos + 1
		return schar(self._chunk:byte(self._pos))
	end
	function __ct:getLastError()
		return self._err_msg, self._pos
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<struct Lexer: %p>", t) end,
		__index = function(t, k)
			local v = rawget(__ct, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,
	}
	Lexer = setmetatable({}, {
		__tostring = function() return "<struct Lexer>" end,
		__index = function(_, k) return rawget(__ct, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(__ct, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(rawget(__ct,'init')) == 'function' and __ct.init(ins,...) == false then return nil end
			return ins
		end,
	})
end
local Parser = { __tn = 'Parser', __tk = 'struct' }
do
	local __ct = Parser
	__ct.__ct = __ct
	-- declare struct var and methods
	__ct._sub_mode = false
	__ct._scopes = QuickStack()
	__ct._lo_count = 0
	__ct._df_in = false
	__ct._err_msg = false
	__ct._pos = false
	__ct._blevel = 0
	__ct._fn_list = {  }
	__ct._fn_map = {  }
	__ct._fn_wrap = false
	function __ct:fReset(chunk)
		self._sub_mode = false
		self._scopes:reset()
		self._lo_count = 0
		self._df_in = false
		self._err_msg = false
		self._pos = false
		self._blevel = 0
		Lexer:reset(chunk)
		local t = self._fn_list
		if #t <= 0 then
			t[#t + 1] = self.stExport
			t[#t + 1] = self.stAssign
			t[#t + 1] = self.stFnCall
			t[#t + 1] = self.stIfElse
			t[#t + 1] = self.stGuard
			t[#t + 1] = self.stClassDef
			t[#t + 1] = self.stDo
			t[#t + 1] = self.stSwitch
			t[#t + 1] = self.stFor
			t[#t + 1] = self.stWhile
			t[#t + 1] = self.stRepeat
			t[#t + 1] = self.stImport
			t[#t + 1] = self.stFnDef
			t[#t + 1] = self.stLabel
			t[#t + 1] = self.stDefer
			t[#t + 1] = self.stLoopEnd
			t[#t + 1] = self.stBlockEnd
			t[#t + 1] = self.stShebang
			self._fn_map[Token.Identifier] = function(self)
				return self:stAssign() or self:stFnCall()
			end
			self._fn_map[Token.KwExport] = function(self)
				return self:stExport() or self:stAssign() or self:stFnDef() or self:stClassDef()
			end
			self._fn_map[Token.KwLocal] = function(self)
				return self:stExport() or self:stAssign() or self:stFnDef() or self:stClassDef()
			end
			self._fn_map[Token.SepLparen] = function(self)
				return self:stAssign() or self:stFnCall()
			end
		end
	end
	function __ct:fAsset(exp, err_msg, pos)
		if not exp then
			self._err_msg = err_msg
			if type(pos) == 'number' then
				self._pos = pos
			elseif type(pos) == 'boolean' then
				self._pos = Lexer:nextPos()
			else 
				self._pos = false
			end
			error("")
		end
	end
	function __ct:getLastError()
		local err_msg, pos = Lexer:getLastError()
		pos = math.max(0, self._pos or pos)
		return err_msg or self._err_msg, pos
	end
	function __ct:fnBodyStart()
		local t = self._scopes:incTop()
		t.scope = 'fn'
		t.df = nil
	end
	function __ct:fnBodyEnd()
		local t = self._scopes:decTop()
		return t and t.df or nil
	end
	function __ct:loBodyStart()
		self._lo_count = self._lo_count + 1
		local t = self._scopes:incTop()
		t.scope = 'lo'
		t.index = self._lo_count
	end
	function __ct:loBodyEnd(body)
		local t = self._scopes:decTop()
		if t.co then
			local ot = body[#body]
			if ot.stype == 'return' or ot.stype == 'break' then
				body[#body] = { stype = 'do', body = { ot } }
			end
			body[#body + 1] = { stype = '::', { etype = "const", value = "__c" .. tostring(t.index), pos = 0 } }
		end
	end
	function __ct:clBodyStart()
		local t = self._scopes:incTop()
		t.scope = 'cl'
		t.cname = nil
		t.sname = nil
		return t
	end
	function __ct:clBodyEnd()
		self._scopes:decTop()
	end
	function __ct:guBodyStart()
		local t = self._scopes:incTop()
		t.scope = 'gu'
		t.term = nil
	end
	function __ct:guBodyEnd()
		return self._scopes:decTop()
	end
	function __ct:isInFn()
		local array, count = self._scopes:dataOp()
		if not (count > 0) then
			return 
		end
		for i = count, 1, -1 do
			local t = array[i]
			if t.scope == 'fn' then
				return t
			end
		end
	end
	function __ct:isInLoop()
		local array, count = self._scopes:dataOp()
		if not (count > 0) then
			return 
		end
		for i = count, 1, -1 do
			local t = array[i]
			if t.scope == 'cl' or t.scope == 'fn' then
				return 
			elseif t.scope == 'lo' then
				return t
			end
		end
	end
	function __ct:isInCls()
		local array, count = self._scopes:dataOp()
		if not (count > 0) then
			return 
		end
		for i = count, 1, -1 do
			local t = array[i]
			if t.scope == 'cl' then
				return t
			end
		end
	end
	function __ct:termInGuard()
		local array, count = self._scopes:dataOp()
		if count > 0 and array[count].scope == 'gu' then
			array[count].term = true
		end
	end
	function __ct:fnWrap()
		return self._fn_wrap
	end
	function __ct:fnMapList(t)
		for i, f in ipairs(self._fn_list) do
			local st = f(self)
			if st then
				self._fn_map[t] = f
				self._fn_wrap = st
				return self.fnWrap
			end
		end
		self._fn_wrap = false
		return self.fnWrap
	end
	function __ct:fParseBlock()
		self._blevel = self._blevel + 1
		local ast = {  }
		repeat
			local t, c, p = Lexer:peekToken()
			local st = (self._fn_map[t] or self:fnMapList(t))(self)
			if st then
				ast[#ast + 1] = st
				if st.stype == "return" then
					self:stSemi(ast, 1)
					t, c, p = Lexer:peekToken()
					if self._blevel == 1 then
						self:fAsset(t == Token.Eof, "'eof' expected after 'return'", p)
					else 
						self:fAsset(t == Token.SepRcurly or t == Token.KwCase or t == Token.KwDefault, "'}', 'case', 'default' expected after 'return'", p)
					end
					break
				end
			end
			st = self:stSemi(ast, math_huge) or st
		until not st or Token.Eof == Lexer:peekToken()
		self._blevel = self._blevel - 1
		if self._blevel == 0 then
			local t, c, p = Lexer:peekToken()
			self:fAsset(Token.Eof == t, "unexpected symbol near '" .. t .. "'", p)
		elseif not self._df_in and #ast > 0 and ast[#ast].stype ~= 'return' then
			local ft = self:isInFn()
			if ft and ft.df then
				ast[#ast + 1] = { stype = 'raw', value = '__dr()' }
			end
		end
		return ast
	end
	function __ct:stSemi(ast, count)
		local i = 0
		while i < count and Token.SepSemi == Lexer:peekToken() do
			Lexer:nextTokenKind(Token.SepSemi)
			i = i + 1
		end
		if i > 0 then
			ast[#ast + 1] = { stype = ';' }
		end
		return i > 0
	end
	function __ct:stShebang()
		local t, c, p = Lexer:peekToken()
		if t == Token.SheBang then
			Lexer:nextTokenKind(t)
			return { stype = "#!", value = c, pos = p }
		end
	end
	function __ct:stExport()
		local t, c, p = Lexer:peekToken()
		if not (t == Token.KwExport or t == Token.KwLocal) then
			return 
		end
		Lexer:savePos()
		Lexer:nextTokenKind(t)
		if t == Token.KwExport and Token.OpMul == Lexer:peekToken() then
			t, c, p = Lexer:nextTokenKind(Token.OpMul)
			Lexer:clearPos()
			return { stype = "ex", attr = t, { etype = '*', value = c, pos = p } }
		end
		if not (Token.Identifier == Lexer:peekToken()) then
			Lexer:restorePos()
			return 
		end
		local nlist = self:etNameList()
		if not (#nlist > 0 and Token.OpAssign ~= Lexer:peekToken()) then
			Lexer:restorePos()
			return 
		end
		Lexer:clearPos()
		return { stype = "ex", attr = t, unp(nlist) }
	end
	function __ct:stAssign()
		Lexer:savePos()
		local attr = nil
		local t, c, p = Lexer:peekToken()
		if t == Token.KwExport or t == Token.KwLocal then
			Lexer:nextTokenKind(t)
			attr = t
		end
		t, c, p = Lexer:peekToken()
		if not (t == Token.Identifier or t == Token.SepLparen) then
			Lexer:restorePos()
			return 
		end
		local vlist = self:etVarList()
		local sub = nil
		t, c, p = Lexer:peekToken(true)
		if t == Token.OpAssign then
		elseif isBinOp(t) and not RelationalOp[t] and Token.OpAssign == Lexer:peekToken(true) then
			sub = t
			self:fAsset(Lexer:charAt(p + t:len()) == Token.OpAssign, "can not keep space between " .. t .. Token.OpAssign, p)
			self:fAsset(#vlist <= 1 or vlist[#vlist].etype == Token.SepDot, "tow much var on equal left")
		else 
			Lexer:restorePos()
			return 
		end
		Lexer:clearPos()
		local elist = self:etExprList("expect exp after assgin", nil, p)
		return { stype = '=', attr = attr, sub = sub, vlist, elist }
	end
	function __ct:stDo()
		if not (Token.KwDo == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwDo)
		Lexer:nextTokenKind(Token.SepLcurly)
		local body = self:fParseBlock()
		Lexer:nextTokenKind(Token.SepRcurly)
		return { stype = "do", body = body }
	end
	function __ct:stIfElse()
		local t, c, p = Lexer:peekToken()
		if not (t == Token.KwIf) then
			return 
		end
		local out = {  }
		repeat
			local st = { sub = t }
			Lexer:nextTokenKind(t)
			st.cond = (t ~= Token.KwElse) and self:etExpr({  }, "expect condition after " .. t) or nil
			Lexer:nextTokenKind(Token.SepLcurly)
			st.body = self:fParseBlock()
			Lexer:nextTokenKind(Token.SepRcurly)
			out[#out + 1] = st
			t, c, p = Lexer:peekToken()
		until t ~= Token.KwElseIf and t ~= Token.KwElse
		return { stype = 'if', unp(out) }
	end
	function __ct:stGuard()
		if not (Token.KwGuard == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwGuard)
		local cond = self:etExpr({  }, "expect condition after guard")
		Lexer:nextTokenKind(Token.KwElse)
		local _, _, p = Lexer:nextTokenKind(Token.SepLcurly)
		self:guBodyStart()
		local body = self:fParseBlock()
		self:fAsset(self:guBodyEnd().term, "'guard' body require return/goto/break/continue to transfer control")
		Lexer:nextTokenKind(Token.SepRcurly)
		return { stype = 'guard', cond = cond, body = body }
	end
	function __ct:stSwitch()
		if not (Token.KwSwitch == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwSwitch)
		local sw_ret = { stype = "switch", cond = self:etExpr({  }, "expect condition after switch") }
		Lexer:nextTokenKind(Token.SepLcurly)
		local df_count = 0
		while true do
			local t, c, p = Lexer:peekToken()
			if t == Token.KwCase then
				Lexer:nextTokenKind(t)
				self._sub_mode = 'case'
				local cond = self:etExprList("expect condition after case")
				self._sub_mode = false
				Lexer:nextTokenKind(Token.SepColon)
				local body = self:fParseBlock()
				sw_ret[#sw_ret + 1] = { cond = cond, body = body }
			elseif t == Token.KwDefault then
				if df_count <= 0 then
					df_count = df_count + 1
					Lexer:nextTokenKind(t)
					Lexer:nextTokenKind(Token.SepColon)
					local body = self:fParseBlock()
					sw_ret[#sw_ret + 1] = { body = body }
				else 
					self:fAsset(false, "too much default case in switch statement")
				end
			else 
				break
			end
		end
		Lexer:nextTokenKind(Token.SepRcurly)
		return sw_ret
	end
	function __ct:stDefer()
		if not (Token.KwDefer == Lexer:peekToken()) then
			return 
		end
		local ft = self:isInFn()
		self:fAsset(ft, "defer only support function scope")
		self:fAsset(not self._df_in, "defer can not inside another defer")
		ft.df = "local __df={};local __dr=function() local __t=__df; for __i=#__t, 1, -1 do __t[__i]() end;end;"
		Lexer:nextTokenKind(Token.KwDefer)
		Lexer:nextTokenKind(Token.SepLcurly)
		self._df_in = true
		local body = self:fParseBlock()
		self._df_in = false
		Lexer:nextTokenKind(Token.SepRcurly)
		return { stype = 'defer', body = body }
	end
	function __ct:stFor()
		if not (Token.KwFor == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwFor)
		local name = self:etNameList()
		self:fAsset(name[#name].value ~= Token.Vararg, "invalid name list after for")
		local sub = nil
		if #name == 1 then
			local t, _, p = Lexer:peekToken(true)
			self:fAsset(t == Token.OpAssign or t == Token.KwIn, "invalid token '" .. t .. "', expected '=' or 'in'", p)
			sub = t
		else 
			sub = Lexer:nextTokenKind(Token.KwIn)
		end
		local step = self:etExprList()
		Lexer:nextTokenKind(Token.SepLcurly)
		self:loBodyStart()
		local body = self:fParseBlock()
		self:loBodyEnd(body)
		Lexer:nextTokenKind(Token.SepRcurly)
		return { stype = 'for', sub = sub, name = name, step = step, body = body }
	end
	function __ct:stWhile()
		if not (Token.KwWhile == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwWhile)
		local cond = self:etExpr({  }, "expect condition after while")
		Lexer:nextTokenKind(Token.SepLcurly)
		self:loBodyStart()
		local body = self:fParseBlock()
		self:loBodyEnd(body)
		Lexer:nextTokenKind(Token.SepRcurly)
		return { stype = 'while', cond = cond, body = body }
	end
	function __ct:stRepeat()
		if not (Token.KwRepeat == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwRepeat)
		Lexer:nextTokenKind(Token.SepLcurly)
		self:loBodyStart()
		local body = self:fParseBlock()
		self:loBodyEnd(body)
		Lexer:nextTokenKind(Token.SepRcurly)
		Lexer:nextTokenKind(Token.KwUntil)
		local cond = self:etExpr({  }, "expect condition after until")
		return { stype = "repeat", cond = cond, body = body }
	end
	function __ct:stFnCall()
		local t, c, p = Lexer:peekToken()
		if not (t == Token.Identifier or t == Token.SepLparen) then
			return 
		end
		Lexer:savePos()
		local expr = self:etExpr({  })
		if not (expr and #expr > 0 and expr[#expr].etype == '(') then
			Lexer:restorePos()
			return 
		end
		Lexer:clearPos()
		return { stype = '(', expr }
	end
	function __ct:stImport()
		if not (Token.KwImport == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.KwImport)
		if Token.String == Lexer:peekToken() then
			local t, c, p = Lexer:nextTokenKind(Token.String)
			return { stype = 'import', lib = { etype = 'const', value = c, pos = p } }
		end
		local vlist = self:etNameList()
		self:fAsset(#vlist > 0 and (vlist[#vlist].value ~= Token.Vararg), "please provide valid var name after import")
		Lexer:nextTokenKind(Token.KwFrom)
		local t, c, p = Lexer:peekToken(true)
		self:fAsset(t == Token.String or t == Token.Identifier, "expect lib type string or variable")
		local out = { stype = "import", lib = { etype = (t == Token.String and 'const' or 'var'), value = c, pos = p }, vlist }
		if not (Token.SepLcurly == Lexer:peekToken()) then
			self:fAsset(#vlist == 1, "import too much var", p)
			return out
		end
		Lexer:nextTokenKind(Token.SepLcurly)
		local plist = {  }
		while Token.Identifier == Lexer:peekToken() do
			plist[#plist + 1] = self:etExpr({  }, "expect sub lib name after from")
			if Token.SepComma == Lexer:peekToken() then
				Lexer:nextTokenKind(Token.SepComma)
				self:fAsset(#vlist > #plist, "from too much sub lib")
			else 
				self:fAsset(#vlist == #plist, "from too few sub lib")
				break
			end
		end
		if #plist > 0 then
			self:fAsset(#vlist == #plist, "import too much/few sub lib")
		end
		out[#out + 1] = plist
		Lexer:nextTokenKind(Token.SepRcurly)
		return out
	end
	function __ct:stFnDef(only_name)
		Lexer:savePos()
		local attr = nil
		local t, c, p = Lexer:peekToken()
		if t == Token.KwLocal or t == Token.KwExport then
			attr = t == Token.KwExport and t or nil
			Lexer:nextTokenKind(t)
		end
		if not (Token.KwFn == Lexer:peekToken()) then
			Lexer:restorePos()
			return 
		end
		Lexer:clearPos()
		Lexer:nextTokenKind(Token.KwFn)
		local name = self:etFnName(only_name)
		Lexer:nextTokenKind(Token.SepLparen)
		local args = self:etNameList()
		Lexer:nextTokenKind(Token.SepRparen)
		Lexer:nextTokenKind(Token.SepLcurly)
		self:fnBodyStart()
		local body = self:fParseBlock()
		Lexer:nextTokenKind(Token.SepRcurly)
		return { stype = "fn", attr = attr, name = name, args = args, body = body, df = self:fnBodyEnd() }
	end
	function __ct:stLabel()
		if not (Token.SepLabel == Lexer:peekToken()) then
			return 
		end
		Lexer:nextTokenKind(Token.SepLabel)
		local t, c, p = Lexer:nextTokenKind(Token.Identifier)
		Lexer:nextTokenKind(Token.SepLabel)
		return { stype = '::', { etype = "const", value = c, pos = p } }
	end
	function __ct:stLoopEnd()
		local t, c, p = Lexer:peekToken()
		if not (t == Token.KwBreak or t == Token.KwContinue) then
			return 
		end
		local lt = self:isInLoop()
		self:fAsset(lt, t .. " not in loop")
		self:termInGuard()
		Lexer:nextTokenKind(t)
		if t == Token.KwBreak then
			return { stype = 'break' }
		else 
			lt.co = true
			return { stype = 'goto', { etype = "const", value = "__c" .. tostring(self._lo_count), pos = p } }
		end
	end
	function __ct:stBlockEnd()
		local t, c, p = Lexer:peekToken()
		if not (t == Token.KwReturn or t == Token.KwGoto) then
			return 
		end
		self:termInGuard()
		if t == Token.KwReturn then
			Lexer:nextTokenKind(t)
			local ft = self:isInFn()
			local list = self:etExprList(false, ft and ft.df and { etype = 'const', value = '__dr()', pos = p } or nil)
			if self._df_in then
				self:fAsset(list == nil, "defer block can not return value", p)
			end
			return { stype = 'return', unp(list) }
		else 
			Lexer:nextTokenKind(t)
			t, c, p = Lexer:nextTokenKind(Token.Identifier)
			return { stype = 'goto', { etype = "const", value = c, pos = p } }
		end
	end
	function __ct:stClassDef()
		Lexer:savePos()
		local attr = nil
		local t, c, p = Lexer:peekToken()
		if t == Token.KwLocal or t == Token.KwExport then
			Lexer:nextTokenKind(t)
			attr = (t == Token.KwExport) and t or nil
		end
		local st, sc, sp = Lexer:peekToken()
		if not (st == Token.KwClass or st == Token.KwStruct or st == Token.KwExtension) then
			Lexer:restorePos()
			return 
		end
		Lexer:clearPos()
		Lexer:nextTokenKind(st)
		t, c, p = Lexer:nextTokenKind(Token.Identifier)
		local out = { stype = st, attr = attr, name = { etype = 'var', value = c, pos = p } }
		local scope = self:clBodyStart()
		scope.cname = c
		if Token.SepColon == Lexer:peekToken() then
			self:fAsset(st ~= Token.KwStruct, "struct can not inherit from super", true)
			Lexer:nextTokenKind(Token.SepColon)
			t, c, p = Lexer:nextTokenKind(Token.Identifier)
			out.super = { etype = 'var', value = c, pos = p }
			scope.sname = c
		end
		Lexer:nextTokenKind(Token.SepLcurly)
		while true do
			t, c, p = Lexer:peekToken()
			local __s = t
			if __s == Token.KwStatic then
				Lexer:nextTokenKind(t)
				self:fAsset(Token.KwFn == Lexer:peekToken(), "expect function definition after " .. t)
				local expr = self:stFnDef(true)
				expr.attr = t
				out[#out + 1] = expr
			elseif __s == Token.KwFn then
				out[#out + 1] = self:stFnDef(true)
			elseif __s == Token.Identifier then
				Lexer:nextTokenKind(t)
				Lexer:nextTokenKind(Token.OpAssign)
				self._sub_mode = 'class'
				out[#out + 1] = { stype = '=', { etype = 'const', value = c, pos = p }, self:etExpr({  }, "expect expr in variable definition") }
				self._sub_mode = false
			elseif __s == Token.SepRcurly then
				break
			else
				self:fAsset(false, "invalid token " .. t .. " in " .. st .. " definition")
			end
		end
		self:clBodyEnd()
		Lexer:nextTokenKind(Token.SepRcurly)
		return out
	end
	function __ct:etExpr(out, force_errmsg)
		out.etype = 'exp'
		repeat
			local t, c, p = Lexer:peekToken()
			local __s = t
			if __s == Token.KwNil or __s == Token.KwFalse or __s == Token.KwTrue or __s == Token.Vararg or __s == Token.Number or __s == Token.String then
				Lexer:nextTokenKind(t)
				out[#out + 1] = { etype = "const", value = c, pos = p }
			elseif __s == Token.StringExprD or __s == Token.StringExprS then
				Lexer:nextTokenKind(t)
				while true do
					if c:len() > 0 then
						out[#out + 1] = { etype = "const", value = c, pos = p }
						out[#out + 1] = { etype = "binop", value = '..', pos = p }
					end
					out[#out + 1] = { etype = "const", value = "tostring", pos = p }
					self:etPrefixExpr(out)
					t, c, p = Lexer:shortString(t == Token.StringExprD and '"' or "'")
					if t == Token.String then
						if c:len() > 0 then
							out[#out + 1] = { etype = "binop", value = '..', pos = p }
							out[#out + 1] = { etype = "const", value = c, pos = p }
						end
						break
					else 
						out[#out + 1] = { etype = "binop", value = '..', pos = p }
					end
				end
			elseif __s == Token.SepLcurly then
				out[#out + 1] = self:etFnAnonymous() or self:etTableConstructor()
			elseif __s == Token.KwFn then
				out[#out + 1] = self:etFnNoName()
			elseif __s == Token.OpNot or __s == Token.OpNen or __s == Token.OpWav then
				Lexer:nextTokenKind(t)
				local i = #out
				if t == Token.OpWav and i > 0 and (out[i].etype == 'const' or out[i].etype == 'var') then
					out[i + 1] = { etype = "binop", value = c, pos = p }
				else 
					out[i + 1] = { etype = "unop", value = c, pos = p }
				end
				self:etExpr(out, "expect exp after " .. t)
			else
				if t == Token.OpMinus and (#out <= 0 or out[#out].etype == 'binop') then
					Lexer:nextTokenKind(t)
					out[#out + 1] = { etype = "unop", value = c, pos = p }
					self:etExpr(out, "expect exp after " .. t)
				elseif isBinOp(t) then
					self:fAsset(#out > 0, "invalid expr begin with " .. t)
					Lexer:nextTokenKind(t)
					out[#out + 1] = { etype = "binop", value = c, pos = p }
					out.rlop = out.rlop or RelationalOp[t] or LogicalOp[t] or nil
					self:etExpr(out, "expect exp after " .. t)
				else 
					local ncount = #out
					self:etPrefixExpr(out)
					self:etPrefixExprFinish(out)
					if #out <= ncount then
						break
					end
				end
			end
		until not isBinOp(Lexer:peekToken())
		if #out > 0 then
			return #out == 1 and out[1] or out
		elseif force_errmsg then
			self:fAsset(false, force_errmsg)
		end
	end
	function __ct:etPrefixExpr(out)
		local o_out = #out
		local t, c, p = Lexer:peekToken()
		local __s = t
		if __s == Token.Identifier then
			Lexer:nextTokenKind(t)
			if #out == o_out and (c == 'Self' or c == 'Super') then
				local cls = self:isInCls()
				if cls then
					if c == 'Self' then
						out[#out + 1] = { etype = "const", value = cls.cname, pos = p }
					else 
						if cls.sname then
							out[#out + 1] = { etype = "const", value = cls.sname, pos = p }
						else 
							out[#out + 1] = { etype = "const", value = cls.cname, pos = p }
							out[#out + 1] = { etype = '.', { etype = 'const', value = '__st', pos = p } }
						end
					end
					return 
				end
			end
			local etype = (#out == 0 or out[#out].etype == 'binop') and 'var' or 'const'
			out[#out + 1] = { etype = etype, value = c, pos = p }
		elseif __s == Token.SepLparen then
			Lexer:nextTokenKind(t)
			local expr = self:etExpr({  }, "expect exp after " .. t)
			Lexer:nextTokenKind(Token.SepRparen)
			out[#out + 1] = { etype = '(', expr }
		end
	end
	function __ct:etPrefixExprFinish(out)
		while true do
			local t, c, p = Lexer:peekToken()
			local __s = t
			if __s == Token.SepLbreak then
				self:fAsset(#out > 0, "expect prefix expr before " .. t)
				Lexer:nextTokenKind(t)
				local expr = self:etExpr({  }, "expect exp after " .. t)
				Lexer:nextTokenKind(Token.SepRbreak)
				out[#out + 1] = { etype = '[', expr }
			elseif __s == Token.SepDot then
				self:fAsset(#out > 0, "expect prefix expr before " .. t)
				Lexer:nextTokenKind(t)
				t, c, p = Lexer:peekToken()
				local __s = t
				if __s == Token.Identifier then
					Lexer:nextTokenKind(t)
					out[#out + 1] = { etype = '.', { etype = 'const', value = c, pos = p } }
				elseif __s == Token.String then
					Lexer:nextTokenKind(t)
					out[#out + 1] = { etype = '(', { etype = 'const', value = c, pos = p } }
				elseif __s == Token.SepLcurly then
					local expr = self:etTableConstructor()
					out[#out + 1] = { etype = '(', expr }
				else
					self:fAsset(false, 'expect identifier or [string | table] after ' .. t)
				end
			elseif __s == Token.SepColon then
				self:fAsset(#out > 0, "expect prefix expr before " .. t)
				if self._sub_mode == 'case' and CharBlank[Lexer:charAt(p + 1)] then
					return 
				else 
					Lexer:nextTokenKind(t)
					t, c, p = Lexer:nextTokenKind(Token.Identifier)
					out[#out + 1] = { etype = ':', { etype = 'const', value = c, pos = p } }
					out[#out + 1] = { etype = '(', self:etArgs() }
				end
			elseif __s == Token.SepLparen then
				self:fAsset(#out > 0, "expect prefix expr before " .. t)
				out[#out + 1] = { etype = '(', self:etArgs() }
			else
				break
			end
		end
	end
	function __ct:etArgs()
		local t, c, p = Lexer:peekToken()
		self:fAsset(t == Token.SepLparen, "expect args begin with " .. Token.SepLparen)
		Lexer:nextTokenKind(t)
		local list = (Token.SepRparen ~= Lexer:peekToken()) and self:etExprList()
		Lexer:nextTokenKind(Token.SepRparen)
		return unp(list)
	end
	function __ct:etFnNoName()
		self:fAsset(self._sub_mode ~= 'class', "can not define function in class/struct/extension variable definition")
		Lexer:nextTokenKind(Token.KwFn)
		Lexer:nextTokenKind(Token.SepLparen)
		local args = self:etNameList()
		Lexer:nextTokenKind(Token.SepRparen)
		Lexer:nextTokenKind(Token.SepLcurly)
		self:fnBodyStart()
		local body = self:fParseBlock()
		Lexer:nextTokenKind(Token.SepRcurly)
		return { etype = 'fn', args = args, body = body, df = self:fnBodyEnd() }
	end
	function __ct:etFnAnonymous()
		Lexer:savePos()
		Lexer:nextTokenKind(Token.SepLcurly)
		local args = self:etNameList()
		if not (Token.KwIn == Lexer:peekToken()) then
			Lexer:restorePos()
			return 
		end
		self:fAsset(self._sub_mode ~= 'class', "can not define function in class/struct/extension variable definition")
		Lexer:clearPos()
		Lexer:nextTokenKind(Token.KwIn)
		self:fnBodyStart()
		local body = self:fParseBlock()
		Lexer:nextTokenKind(Token.SepRcurly)
		return { etype = 'fn', args = args, body = body, df = self:fnBodyEnd() }
	end
	function __ct:etTableConstructor()
		Lexer:nextTokenKind(Token.SepLcurly)
		local expr = { etype = "{" }
		while Token.SepRcurly ~= Lexer:peekToken() do
			expr[#expr + 1] = self:etField()
			local t, c, p = Lexer:peekToken()
			if t == Token.SepComma or t == Token.SepSemi then
				Lexer:nextTokenKind(t)
			else 
				break
			end
		end
		Lexer:nextTokenKind(Token.SepRcurly)
		return expr
	end
	function __ct:etField()
		local t, c, p = Lexer:peekToken()
		local __s = t
		if __s == Token.SepLbreak then
			Lexer:nextTokenKind(t)
			local expr = { bkey = self:etExpr({  }, "expect exp after " .. t) }
			Lexer:nextTokenKind(Token.SepRbreak)
			Lexer:nextTokenKind(Token.OpAssign)
			expr.value = self:etExpr({  }, "expect exp after " .. Token.OpAssign)
			return expr
		elseif __s == Token.OpAssign then
			Lexer:nextTokenKind(t)
			t, c, p = Lexer:nextTokenKind(Token.Identifier)
			return { nkey = { etype = 'var', value = c, pos = p } }
		elseif __s == Token.Identifier or __s == Token.Number or __s == Token.String then
			Lexer:savePos()
			Lexer:nextTokenKind(t)
			if Token.OpAssign == Lexer:peekToken() then
				Lexer:clearPos()
				Lexer:nextTokenKind(Token.OpAssign)
				local expr = { value = self:etExpr({  }, "expect exp after " .. Token.OpAssign) }
				if t == Token.Identifier then
					expr.vkey = { etype = 'const', value = c, pos = p }
				else 
					expr.bkey = { etype = 'const', value = c, pos = p }
				end
				return expr
			else 
				Lexer:restorePos()
			end
		end
		return { value = self:etExpr({  }, "expect exp in table field") }
	end
	function __ct:etNameList()
		local out = {  }
		while true do
			local t, c, p = Lexer:peekToken()
			local __s = t
			if __s == Token.Identifier then
				Lexer:nextTokenKind(t)
				out[#out + 1] = { etype = "const", value = c, pos = p }
			elseif __s == Token.Vararg then
				Lexer:nextTokenKind(t)
				out[#out + 1] = { etype = "const", value = c, pos = p }
				break
			else
				return out
			end
			if Token.SepComma == Lexer:peekToken() then
				Lexer:nextTokenKind(Token.SepComma)
			else 
				break
			end
		end
		return out
	end
	function __ct:etExprList(force_msg, extra, pos)
		local out = {  }
		while true do
			local expr = self:etExpr({  })
			out[#out + 1] = expr
			if expr and Token.SepComma == Lexer:peekToken() then
				Lexer:nextTokenKind(Token.SepComma)
			else 
				break
			end
		end
		if extra then
			out[#out + 1] = extra
		end
		if #out > 0 then
			return out
		elseif force_msg then
			self:fAsset(false, force_msg, pos)
		end
	end
	function __ct:etVarList()
		Lexer:savePos()
		local out = {  }
		while true do
			local t, c, p = Lexer:peekToken()
			if not (t == Token.Identifier) then
				break
			end
			local expr = { etype = "exp" }
			self:etPrefixExpr(expr)
			self:etPrefixExprFinish(expr)
			local etype = expr[#expr].etype
			if not (etype == 'var' or etype == "[" or etype == ".") then
				break
			end
			out[#out + 1] = #expr == 1 and expr[1] or expr
			if not (Token.SepComma == Lexer:peekToken()) then
				break
			end
			Lexer:nextTokenKind(Token.SepComma)
		end
		if #out > 0 then
			Lexer:clearPos()
			return out
		else 
			Lexer:restorePos()
		end
	end
	function __ct:etFnName(only_name)
		local t, c, p = Lexer:nextTokenKind(Token.Identifier)
		local out = { etype = "exp", { etype = "var", value = c, pos = p } }
		if not only_name then
			while Token.SepDot == Lexer:peekToken() do
				Lexer:nextTokenKind(Token.SepDot)
				t, c, p = Lexer:nextTokenKind(Token.Identifier)
				out[#out + 1] = { etype = '.', { etype = 'const', value = c, pos = p } }
			end
			if Token.SepColon == Lexer:peekToken() then
				Lexer:nextTokenKind(Token.SepColon)
				t, c, p = Lexer:nextTokenKind(Token.Identifier)
				out[#out + 1] = { etype = ':', { etype = 'const', value = c, pos = p } }
			end
		end
		if #out == 1 then
			return out[1]
		else 
			out[1].etype = 'var'
			return out
		end
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<struct Parser: %p>", t) end,
		__index = function(t, k)
			local v = rawget(__ct, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,
	}
	Parser = setmetatable({}, {
		__tostring = function() return "<struct Parser>" end,
		__index = function(_, k) return rawget(__ct, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(__ct, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __imt)
			if type(rawget(__ct,'init')) == 'function' and __ct.init(ins,...) == false then return nil end
			return ins
		end,
	})
end
local function parse(content)
	Parser:fReset(content)
	local ret, ast = pcall(Parser.fParseBlock, Parser)
	if ret then
		return true, { content = content, ast = ast }
	else 
		local err_msg, pos = Parser:getLastError()
		return false, { content = content, pos = pos, err_msg = (err_msg or ast) }
	end
end
return { parse = parse }
