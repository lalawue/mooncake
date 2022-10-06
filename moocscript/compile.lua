local Utils = require("moocscript.utils")
local assert = assert
local type = type
local srep = string.rep
local ipairs = ipairs
local mathmax = math.max
local Out = { __tn = 'Out', __tk = 'class', __st = nil }
do
	local __st = nil
	local __ct = Out
	__ct.__ct = __ct
	__ct.isKindOf = function(c, a) return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false end
	-- declare class var and methods
	__ct._indent = 0
	__ct._changeLine = false
	__ct._output = {  }
	__ct._inline = 0
	function __ct:reset()
		self._indent = 0
		self._changeLine = false
		self._output = {  }
		self._inline = 0
	end
	function __ct:incIndent()
		self._indent = self._indent + 1
	end
	function __ct:decIndent()
		self._indent = self._indent - 1
	end
	function __ct:changeLine()
		self._changeLine = true
	end
	function __ct:pushInline()
		self._inline = self._inline + 1
	end
	function __ct:popInline()
		self._inline = self._inline - 1
	end
	function __ct:append(str, same_line)
		assert(type(str) == "string", "Invalid input")
		local t = self._output
		same_line = same_line or (self._inline > 0)
		if same_line and not self._changeLine then
			local i = mathmax(#t, 1)
			t[i] = (t[i] or "") .. str
		else 
			self._changeLine = false
			t[#t + 1] = (self._indent > 0 and srep("\t", self._indent) or "") .. str
		end
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<class Out: %p>", t) end,
		__index = function(t, k)
			local v = __ct[k]
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
	}
	setmetatable(__ct, {
		__tostring = function() return "<class Out>" end,
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
local _global_names = Utils.set({ "_G", "_VERSION", "_ENV", "assert", "collectgarbage", "coroutine", "debug", "dofile", "error", "getfenv", "getmetatable", "io", "ipairs", "jit", "load", "loadfile", "loadstring", "math", "module", "next", "os", "package", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require", "select", "setfenv", "setmetatable", "string", "table", "tonumber", "tostring", "type", "unpack", "xpcall", "nil", "true", "false" })
local _scope_global = { otype = "gl", vars = _global_names }
local _scope_proj = { otype = "pj", vars = {  } }
local Ctx = { __tn = 'Ctx', __tk = 'class', __st = nil }
do
	local __st = nil
	local __ct = Ctx
	__ct.__ct = __ct
	__ct.isKindOf = function(c, a) return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false end
	-- declare class var and methods
	__ct.config = false
	__ct.ast = false
	__ct.content = false
	__ct.scopes = false
	__ct.err_info = false
	__ct.last_pos = 0
	function __ct:reset(config, ast, content)
		self.config = config
		self.ast = ast
		self.content = content
		self.scopes = { index = 3, _scope_global, _scope_proj, { otype = "fi", vars = config.fi_scope or {  } } }
		self.err_info = false
		self.last_pos = 0
	end
	function __ct:pushScope(ot, exp)
		local t = self.scopes
		t.index = t.index + 1
		local tn = t[t.index] or {  }
		tn.otype = ot
		tn.vars = {  }
		tn.exp = exp
		t[t.index] = tn
	end
	function __ct:popScope()
		local t = self.scopes
		t.index = t.index - 1
	end
	function __ct:globalInsert(n)
		local t = self.scopes
		t[2].vars[n] = true
	end
	function __ct:localInsert(n)
		local t = self.scopes
		t[t.index].vars[n] = true
	end
	function __ct:checkName(e, only_check)
		if e and e.etype == 'exp' then
			e = e[1]
		end
		if e and e.etype == 'var' then
			local n = e.value
			local t = self.scopes
			for i = t.index, 1, -1 do
				if t[i].vars[n] or t[i].vars["*"] then
					return true
				end
			end
			if not only_check then
				self:errorPos("undefined variable", e.pos - 1)
			end
		end
	end
	function __ct:errorPos(err_msg, pos)
		if self.err_info then
			return 
		end
		pos = pos or mathmax(0, self.last_pos - 1)
		self.err_info = { err_msg = err_msg, pos = pos }
		error('')
	end
	function __ct:updatePos(pos)
		if type(pos) == "number" and not self.err_info then
			self.last_pos = pos
		end
	end
	-- declare end
	local __imt = {
		__tostring = function(t) return string.format("<class Ctx: %p>", t) end,
		__index = function(t, k)
			local v = __ct[k]
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
	}
	setmetatable(__ct, {
		__tostring = function() return "<class Ctx>" end,
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
local _cls_metafns = Utils.set({ "__tostring", "__index", "__newindex", "__call", "__add", "__band", "__bnot", "__bor", "__bxor", "__close", "__concat", "__div", "__eq", "__idiv", "__le", "__len", "__pairs", "__ipairs", "__lt", "__metatable", "__mod", "__mode", "__mul", "__name", "__pow", "__shl", "__shr", "__sub", "__unm" })
local _map_binop = { ['!='] = '~=' }
local M = { __tn = 'M', __tk = 'class', __st = nil }
do
	local __st = nil
	local __ct = M
	__ct.__ct = __ct
	__ct.isKindOf = function(c, a) return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false end
	-- declare class var and methods
	__ct.ctx = false
	__ct.out = false
	__ct.exfn = {  }
	__ct.stfn = {  }
	function __ct:reset(ctx, out)
		self.ctx = ctx
		self.out = out
	end
	function __ct:trExpr(t)
		assert(type(t) == "table", "Invalid expr type")
		local ctx = self.ctx
		local out = self.out
		local etype = t.etype
		if etype == "exp" then
			for _, v in ipairs(t) do
				self:trExpr(v)
			end
			return 
		end
		local func = self.exfn[etype]
		if func then
			func(self, t)
			return 
		end
		local __s = etype
		if __s == "var" then
			func = function(_, t)
				ctx:checkName(t)
				out:append(t.value, true)
			end
		elseif __s == "const" then
			func = function(_, t)
				out:append(t.value, true)
			end
		elseif __s == "{" then
			func = self.trEtTblDef
		elseif __s == "fn" then
			func = self.trEtFnOnly
		elseif __s == "(" then
			func = self.trEtPara
		elseif __s == "." then
			func = function(_, t)
				out:append("." .. t[1].value, true)
			end
		elseif __s == ":" then
			func = self.trEtColon
		elseif __s == "[" then
			func = self.trEtSquare
		elseif __s == 'unop' then
			func = function(_, t)
				local v = t.value == 'not' and 'not ' or t.value
				out:append(v, true)
			end
		elseif __s == 'binop' then
			func = function(_, t)
				out:append(' ' .. (_map_binop[t.value] or t.value) .. ' ', true)
			end
		else
			ctx:errorPos("Invalid expr etype near " .. (etype or "unknown"))
			return 
		end
		self.exfn[etype] = func
		func(self, t)
	end
	function __ct:trStatement(ast)
		local ctx = self.ctx
		local out = self.out
		local stfn = self.stfn
		local index = 0
		while true do
			index = index + 1
			if index > #ast then
				break
			end
			local t = ast[index]
			local stype = t.stype
			local func = stfn[stype]
			if t.pos then
				ctx:updatePos(t.pos)
			end
			if func then
				func(self, t)
			else 
				local __s = stype
				if __s == "import" then
					func = self.trStImport
				elseif __s == "fn" then
					func = self.trStFnDef
				elseif __s == "(" then
					func = self.trStCall
				elseif __s == "class" then
					func = self.trStClass
				elseif __s == "struct" then
					func = self.trStStruct
				elseif __s == "extension" then
					func = self.trStExtension
				elseif __s == "ex" then
					func = self.trStExport
				elseif __s == "=" then
					func = self.trAssign
				elseif __s == "return" then
					func = self.trStReturn
				elseif __s == "defer" then
					func = self.trStDefer
				elseif __s == "if" then
					func = self.trStIfElse
				elseif __s == "switch" then
					func = self.trStSwitch
				elseif __s == "guard" then
					func = self.trStGuard
				elseif __s == "break" then
					func = self.trStBreak
				elseif __s == "goto" or __s == "::" then
					func = self.trStGotoLabel
				elseif __s == "for" then
					func = self.trStFor
				elseif __s == "while" then
					func = self.trStWhile
				elseif __s == "repeat" then
					func = self.trStRepeat
				elseif __s == "do" then
					func = self.trStDo
				elseif __s == "#!" then
					func = function(self, t)
						if self.ctx.config.shebang and t.value then
							self.out:append(t.value)
						end
					end
				elseif __s == ';' then
					func = function(self, _)
						t = out._output
						local i = mathmax(#t, 1)
						t[i] = (t[i] or "") .. ';'
					end
				elseif __s == 'raw' then
					func = function(self, t)
						self.out:append(t.value)
					end
				else
					ctx:errorPos("Invalid stype near " .. (stype or "uknown stype"))
					return 
				end
				stfn[stype] = func
				func(self, t)
			end
			out:changeLine()
		end
	end
	function __ct:trEtName(t)
		local ctx = self.ctx
		local n = ''
		if t.etype == 'exp' and #t > 0 then
			local name = ''
			for i, v in ipairs(t) do
				if i == 1 then
					n = v.value
					name = n
				else 
					name = name .. v.etype .. v[1].value
				end
			end
			return name, n
		elseif t.etype then
			return t.value, t.value
		end
	end
	function __ct:trEtPara(t)
		assert(t.etype == "(", "Invalid op (")
		local out = self.out
		out:pushInline()
		out:append("(", true)
		for i, e in ipairs(t) do
			if i > 1 then
				out:append(", ", true)
			end
			self:trExpr(e)
		end
		out:append(")", true)
		out:popInline()
	end
	function __ct:trEtColon(t)
		assert(t.etype == ":", "Invalid op =")
		self.out:append(":", true)
		for i, e in ipairs(t) do
			self:trExpr(e)
		end
	end
	function __ct:trEtSquare(t)
		assert(t.etype == "[", "Invalid op [")
		local out = self.out
		out:pushInline()
		out:append("[", true)
		for _, e in ipairs(t) do
			self:trExpr(e)
		end
		out:append("]", true)
		out:popInline()
	end
	function __ct:trEtTblDef(t)
		assert(t.etype == "{", "Invalid etype table def")
		local ctx = self.ctx
		local out = self.out
		out:append("{ ")
		for i, e in ipairs(t) do
			if e.nkey then
				local value = e.nkey.value
				out:append(value, true)
				out:append(" = ", true)
				out:append(value, true)
			else 
				if e.vkey then
					out:append(e.vkey.value, true)
					out:append(" = ", true)
				elseif e.bkey then
					out:append("[", true)
					self:trExpr(e.bkey)
					out:append("] = ", true)
				end
				self:trExpr(e.value)
			end
			if i < #t then
				out:append(", ")
			end
		end
		out:append(" }")
	end
	function __ct:trEtFnOnly(t)
		assert(t.etype == "fn", "Invalid etype fn def only")
		local ctx = self.ctx
		local out = self.out
		ctx:pushScope("fn", t)
		out:append("function(" .. Utils.seqReduce(t.args, "", function(init, i, v)
			ctx:localInsert(v.value)
			return init .. (i > 1 and ", " or "") .. v.value
		end) .. ")")
		out:incIndent()
		if #t.body > 0 then
			if t.df then
				out:changeLine()
				out:append(t.df)
			end
			out:changeLine()
			self:trStatement(t.body)
		end
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __ct:trStImport(t)
		assert(t.stype == "import", "Invalid stype import")
		local ctx = self.ctx
		local out = self.out
		if #t <= 0 then
			out:append("require(" .. t.lib.value .. ")")
		elseif #t == 1 then
			local lt = t[1][1]
			if t.lib.etype == 'const' then
				out:append("local " .. lt.value .. " = require(" .. t.lib.value .. ")")
			else 
				ctx:checkName(t.lib)
				out:append("local " .. lt.value .. " = " .. t.lib.value)
			end
			ctx:localInsert(lt.value)
		else 
			local lt = t[1]
			local rt = t[2]
			if #rt <= 0 then
				rt = lt
			end
			out:append(Utils.seqReduce(lt, "local ", function(init, i, v)
				ctx:localInsert(v.value)
				return init .. (i <= 1 and "" or ", ") .. v.value
			end))
			if t.lib.etype == 'const' then
				out:append("do")
				out:incIndent()
				out:append("local __l = require(" .. t.lib.value .. ")")
				out:append(Utils.seqReduce(lt, "", function(init, i, v)
					return init .. (i <= 1 and "" or ", ") .. v.value
				end))
				out:append(" = " .. Utils.seqReduce(rt, "", function(init, i, v)
					return init .. (i <= 1 and "__l." or ", __l.") .. v.value
				end), true)
				out:decIndent()
				out:append("end")
			else 
				ctx:checkName(t.lib)
				local tfirst, tnext = t.lib.value .. ".", ", " .. t.lib.value .. "."
				out:append(" = " .. Utils.seqReduce(rt, "", function(init, i, v)
					return init .. (i <= 1 and tfirst or tnext) .. v.value
				end), true)
			end
		end
	end
	function __ct:trStExport(t)
		assert(t.stype == "ex", "Invalid stype export")
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		if t.attr == "local" then
			out:append("local ")
			for i, v in ipairs(t) do
				if i > 1 then
					out:append(", ")
				end
				self:trExpr(v)
				ctx:localInsert(v.value)
			end
		elseif t.attr == "export" then
			for i, v in ipairs(t) do
				ctx:globalInsert(v.value)
				out:append(v.value)
				if i < #t then
					out:append(", ")
				end
			end
			out:append(' = ')
			for i, v in ipairs(t) do
				out:append(v.value .. ' or nil')
				if i < #t then
					out:append(", ")
				end
			end
		elseif t.attr == "*" then
			ctx:localInsert("*")
		else 
			ctx:errorPos("Invalid export attr near " .. (t.attr or "unknown"))
		end
		out:popInline()
	end
	function __ct:trAssign(t)
		assert(t.stype == '=', "Invalid stype =")
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		if t.sub then
			assert(#t[1] == 1 and #t[1] == #t[2], "Invalid assign sub AST")
			local e = t[1][1]
			self:trExpr(e)
			out:append(' = ')
			self:trExpr(e)
			out:append(' ' .. t.sub .. ' ')
			e = t[2][1]
			local sp, ep = '', ''
			if e.rlop then
				sp, ep = '(', ')'
			end
			out:append(sp)
			self:trExpr(e)
			out:append(ep)
		else 
			local e = t[2]
			for _, v in ipairs(e) do
				ctx:checkName(v)
			end
			e = t[1]
			for i, v in ipairs(e) do
				if t.attr == 'export' then
					ctx:globalInsert(v.value)
				elseif t.attr == 'local' or #v <= 0 and not ctx:checkName(v, true) then
					ctx:localInsert(v.value)
					if i == 1 then
						out:append("local ")
					end
				end
				self:trExpr(v)
				if i < #e then
					out:append(", ")
				end
			end
			out:append(" = ")
			e = t[2]
			for i, v in ipairs(e) do
				self:trExpr(v)
				if i < #e then
					out:append(", ")
				end
			end
		end
		out:popInline()
	end
	function __ct:trStFnDef(t)
		assert(t.stype == "fn", "Invalid stype fn")
		local ctx = self.ctx
		local out = self.out
		local attr = (t.attr == "export" and "" or "local ")
		local args = t.args or {  }
		local fname, pname = self:trEtName(t.name)
		if fname == pname then
			if t.attr == "export" or ctx:checkName(t.name, true) then
				attr = ''
				ctx:globalInsert(fname)
			else 
				ctx:localInsert(fname)
			end
		else 
			ctx:checkName(t.name)
		end
		ctx:pushScope("fn", t)
		local mark = self:hasColonDot(t.name)
		if mark then
			if mark == ':' then
				ctx:localInsert("self")
			end
			attr = ""
		end
		out:append(attr .. "function " .. fname .. "(" .. Utils.seqReduce(args, "", function(init, i, v)
			ctx:localInsert(v.value)
			return init .. (i > 1 and ", " or "") .. v.value
		end) .. ")")
		out:incIndent()
		if #t.body > 0 then
			if t.df then
				out:append(t.df)
			end
			out:changeLine()
			self:trStatement(t.body)
		end
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __ct:trStCall(t)
		assert(t.stype == "(", "Invalid stype fn call")
		local ctx = self.ctx
		local out = self.out
		local n = 0
		out:pushInline()
		for i, e in ipairs(t) do
			if i > n then
				self:trExpr(e)
			end
		end
		out:popInline()
	end
	function __ct:trStIfElse(t)
		assert(t.stype == "if", "Invalid stype if")
		local ctx = self.ctx
		local out = self.out
		for i, e in ipairs(t) do
			out:append(e.sub .. " ")
			if e.sub ~= 'else' then
				out:pushInline()
				self:trExpr(e.cond)
				out:popInline()
				out:append(" then", true)
			end
			ctx:pushScope("if", e)
			out:changeLine()
			out:incIndent()
			self:trStatement(e.body)
			out:decIndent()
			ctx:popScope()
		end
		out:append('end')
	end
	function __ct:trStSwitch(t)
		assert(t.stype == "switch", "Invalid stype switch")
		local ctx = self.ctx
		local out = self.out
		out:append("local __s = ")
		out:pushInline()
		self:trExpr(t.cond)
		out:popInline()
		out:changeLine()
		for i = 1, #t do
			local c = t[i]
			out:pushInline()
			if c.cond then
				if i == 1 then
					out:append("if ")
				else 
					out:append("elseif ")
				end
				local sp, ep, count = nil, nil, #c.cond
				for j, e in ipairs(c.cond) do
					out:append("__s ==")
					if e.rlop then
						sp, ep = ' (', (j == count and ')' or ') or ')
					else 
						sp, ep = ' ', (j == count and '' or ' or ')
					end
					out:append(sp)
					self:trExpr(e)
					out:append(ep)
				end
				out:append(" then")
			else 
				out:append("else")
			end
			out:changeLine()
			ctx:pushScope("if")
			out:popInline()
			out:incIndent()
			self:trStatement(c.body)
			out:decIndent()
			ctx:popScope()
		end
		out:append("end")
		out:changeLine()
	end
	function __ct:trStGuard(t)
		assert(t.stype == "guard", "Invalid stype guard")
		local ctx = self.ctx
		local out = self.out
		out:append("if not (")
		out:pushInline()
		self:trExpr(t.cond)
		out:append(") then", true)
		out:popInline()
		out:changeLine()
		out:incIndent()
		ctx:pushScope("gu", t)
		self:trStatement(t.body)
		ctx:popScope()
		out:decIndent()
		out:append("end")
	end
	function __ct:trStFor(t)
		assert(t.stype == "for" and (t.sub == '=' or t.sub == 'in'), "Invalid stype for")
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		out:append("for ")
		ctx:pushScope("lo", t)
		for i, e in ipairs(t.name) do
			ctx:localInsert(e.value)
			if i > 1 then
				out:append(", ")
			end
			self:trExpr(e)
		end
		out:append(' ' .. t.sub .. ' ')
		for i, e in ipairs(t.step) do
			if i > 1 then
				out:append(", ")
			end
			self:trExpr(e)
		end
		out:append(" do")
		out:popInline()
		out:changeLine()
		out:incIndent()
		self:trStatement(t.body)
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __ct:trStWhile(t)
		assert(t.stype == "while", "Invalid stype while")
		local ctx = self.ctx
		local out = self.out
		out:append("while ")
		out:pushInline()
		self:trExpr(t.cond)
		out:append(" do")
		out:popInline()
		out:changeLine()
		out:incIndent()
		ctx:pushScope("lo", t)
		self:trStatement(t.body)
		ctx:popScope()
		out:decIndent()
		out:append("end")
	end
	function __ct:trStRepeat(t)
		assert(t.stype == "repeat", "Invalid repeat op")
		local ctx = self.ctx
		local out = self.out
		out:append("repeat")
		out:changeLine()
		out:incIndent()
		ctx:pushScope("lo", t)
		self:trStatement(t.body)
		out:decIndent()
		out:append("until ")
		out:pushInline()
		self:trExpr(t.cond)
		out:popInline()
		ctx:popScope()
	end
	function __ct:trStBreak(t)
		assert(t.stype == "break", "Invalid stype break")
		local ctx = self.ctx
		local out = self.out
		out:append("break")
	end
	function __ct:trStGotoLabel(t)
		assert(t.stype == "goto" or t.stype == "::", "Invalid stype goto")
		local ctx = self.ctx
		local out = self.out
		if t.stype == "goto" then
			out:append("goto " .. t[1].value)
		else 
			out:append("::" .. t[1].value .. "::")
		end
	end
	function __ct:trStReturn(t)
		assert(t.stype == "return", "Invalid stpye return")
		local ctx = self.ctx
		local out = self.out
		out:append("return ")
		out:pushInline()
		for i, e in ipairs(t) do
			if i > 1 then
				out:append(", ")
			end
			self:trExpr(e)
		end
		out:popInline()
	end
	function __ct:trStDefer(t)
		assert(t.stype == "defer", "Invalid stype defer")
		local ctx = self.ctx
		local out = self.out
		out:append("__df[#__df+1] = function()")
		out:changeLine()
		out:incIndent()
		ctx:pushScope("df")
		self:trStatement(t.body)
		ctx:popScope()
		out:decIndent()
		out:append("end")
	end
	function __ct:trStDo(t)
		assert(t.stype == "do", "Invalid stype do end")
		local ctx = self.ctx
		local out = self.out
		out:append("do")
		out:changeLine()
		out:incIndent()
		ctx:pushScope("do")
		self:trStatement(t.body)
		ctx:popScope()
		out:decIndent()
		out:append("end")
	end
	function __ct:trStClass(t)
		assert(t.stype == "class", "Invalid stype class")
		local ctx = self.ctx
		local out = self.out
		local attr = (t.attr == "export") and "" or "local "
		local clsname = t.name.value
		local supertype = t.super and t.super.value
		if t.attr == "export" or ctx:checkName(t.name, true) then
			attr = ''
			ctx:globalInsert(clsname)
		else 
			ctx:localInsert(clsname)
		end
		if supertype then
			ctx:checkName(t.super)
		end
		ctx:updatePos(t.name.pos)
		out:append(attr .. clsname .. " = { __tn = '" .. clsname .. "', __tk = 'class', __st = " .. (supertype or "nil") .. " }")
		out:append("do")
		out:changeLine()
		out:incIndent()
		out:append("local __st = " .. (supertype or "nil"))
		out:append("local __ct = " .. clsname)
		out:append("__ct.__ct = __ct")
		if supertype then
			out:append("assert(type(__st) == 'table' and __st.__ct == __st and __st.__tk == 'class', 'invalid super type')")
		else 
			out:append("__ct.isKindOf = function(c, a) return a and c and ((c.__ct == a) or (c.__st and c.__st:isKindOf(a))) or false end")
		end
		ctx:pushScope("cl")
		local cls_fns, ins_fns = {  }, {  }
		local fn_deinit = self:hlVarAndFns(t, "class", "__ct", ctx, out, cls_fns, ins_fns)
		out:append("local __imt = {")
		out:incIndent()
		if not ins_fns.has_tostring then
			out:append('__tostring = function(t) return string.format("<class ' .. clsname .. ': %p>", t) end,')
		end
		out:append("__index = function(t, k)")
		out:incIndent()
		if ins_fns.has_index then
			out:append("local ok, v = __ct.__ins_index(t, k)")
			out:append("if ok then return v else v = __ct[k] end")
		else 
			out:append("local v = __ct[k]")
		end
		out:append("if v ~= nil then rawset(t, k, v) end")
		out:append("return v")
		out:decIndent()
		out:append("end,")
		if fn_deinit then
			out:append("__gc = function(t) t:deinit() end,")
		end
		for _, e in ipairs(ins_fns) do
			out:append(e.name.value .. " = function(")
			self:hlFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("}")
		out:append("setmetatable(__ct, {")
		out:incIndent()
		if not cls_fns.has_tostring then
			out:append('__tostring = function() return "<class ' .. clsname .. '>" end,')
		end
		out:append('__index = function(t, k)')
		out:incIndent()
		if cls_fns.has_index then
			out:append('local ok, v = t.__cls_index(t, k)')
			out:append('if ok then return v else v = __st and __st[k] end')
		else 
			out:append('local v = __st and __st[k]')
		end
		out:append('if v ~= nil then rawset(t, k, v) end')
		out:append('return v')
		out:decIndent()
		out:append('end,')
		out:append("__call = function(_, ...)")
		out:incIndent()
		out:append("local ins = setmetatable({}, __imt)")
		out:append("if type(rawget(__ct,'init')) == 'function' and __ct.init(ins, ...) == false then return nil end")
		if fn_deinit then
			out:append('if _VERSION == "Lua 5.1" then')
			out:incIndent()
			out:append("rawset(ins, '__gc_proxy', newproxy(true))")
			out:append("getmetatable(ins.__gc_proxy).__gc = function() ins:deinit() end")
			out:decIndent()
			out:append("end")
		end
		out:append("return ins")
		out:decIndent()
		out:append("end,")
		for _, e in ipairs(cls_fns) do
			out:append(e.name.value .. " = function(")
			self:hlFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("})")
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __ct:trStStruct(t)
		assert(t.stype == "struct", "Invalid stype struct")
		local ctx = self.ctx
		local out = self.out
		local attr = (t.attr == "export") and "" or "local "
		local strname = t.name.value
		if t.attr == "export" or ctx:checkName(t.name, true) then
			attr = ''
			ctx:globalInsert(strname)
		else 
			ctx:localInsert(strname)
		end
		ctx:updatePos(t.name.pos)
		out:append(attr .. strname .. " = { __tn = '" .. strname .. "', __tk = 'struct' }")
		out:append("do")
		out:changeLine()
		out:incIndent()
		out:append("local __ct = " .. strname)
		out:append("__ct.__ct = __ct")
		ctx:pushScope("cl")
		local cls_fns, ins_fns = {  }, {  }
		local fn_deinit = self:hlVarAndFns(t, "struct", "__ct", ctx, out, cls_fns, ins_fns)
		out:append("local __imt = {")
		out:incIndent()
		if not ins_fns.has_tostring then
			out:append('__tostring = function(t) return string.format("<struct ' .. strname .. ': %p>", t) end,')
		end
		out:append("__index = function(t, k)")
		out:incIndent()
		out:append("local v = rawget(__ct, k)")
		out:append("if v ~= nil then rawset(t, k, v) end")
		out:append("return v")
		out:decIndent()
		out:append("end,")
		out:append("__newindex = function(t, k, v) if rawget(__ct, k) ~= nil then rawset(t, k, v) end end,")
		if fn_deinit then
			out:append("__gc = function(t) t:deinit() end,")
		end
		for _, e in ipairs(ins_fns) do
			out:append(e.name.value .. " = function(")
			self:hlFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("}")
		out:append(strname .. " = setmetatable({}, {")
		out:incIndent()
		if not cls_fns.has_tostring then
			out:append('__tostring = function() return "<struct ' .. strname .. '>" end,')
		end
		out:append('__index = function(t, k) local v = rawget(__ct, k); if v ~= nil then rawset(t, k, v); end return v end,')
		out:append('__newindex = function(t, k, v) if v ~= nil and rawget(__ct, k) ~= nil then rawset(t, k, v) end end,')
		out:append("__call = function(_, ...)")
		out:incIndent()
		out:append("local ins = setmetatable({}, __imt)")
		out:append("if type(rawget(__ct,'init')) == 'function' and __ct.init(ins, ...) == false then return nil end")
		if fn_deinit then
			out:append('if _VERSION == "Lua 5.1" then')
			out:incIndent()
			out:append("rawset(ins, '__gc_proxy', newproxy(true))")
			out:append("getmetatable(ins.__gc_proxy).__gc = function() ins:deinit() end")
			out:decIndent()
			out:append("end")
		end
		out:append("return ins")
		out:decIndent()
		out:append("end,")
		for _, e in ipairs(cls_fns) do
			out:append(e.name.value .. " = function(")
			self:hlFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("})")
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __ct:trStExtension(t)
		assert(t.stype == "extension", "Invalid stype extension")
		local ctx = self.ctx
		local out = self.out
		local clsname = t.name.value
		local extype = t.super and t.super.value
		ctx:checkName(t.name)
		if extype then
			ctx:checkName(t.super)
		end
		ctx:updatePos(t.name.pos)
		out:append("do")
		out:changeLine()
		out:incIndent()
		out:append("local __et = " .. (extype or "nil"))
		out:append("local __ct = " .. clsname)
		out:append("assert(type(__ct) == 'table' and type(__ct.__ct) == 'table' and (__ct.__tk == 'class' or __ct.__tk == 'struct'), 'invalid extended type')")
		out:append("__ct = __ct.__ct")
		if extype then
			out:append("assert(type(__et) == 'table' and type(__et.__ct) == 'table' and (__et.__tk == 'class' or __et.__tk == 'struct'), 'invalid super type')")
			out:append('for k, v in pairs(__et.__ct) do')
			out:incIndent()
			out:append('if __ct[k] == nil and (k:len() < 2 or (k:sub(1, 2) ~= "__" and k ~= "isKindOf" and k ~= "init" and k ~= "deinit")) then')
			out:incIndent()
			out:append('__ct[k] = v')
			out:decIndent()
			out:append("end")
			out:decIndent()
			out:append("end")
		end
		ctx:pushScope("cl")
		self:hlVarAndFns(t, "extension", "__ct", ctx, out, {  }, {  })
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __ct:hlVarAndFns(t, cname, sname, ctx, out, cls_fns, ins_fns)
		out:append("-- declare " .. cname .. " var and methods")
		out:changeLine()
		local fn_deinit = false
		for _, s in ipairs(t) do
			local stype = s.stype
			if stype == "=" then
				out:append(sname .. ".")
				out:pushInline()
				self:trExpr(s[1])
				out:append(' = ')
				self:trExpr(s[2])
				out:popInline()
				out:changeLine()
			elseif stype == "fn" then
				local fn_name = s.name.value
				if cname == "extension" and (fn_name == "init" or fn_name == "deinit") then
					ctx:errorPos("extension not support init/deinit", s.name.pos)
				elseif fn_name == "deinit" then
					fn_deinit = true
				end
				local fn_ins = s.attr ~= "static"
				if _cls_metafns[fn_name] then
					if cname == "extension" then
						ctx:errorPos("extension not support metamethod", s.name.pos)
					elseif fn_ins then
						ins_fns[#ins_fns + 1] = s
						if fn_name == "__tostring" then
							ins_fns.has_tostring = true
						elseif fn_name == "__index" or fn_name == "__newindex" then
							if cname == "struct" then
								ctx:errorPos("struct not support " .. fn_name, s.name.pos)
							elseif fn_name == "__index" then
								ins_fns[#ins_fns] = nil
								ins_fns.has_index = true
								s.name.value = "__ins_index"
								out:append("function " .. sname .. "." .. s.name.value .. "(")
								self:hlFnArgsBody(s, false)
							end
						end
					else 
						cls_fns[#cls_fns + 1] = s
						if fn_name == "__tostring" then
							cls_fns.has_tostring = true
						elseif fn_name == "__index" or fn_name == "__newindex" then
							if cname == "struct" then
								ctx:errorPos("struct not support " .. fn_name, s.name.pos)
							elseif fn_name == "__index" then
								cls_fns[#cls_fns] = nil
								cls_fns.has_index = true
								s.name.value = "__cls_index"
								out:append("function " .. sname .. "." .. s.name.value .. "(")
								self:hlFnArgsBody(s, false)
							end
						elseif fn_name == "__call" then
							ctx:errorPos(cname .. " not support static " .. fn_name, s.name.pos)
						end
					end
				else 
					out:append("function " .. sname .. (fn_ins and ":" or ".") .. fn_name .. "(")
					self:hlFnArgsBody(s, fn_ins)
				end
			end
		end
		out:append("-- declare end")
		return fn_deinit
	end
	function __ct:hlFnArgsBody(e, fn_ins, comma_end)
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		ctx:pushScope("fn", e)
		for i, v in ipairs(e.args) do
			if i > 1 then
				out:append(", ")
			end
			self:trExpr(v)
			ctx:localInsert(v.value)
		end
		if fn_ins then
			ctx:localInsert("self")
		end
		out:append(")")
		out:popInline()
		out:incIndent()
		if #e.body > 0 then
			if e.df then
				out:append(e.df)
			end
			out:changeLine()
			self:trStatement(e.body)
		end
		out:decIndent()
		out:append("end" .. (comma_end and "," or ""))
		out:changeLine()
		ctx:popScope()
	end
	function __ct:hasColonDot(expr)
		if type(expr) == 'table' then
			if expr.etype == 'exp' then
				local count = #expr
				for i = count, 1, -1 do
					local v = expr[i]
					if v.etype == ':' or v.etype == '.' then
						return v.etype
					end
				end
			end
			return (expr.etype == ':' or expr.etype == '.') and expr.etype
		end
		return false
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
local function compile(config, data)
	if not (type(data) == "table" and data.ast and data.content) then
		return false, "Invalid data"
	end
	Ctx:reset(config, data.ast, data.content)
	Out:reset()
	M:reset(Ctx, Out)
	local ret, emsg = pcall(M.trStatement, M, Ctx.ast)
	if not (ret) then
		return false, (Ctx.err_info or { err_msg = emsg, pos = 0 })
	end
	return true, table.concat(Out._output, "\n")
end
local function clearproj()
	_scope_proj.vars = {  }
end
return { compile = compile, clearproj = clearproj }
