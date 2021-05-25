--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local Utils = require("mnscript.utils")
local Out = {}
do
	local __stype__ = nil
	local __clsname__ = "Out"
	local __clstype__ = Out
	__clstype__.classname = __clsname__
	__clstype__.classtype = __clstype__
	__clstype__.supertype = __stype__
	__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end
	__clstype__.isMemberOf = function(cls, a) return cls.classtype == a end
	__clstype__.init = function() end
	-- declare class var and methods
	function __clstype__:init()
		self:reset()
	end
	function __clstype__:reset(dryrun)
		self._indent = 0
		-- indent char
		self._changeLine = false
		-- force change line
		self._output = {  }
		-- output table
		self._inline = 0
		-- force expr oneline
		self._dryrun = dryrun
	end
	function __clstype__:incIndent()
		self._indent = self._indent + 1
	end
	function __clstype__:decIndent()
		self._indent = self._indent - 1
	end
	function __clstype__:changeLine()
		self._changeLine = true
	end
	function __clstype__:pushInline()
		self._inline = self._inline + 1
	end
	function __clstype__:popInline()
		self._inline = self._inline - 1
	end
	function __clstype__:isDryRun(set)
		return self._dryrun
	end
	function __clstype__:append(str, same_line)
		if self._dryrun then
			return 
		end
		assert(type(str) == "string", "Invalid input")
		local t = self._output
		same_line = same_line or (self._inline > 0)
		if same_line and  not self._changeLine then
			local i = math.max( # t, 1)
			t[i] = (t[i] or "") .. str
		else
			self._changeLine = false
			local indent = self._indent > 0 and string.rep("\t", self._indent) or ""
			t[ # t + 1] = indent .. str
		end
	end
	-- declare end
	local __ins_mt = {
		__tostring = function() return "instance of " .. __clsname__ end,
		__index = function(t, k) return rawget(t, k) or __clstype__[k] end,
	}
	setmetatable(__clstype__, {
		__tostring = function() return "class " .. __clsname__ end,
		__index = function(_, k) return rawget(__clstype__, k) or (__stype__ and __stype__[k]) end,
		__newindex = function() end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt)
			ins:init(...)
			return ins
		end,
	})
end
local _preserv_keyword = Utils.set({ "_G", "_VERSION", "_ENV", "assert", "bit32", "collectgarbage", "coroutine", "debug", "dofile", "error", "getfenv", "getmetatable", "io", "ipairs", "jit", "load", "loadfile", "loadstring", "math", "module", "next", "os", "package", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require", "select", "setfenv", "setmetatable", "string", "table", "tonumber", "tostring", "type", "unpack", "xpcall", "nil", "true", "false" })
local Ctx = {}
do
	local __stype__ = nil
	local __clsname__ = "Ctx"
	local __clstype__ = Ctx
	__clstype__.classname = __clsname__
	__clstype__.classtype = __clstype__
	__clstype__.supertype = __stype__
	__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end
	__clstype__.isMemberOf = function(cls, a) return cls.classtype == a end
	__clstype__.init = function() end
	-- declare class var and methods
	function __clstype__:init(config, ast, content)
		self.config = config
		self.ast = ast
		self.content = content
		self:reset()
	end
	function __clstype__:reset()
		self.loops = {  }
		self.funcs = {  }
		self.has_defer = false
		self.in_defer = false
		self.in_clsvar = false
		self.temp = {  }
		self.temp[1] = _preserv_keyword
		self.temp[2] = {  }
		self.error = nil
		self.last_pos = 0
	end
	function __clstype__:pushLoop(e)
		local t = self.loops
		t[ # t + 1] = e
	end
	function __clstype__:popLoop()
		local t = self.loops
		t[ # t] = nil
	end
	function __clstype__:pushFunc(e)
		local t = self.funcs
		t[ # t + 1] = e
	end
	function __clstype__:popFunc()
		local t = self.funcs
		t[ # t] = nil
	end
	function __clstype__:globalInsert(n)
		assert(type(n) == "string", "Invalid index")
		local t = self.temp[2]
		t[n] = true
	end
	function __clstype__:localPush()
		local t = self.temp
		t[ # t + 1] = {  }
	end
	function __clstype__:localPop()
		local t = self.temp
		t[ # t] = nil
	end
	function __clstype__:localInsert(n)
		assert(type(n) == "string", "Invalid index")
		local t = self.temp[ # self.temp]
		t[n] = true
	end
	-- treat lvar as to be defined, grammar checking
	function __clstype__:checkName(e, checkLeftLocal, onlyList1st)
		local ret, name, pos = self:isVarDeclared(e, checkLeftLocal, onlyList1st)
		if ret then
			return 
		end
		self:errorPos("undefined variable", name, pos - 1)
	end
	-- checkLeftLocal: check left define, in transform to Lua
	function __clstype__:isVarDeclared(e, checkLeftLocal, onlyList1st)
		local n, pos = nil, nil
		assert(type(e) == "table", "Invalid var declare type")
		local etype = e.etype
		if etype == "lvar" and e.list then
			n = e.list[1]
			pos = e.pos
		elseif etype == "lvar" and checkLeftLocal and  not onlyList1st then
			n = e.value
			pos = e.pos
		elseif etype == "rvar" then
			n = e.list and e.list[1] or e.value
			pos = e.pos
		elseif etype == "lexp" and checkLeftLocal and  not onlyList1st then
			n = e[1].value
			pos = e[1].pos
		else
			return true
		end
		local t = self.temp
		for i =  # t, 1,  - 1 do
			if t[i][n] then
				return true
			end
		end
		return false, n, pos
	end
	function __clstype__:errorPos(msg, symbol, pos)
		if self.error then
			return 
		end
		pos = pos or math.max(0, self.last_pos - 1)
		local err = Utils.posLine(self.content, pos)
		self.error = string.format("%s:%d: %s <%s '%s'>", self.config.fname or "_", err.line, err.message, msg, symbol)
	end
	function __clstype__:hasError()
		return self.error ~= nil
	end
	function __clstype__:updatePos(pos)
		if type(pos) == "number" and self.error == nil then
			self.last_pos = pos
		end
	end
	-- declare end
	local __ins_mt = {
		__tostring = function() return "instance of " .. __clsname__ end,
		__index = function(t, k) return rawget(t, k) or __clstype__[k] end,
	}
	setmetatable(__clstype__, {
		__tostring = function() return "class " .. __clsname__ end,
		__index = function(_, k) return rawget(__clstype__, k) or (__stype__ and __stype__[k]) end,
		__newindex = function() end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt)
			ins:init(...)
			return ins
		end,
	})
end
--[[
]]
-- class and instance metamethod except __tostring, __index, __newindex, __call
local _cls_metafns = Utils.set({ "__add", "__band", "__bnot", "__bor", "__bxor", "__close", "__concat", "__div", "__eq", "__gc", "__idiv", "__le", "__len", "__lt", "__metatable", "__mod", "__mode", "__mul", "__name", "__pairs", "__pow", "__shl", "__shr", "__sub", "__unm" })
local M = {}
do
	local __stype__ = nil
	local __clsname__ = "M"
	local __clstype__ = M
	__clstype__.classname = __clsname__
	__clstype__.classtype = __clstype__
	__clstype__.supertype = __stype__
	__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end
	__clstype__.isMemberOf = function(cls, a) return cls.classtype == a end
	__clstype__.init = function() end
	-- declare class var and methods
	function __clstype__:init(ctx, out)
		self.ctx = ctx
		self.out = out
	end
	function __clstype__:trOp(t)
		local ctx = self.ctx
		ctx:updatePos(t.pos)
		do 
			local __sw__ = t.op
			if __sw__ == ("(") then
				self:trOpPara(t)
			elseif __sw__ == (".") then
				self:trOpDot(t)
			elseif __sw__ == (":") then
				self:trOpColon(t)
			elseif __sw__ == ("[") then
				self:trOpSquare(t)
			else
				ctx:errorPos("Invalid op near", (t.op or "unknown"))
			end
		end
	end
	function __clstype__:trExpr(t)
		assert(type(t) == "table", "Invalid expr type")
		local ctx = self.ctx
		local out = self.out
		local etype = t.etype
		ctx:updatePos(t.pos)
		do 
			local __sw__ = etype
			if __sw__ == ("lvar") then
				if  not ctx.in_clsvar then
					ctx:checkName(t)
				end
				out:append(t.value, true)
			elseif __sw__ == ("rvar") then
				ctx:checkName(t)
				out:append(t.value, true)
			elseif __sw__ == ("number") then
				out:append(t.value, true)
			elseif __sw__ == ("string") then
				out:append(t.value, true)
			elseif __sw__ == ("varg") then
				out:append("...", true)
			elseif __sw__ == ("op") then
				if t.value == "(" or t.value == ")" then
					out:append(t.value, true)
				else
					out:append(" " .. t.value .. " ", true)
				end
			elseif __sw__ == ("{") then
				self:trEtTblDef(t)
			elseif __sw__ == ("fn") then
				self:trEtFnOnly(t)
			elseif __sw__ == ("rexp") then
				self:trEtRexp(t)
			elseif __sw__ == ("lexp") then
				self:trEtLexp(t)
			else
				if t.op then
					self:trOp(t)
				else
					ctx:errorPos("Invalid expr etype near", (etype or "unknown"))
				end
			end
		end
	end
	function __clstype__:trStatement(ast)
		local ctx = self.ctx
		local out = self.out
		for index = 1,  # ast, 1 do
			local t = ast[index]
			local stype = t.stype
			do 
				local __sw__ = stype
				if __sw__ == ("cm") then
					self:trStComment(t)
				elseif __sw__ == ("import") then
					self:trStImport(t)
				elseif __sw__ == ("fn") then
					self:trStFnDef(t)
				elseif __sw__ == ("(") then
					self:trStCall(t)
				elseif __sw__ == ("class") then
					self:trStClass(t)
				elseif __sw__ == ("ex") then
					self:trStExport(t)
				elseif __sw__ == ("return") then
					self:trStReturn(t)
				elseif __sw__ == ("defer") then
					self:trStDefer(t)
				elseif __sw__ == ("if") or __sw__ == ("elseif") or __sw__ == ("else") or __sw__ == ("ifend") then
					self:trStIfElse(t)
				elseif __sw__ == ("switch") then
					self:trStSwitch(t)
				elseif __sw__ == ("break") then
					self:trStBreak(t)
				elseif __sw__ == ("continue") then
					self:trStContinue(t)
				elseif __sw__ == ("goto") or __sw__ == ("::") then
					self:trStGoto(t)
				elseif __sw__ == ("for") then
					self:trStFor(t)
				elseif __sw__ == ("while") then
					self:trStWhile(t)
				elseif __sw__ == ("repeat") then
					self:trStRepeat(t)
				elseif __sw__ == ("=") then
					-- a = b * (2 + 4)
					self:trStEqual(t)
				elseif __sw__ == ("{") then
					self:trStDo(t)
				elseif __sw__ == ("raw") then
					-- generate by compiler
					self:trStRaw(t)
				elseif __sw__ == (";") then
					out:append(";", true)
				elseif __sw__ == ("#!") then
					if ctx.config.shebang then
						out:append("#!/usr/bin/env lua")
					end
				else
					if stype and stype:sub(stype:len(), stype:len()) == "=" then
						-- q ..= "hello"
						self:trStTwoEqual(t)
					else
						ctx:errorPos("Invalid stype near", (stype or "uknown stype"))
						return 
					end
				end
			end
			local nstype = ast[index + 1] and ast[index + 1].stype
			if stype ~= ";" then
				out:changeLine()
			end
		end
	end
	-- MARK: Op
	function __clstype__:trOpPara(t)
		assert(t.op == "(", "Invalid op (")
		local out = self.out
		out:pushInline()
		out:append("(", true)
		for i, e in ipairs(t) do
			if i > 1 then
				out:append(", ", true)
			end
			for _, v in ipairs(e) do
				self:trExpr(v)
			end
		end
		out:append(")", true)
		out:popInline()
	end
	function __clstype__:trOpDot(t)
		assert(t.op == ".", "Invalid op .")
		local out = self.out
		out:append("." .. t[1].value, true)
	end
	function __clstype__:trOpColon(t)
		assert(t.op == ":", "Invalid op :")
		local out = self.out
		out:append(":", true)
		for i, e in ipairs(t) do
			if e.etype then
				self:trExpr(e)
			else
				self:trOp(e)
			end
		end
	end
	function __clstype__:trOpSquare(t)
		assert(t.op == "[", "Invalid op [")
		local out = self.out
		out:pushInline()
		out:append("[", true)
		for i, e in ipairs(t) do
			self:trExpr(e)
		end
		out:append("]", true)
		out:popInline()
	end
	-- MARK: Expr
	function __clstype__:trEtTblDef(t)
		assert(t.etype == "{", "Invalid etype table def")
		local ctx = self.ctx
		local out = self.out
		out:append("{ ")
		for i, e in ipairs(t) do
			if e.stype then
				self:trStComment(e)
				out:changeLine()
			else
				if e.nkey ~= nil then
					local nk = e.nkey
					out:append(nk.value, true)
					out:append(" = ", true)
					out:append(nk.value, true)
				else
					if e.vkey ~= nil then
						local vk = e.vkey
						out:append(vk.value, true)
						out:append(" = ", true)
					elseif e.bkey ~= nil then
						local bk = e.bkey
						out:append("[", true)
						self:trExpr(bk)
						out:append("] = ", true)
					end
					for _, v in ipairs(e.value) do
						self:trExpr(v)
					end
				end
				if i <  # t then
					out:append(", ")
				end
			end
		end
		out:append(" }")
	end
	function __clstype__:trEtFnOnly(t)
		assert(t.etype == "fn", "Invalid etype fn def only")
		local args = t.args or {  }
		local body = t.body
		local ctx = self.ctx
		local out = self.out
		ctx:localPush()
		ctx:pushFunc(t)
		out:append("function(" .. Utils.seqReduce(args, "", function(init, i, v)
			ctx:localInsert(v.value)
			return init .. (i > 1 and ", " or "") .. v.value
		end
		) .. ")")
		if  # body > 0 then
			out:changeLine()
			out:incIndent()
			self:trStatement(body)
			if ctx.has_defer and body[ # body].stype ~= "return" then
				out:append(( # t > 0 and ", " or "") .. "__df_run__()")
			end
			out:decIndent()
		end
		out:append("end")
		if  # body > 0 then
			out:changeLine()
		end
		ctx:popFunc()
		ctx:localPop()
		ctx.has_defer = false
	end
	function __clstype__:trEtRexp(t)
		assert(t.etype == "rexp", "Invalid etype rexp")
		local ctx = self.ctx
		local out = self.out
		ctx:checkName(t[1])
		for i, e in ipairs(t) do
			if e.etype then
				self:trExpr(e)
			elseif e.op then
				self:trOp(e)
			end
		end
	end
	function __clstype__:trEtLexp(t)
		assert(t.etype == "lexp", "Invalid etype lexp")
		local ctx = self.ctx
		local out = self.out
		ctx:checkName(t[1], ( # t - 1) > 0)
		for i, e in ipairs(t) do
			if e.etype then
				self:trExpr(e)
			elseif e.op then
				self:trOp(e)
			end
		end
	end
	-- MARK: Statement
	function __clstype__:trStEqual(t)
		assert(t.stype == "=", "Invalid stype equal")
		assert( # t == 2, "Invalid asign count")
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		for i, v in ipairs(t[1]) do
			if i == 1 then
				if  not ctx:isVarDeclared(v, true) then
					out:append("local ")
				end
			else
				out:append(", ")
			end
			self:trExpr(v)
		end
		out:append(" = ")
		for i, v in ipairs(t[2]) do
			if i > 1 then
				out:append(", ")
			end
			for _, n in ipairs(v) do
				self:trExpr(n)
			end
		end
		out:popInline()
		-- name
		for i, e in ipairs(t[1]) do
			if e.etype == "lexp" and  # e == 1 then
				ctx:localInsert(e[1].value)
			end
		end
	end
	function __clstype__:trStTwoEqual(t)
		assert(t.stype:sub(2, 2) == "=", "Invalid stype two equal")
		local ctx = self.ctx
		local out = self.out
		assert( # t == 2, "Invalid asign count")
		out:pushInline()
		ctx:checkName(t[1], true)
		self:trExpr(t[1])
		out:append(" = ")
		self:trExpr(t[1])
		out:append(" " .. t.stype:sub(1, t.stype:len() - 1) .. " (")
		for _, v in ipairs(t[2]) do
			self:trExpr(v)
		end
		out:append(")")
		out:popInline()
	end
	function __clstype__:trStComment(t)
		assert(t.stype == "cm", "Invalid stype cm")
		self.out:append(t.value)
	end
	function __clstype__:trStImport(t)
		assert(t.stype == "import", "Invalid stype import")
		local ctx = self.ctx
		local out = self.out
		if  # t <= 0 then
			out:append("require(" .. t.slib.value .. ")")
		elseif t[2] == nil then
			local lt = t[1][1]
			if t.slib then
				out:append("local " .. lt.value .. " = require(" .. t.slib.value .. ")")
			else
				ctx:checkName(t.tlib, true)
				out:append("local " .. lt.value .. " = " .. t.tlib.value)
			end
			ctx:localInsert(lt.value)
		else
			local lt = t[1]
			local rt = t[2]
			if  # rt <= 0 then
				rt = lt
			end
			out:append(Utils.seqReduce(lt, "local ", function(init, i, v)
				ctx:localInsert(v.value)
				return init .. (i > 1 and ", " or "") .. v.value
			end
			))
			out:append("do")
			out:incIndent()
			if t.slib then
				out:append("local __lib__ = require(" .. t.slib.value .. ")")
			else
				ctx:checkName(t.tlib, true)
				out:append("local __lib__ = " .. t.tlib.value)
			end
			out:append(Utils.seqReduce(lt, "", function(init, i, v)
				return init .. (i > 1 and ", " or "") .. v.value
			end
			))
			out:append(" = " .. Utils.seqReduce(rt, "", function(init, i, v)
				return init .. (i > 1 and ", __lib__." or "__lib__.") .. v.value
			end
			), true)
			out:decIndent()
			out:append("end")
		end
	end
	function __clstype__:trStExport(t)
		assert(t.stype == "ex", "Invalid stype export")
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		if t.attr == "local" then
			out:append("local ")
			for i, v in ipairs(t[1]) do
				if i > 1 then
					out:append(", ")
				end
				self:trExpr(v)
				ctx:localInsert(v.value)
			end
			if t[2] then
				out:append(" = ")
				for i, e in ipairs(t[2]) do
					if i > 1 then
						out:append(", ")
					end
					for _, v in ipairs(e) do
						self:trExpr(v)
					end
				end
			end
		elseif t.attr == "export" then
			for i, v in ipairs(t[1]) do
				ctx:globalInsert(v.value)
			end
			if t[2] then
				for i, v in ipairs(t[1]) do
					if i > 1 then
						out:append(",")
					end
					self:trExpr(v)
				end
				out:append(" = ")
				for i, e in ipairs(t[2]) do
					if i > 1 then
						out:append(", ")
					end
					for _, v in ipairs(e) do
						self:trExpr(v)
					end
				end
			end
		else
			ctx:errorPos("Invalid export attr near", (t.attr or "unknown"))
		end
		out:popInline()
	end
	function __clstype__:trStFnDef(t)
		assert(t.stype == "fn", "Invalid stype fn")
		local attr = (t.attr == "export" and "" or "local ")
		local name = t.name and t.name.value or ""
		local args = t.args or {  }
		local body = t.body
		local ctx = self.ctx
		local out = self.out
		ctx:checkName(t.name, true, true)
		if t.attr == "export" then
			ctx:globalInsert(name)
		else
			ctx:localInsert(name)
		end
		ctx:pushFunc(t)
		ctx:localPush()
		out:append(attr .. "function " .. name .. "(" .. Utils.seqReduce(args, "", function(init, i, v)
			ctx:localInsert(v.value)
			return init .. (i > 1 and ", " or "") .. v.value
		end
		) .. ")")
		if  # body > 0 then
			out:changeLine()
			out:incIndent()
			self:trStatement(body)
			if ctx.has_defer and body[ # body].stype ~= "return" then
				out:append(( # t > 0 and ", " or "") .. "__df_run__()")
			end
			out:decIndent()
		end
		out:append("end")
		ctx:popFunc()
		ctx:localPop()
		ctx.has_defer = false
	end
	function __clstype__:trStCall(t)
		assert(t.stype == "(", "Invalid stype fn call")
		local ctx = self.ctx
		local out = self.out
		local n = 0
		if t[1].etype == "lvar" then
			n = 1
			ctx:checkName(t[1], true)
			out:pushInline()
			out:append(t[1].value, true)
		end
		for i, e in ipairs(t) do
			if i > n then
				if e.etype then
					self:trExpr(e)
				elseif e.op then
					self:trOp(e)
				end
			end
		end
		out:popInline()
	end
	function __clstype__:trStIfElse(t)
		local ctx = self.ctx
		local out = self.out
		if t.stype == "if" or t.stype == "elseif" then
			out:append(t.stype .. " ")
			out:pushInline()
			for _, v in ipairs(t[1]) do
				self:trExpr(v)
			end
			out:popInline()
			out:append(" then", true)
			ctx:localPush()
			out:changeLine()
			out:incIndent()
			self:trStatement(t[2])
			ctx:localPop()
			out:decIndent()
		elseif t.stype == "else" then
			ctx:localPush()
			out:append("else")
			out:changeLine()
			out:incIndent()
			self:trStatement(t[1])
			out:decIndent()
			ctx:localPop()
		elseif t.stype == "ifend" then
			out:append("end")
		else
			ctx:errorPos("Invalid stype near", (t.stype or "unknown"))
		end
	end
	function __clstype__:trStSwitch(t)
		assert(t.stype == "switch", "Invalid stype switch")
		local ctx = self.ctx
		local out = self.out
		out:append("do ")
		out:incIndent()
		out:append("local __sw__ = ")
		out:pushInline()
		for _, v in ipairs(t[1]) do
			self:trExpr(v)
		end
		out:popInline()
		out:changeLine()
		for i = 2,  # t do
			local c = t[i]
			out:pushInline()
			if c.stype == "case" then
				if i == 2 then
					out:append("if ")
				else
					out:append("elseif ")
				end
				out:append("__sw__ == (")
				for j, s in ipairs(c) do
					if j > 1 then
						out:append(") or __sw__ == (")
					end
					for _, e in ipairs(s) do
						self:trExpr(e)
					end
				end
				out:append(") then")
				out:changeLine()
				ctx:localPush()
			else
				out:append("else")
				out:changeLine()
				ctx:localPush()
			end
			out:popInline()
			out:incIndent()
			self:trStatement(c.body)
			out:decIndent()
			ctx:localPop()
			if i ==  # t then
				out:append("end")
				out:changeLine()
			end
		end
		out:decIndent()
		out:append("end")
	end
	function __clstype__:trStFor(t)
		assert(t.stype == "for", "Invalid stype for")
		local list = t[1]
		local staments = t[2]
		local ctx = self.ctx
		local out = self.out
		ctx:pushLoop(t)
		out:pushInline()
		out:append("for ")
		ctx:localPush()
		if list.sub == "=" then
			for i, e in ipairs(list) do
				if i == 1 then
					self:trExpr(e)
					out:append(" = ")
					ctx:localInsert(e.value)
				else
					if i > 2 then
						out:append(", ")
					end
					for _, v in ipairs(e) do
						self:trExpr(v)
					end
				end
			end
		elseif list.sub == "in" then
			for i, e in ipairs(list) do
				if i ==  # list then
					out:append(" in ")
				elseif i > 1 then
					out:append(", ")
				end
				if i ==  # list then
					for j, v in ipairs(e) do
						if j > 1 then
							out:append(", ")
						end
						for _, z in ipairs(v) do
							self:trExpr(z)
						end
					end
				else
					self:trExpr(e)
				end
				if i ~=  # list then
					ctx:localInsert(e.value)
				end
			end
		else
			ctx:errorPos("Invalid sub near", (list.sub or "unknown"))
			return 
		end
		out:append(" do")
		out:popInline()
		out:changeLine()
		out:incIndent()
		self:trStatement(staments)
		out:decIndent()
		out:append("end")
		ctx:localPop()
		ctx:popLoop()
	end
	function __clstype__:trStWhile(t)
		assert(t.stype == "while", "Invalid stype while")
		local ctx = self.ctx
		local out = self.out
		ctx:pushLoop(t)
		out:append("while ")
		out:pushInline()
		for _, v in ipairs(t[1]) do
			self:trExpr(v)
		end
		out:append(" do")
		ctx:localPush()
		out:popInline()
		out:changeLine()
		out:incIndent()
		self:trStatement(t[2])
		out:decIndent()
		out:append("end")
		ctx:popLoop()
		ctx:localPop()
	end
	function __clstype__:trStRepeat(t)
		assert(t.stype == "repeat", "Invalid repeat op")
		local ctx = self.ctx
		local out = self.out
		ctx:pushLoop(t)
		out:append("repeat")
		out:changeLine()
		out:incIndent()
		ctx:localPush()
		self:trStatement(t[1])
		out:decIndent()
		out:append("until ")
		out:pushInline()
		for _, v in ipairs(t[2]) do
			self:trExpr(v)
		end
		out:popInline()
		ctx:popLoop()
		ctx:localPop()
	end
	function __clstype__:trStBreak(t)
		assert(t.stype == "break", "Invalid stype break")
		local ctx = self.ctx
		local out = self.out
		if  # ctx.loops <= 0 then
			ctx:errorPos("not in loop", t.stype, t.pos - 1)
			return 
		end
		out:append("break")
	end
	function __clstype__:trStContinue(t)
		assert(t.stype == "continue", "Invalid continue op")
		local ctx = self.ctx
		local out = self.out
		if  # ctx.loops <= 0 then
			ctx:errorPos("not in loop", t.stype, t.pos - 1)
			return 
		end
		out:append("goto __continue__")
		if  not out:isDryRun() then
			return 
		end
		local e = ctx.loops[ # ctx.loops]
		local le = e.stype == "repeat" and e[1] or e[ # e]
		if  # le == 0 or le[ # le].stype ~= "raw" or le[ # le].sub ~= "continue" then
			le[ # le + 1] = { stype = "raw", sub = "continue", "::__continue__::" }
		end
	end
	function __clstype__:trStGoto(t)
		assert(t.stype == "goto" or t.stype == "::", "Invalid stype go")
		local out = self.out
		if t.stype == "goto" then
			out:append("goto " .. t.name.value)
		else
			out:append("::" .. t.name.value .. "::")
		end
	end
	function __clstype__:trStReturn(t)
		assert(t.stype == "return", "Invalid stpye return")
		local ctx = self.ctx
		local out = self.out
		out:append("return ")
		out:pushInline()
		for i, e in ipairs(t) do
			if i > 1 then
				out:append(", ")
			end
			for _, v in ipairs(e) do
				self:trExpr(v)
			end
		end
		if ctx.has_defer then
			out:append(( # t > 0 and ", " or "") .. "__df_run__()")
		end
		out:popInline()
	end
	function __clstype__:trStDefer(t)
		assert(t.stype == "defer", "Invalid stype defer")
		local ctx = self.ctx
		local out = self.out
		if  # ctx.funcs <= 0 then
			ctx:errorPos("not in function", t.stype, t.pos)
			return 
		end
		if out:isDryRun() then
			local funcs = ctx.funcs
			local e = funcs[ # funcs]
			local body = e.body
			if  # body == 0 or body[1].stype ~= "raw" or body[1].sub ~= "defer" then
				local tbl = { stype = "raw", sub = "defer", "local __df_fns__ = {}", "local __df_run__ = function() local t=__df_fns__; for i=#t, 1, -1 do t[i]() end; end" }
				table.insert(body, 1, tbl)
			end
		elseif  not ctx.in_defer then
			ctx.in_defer = true
			out:append("__df_fns__[#__df_fns__ + 1] = function()")
			out:changeLine()
			out:incIndent()
			ctx:localPush()
			self:trStatement(t[1])
			ctx:localPop()
			out:decIndent()
			out:append("end")
			ctx.in_defer = false
		end
	end
	function __clstype__:trStDo(t)
		assert(t.stype == "{", "Invalid stype do end")
		local ctx = self.ctx
		local out = self.out
		ctx:localPush()
		out:append("do")
		out:changeLine()
		out:incIndent()
		self:trStatement(t[1])
		out:decIndent()
		out:append("end")
		ctx:localPop()
	end
	-- generated by compiler 1st pass
	function __clstype__:trStRaw(t)
		assert(t.stype == "raw", "Invalid stype raw")
		local ctx = self.ctx
		if t.sub == "defer" then
			ctx.has_defer = true
		end
		local out = self.out
		for _, v in ipairs(t) do
			out:append(v)
			out:changeLine()
		end
	end
	function __clstype__:trStClass(t)
		assert(t.stype == "class", "Invalid stype class")
		local ctx = self.ctx
		local out = self.out
		local attr = (t.attr == "export") and "" or "local "
		local clsname = t.name.value
		local supertype = t.super and t.super.value
		if t.attr == "export" then
			ctx:globalInsert(clsname)
		else
			ctx:localInsert(clsname)
		end
		if supertype then
			ctx:checkName(t.super)
		end
		out:append(attr .. clsname .. " = {}")
		out:append("do")
		out:changeLine()
		out:incIndent()
		out:append("local __stype__ = " .. (supertype or "nil"))
		out:append('local __clsname__ = "' .. clsname .. '"')
		out:append("local __clstype__ = " .. clsname)
		if supertype then
			out:append('assert(type(__stype__) == "table" and type(__stype__.classtype) == "table")')
			out:append('for k, v in pairs(__stype__) do __clstype__[k] = v end')
		end
		out:append("__clstype__.classname = __clsname__")
		out:append("__clstype__.classtype = __clstype__")
		out:append("__clstype__.supertype = __stype__")
		if  not supertype then
			out:append("__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end")
			out:append("__clstype__.isMemberOf = function(cls, a) return cls.classtype == a end")
			out:append("__clstype__.init = function() end")
		end
		--
		out:append("-- declare class var and methods")
		out:changeLine()
		local fn_deinit = false
		local cls_fns = {  }
		local ins_fns = {  }
		for _, e in ipairs(t) do
			local stype = e.stype
			if stype == "=" then
				ctx.in_clsvar = true
				out:append("__clstype__.")
				out:pushInline()
				for i, v in ipairs(e) do
					self:trExpr(v)
					if i == 1 then
						out:append(" = ")
					end
				end
				out:popInline()
				out:changeLine()
				ctx.in_clsvar = false
			elseif stype == "fn" then
				local fn_name = e.name.value
				if fn_name == "deinit" then
					fn_deinit = true
				end
				local fn_ins = e.attr ~= "class"
				if _cls_metafns[fn_name] then
					if e.attr == "class" then
						cls_fns[ # cls_fns + 1] = e
					else
						ins_fns[ # ins_fns + 1] = e
					end
				else
					out:append("function __clstype__" .. (fn_ins and ":" or ".") .. fn_name .. "(")
					self:hlClsFnArgsBody(e, fn_ins, false)
				end
			elseif stype == "cm" then
				self:trStComment(e)
			end
		end
		out:append("-- declare end")
		--
		out:append("local __ins_mt = {")
		out:incIndent()
		out:append('__tostring = function() return "instance of " .. __clsname__ end,')
		out:append("__index = function(t, k) return rawget(t, k) or __clstype__[k] end,")
		if fn_deinit then
			out:append("__gc = function(t) t:deinit() end,")
		end
		for _, e in ipairs(ins_fns) do
			out:append(e.name.value .. " = function(")
			self:hlClsFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("}")
		--
		out:append("setmetatable(__clstype__, {")
		out:incIndent()
		out:append('__tostring = function() return "class " .. __clsname__ end,')
		out:append('__index = function(_, k) return rawget(__clstype__, k) or (__stype__ and __stype__[k]) end,')
		out:append('__newindex = function() end,')
		out:append("__call = function(_, ...)")
		out:incIndent()
		out:append("local ins = setmetatable({}, __ins_mt)")
		if fn_deinit then
			out:append('if _VERSION == "Lua 5.1" then')
			out:incIndent()
			out:append("ins.__gc_proxy = newproxy(true)")
			out:append("getmetatable(ins.__gc_proxy).__gc = function() ins:deinit() end")
			out:decIndent()
			out:append("end")
		end
		out:append("ins:init(...)")
		out:append("return ins")
		out:decIndent()
		out:append("end,")
		for _, e in ipairs(cls_fns) do
			out:append(e.name.value .. " = function(")
			self:hlClsFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("})")
		--
		out:decIndent()
		out:append("end")
	end
	function __clstype__:hlClsFnArgsBody(e, fn_ins, comma_end)
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		ctx:localPush()
		if e.args then
			for i, v in ipairs(e.args) do
				if i > 1 then
					out:append(", ")
				end
				self:trExpr(v)
				ctx:localInsert(v.value)
			end
		end
		if fn_ins then
			ctx:localInsert("self")
		end
		out:append(")")
		out:changeLine()
		out:popInline()
		out:incIndent()
		self:trStatement(e.body)
		out:decIndent()
		out:append("end" .. (comma_end and "," or ""))
		out:changeLine()
		ctx:localPop()
	end
	-- declare end
	local __ins_mt = {
		__tostring = function() return "instance of " .. __clsname__ end,
		__index = function(t, k) return rawget(t, k) or __clstype__[k] end,
	}
	setmetatable(__clstype__, {
		__tostring = function() return "class " .. __clsname__ end,
		__index = function(_, k) return rawget(__clstype__, k) or (__stype__ and __stype__[k]) end,
		__newindex = function() end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt)
			ins:init(...)
			return ins
		end,
	})
end
--[[
    config as { fname : "filename", shebang : false }    
    data as { content : CONTENT, ast : AST_TREE }
]]
local function compile(config, data)
	assert(type(data) == "table", "Invalid data")
	assert(type(data.ast) == "table", "Invalid AST")
	assert(type(data.content) == "string", "Invalid content")
	local ctx = Ctx(config, data.ast, data.content)
	local out = Out()
	local comp = M(ctx, out)
	out:reset(true)
	comp:trStatement(ctx.ast)
	if ctx:hasError() then
		return false, ctx.error
	end
	ctx:reset()
	out:reset()
	comp:trStatement(ctx.ast)
	return true, table.concat(out._output, "\n")
end
return { compile = compile }
