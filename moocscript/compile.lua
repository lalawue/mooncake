--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local Utils = require("moocscript.utils")
local setmetatable = setmetatable
local assert = assert
local type = type
local srep = string.rep
local ipairs = ipairs
local mathmax = math.max
local Out = {}
do
	local __clsname__ = "Out"
	local __clstype__ = Out
	__clstype__.typename = __clsname__
	__clstype__.typekind = 'struct'
	__clstype__.classtype = __clstype__
	-- declare var and methods
	__clstype__._indent = 0
	__clstype__._changeLine = false
	__clstype__._output = {  }
	__clstype__._inline = 0
	function __clstype__:init()
		self._indent = 0
		-- indent char
		self._changeLine = false
		-- force change line
		self._output = {  }
		-- output table
		self._inline = 0
		-- force expr oneline
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
	function __clstype__:append(str, same_line)
		assert(type(str) == "string", "Invalid input")
		local t = self._output
		same_line = same_line or (self._inline > 0)
		if same_line and not self._changeLine then
			local i = mathmax(#t, 1)
			t[i] = (t[i] or "") .. str
		else
			self._changeLine = false
			local prefix = self._indent > 0 and srep("\t", self._indent) or ""
			t[#t + 1] = prefix .. str
		end
	end
	function __clstype__:getInfo()
		return { #self._output, self._indent }
	end
	function __clstype__:appendExt(info, tbl)
		local t = self._output
		if #info > 1 and info[1] <= #t then
			local idx, indent = info[1], info[2]
			local prefix = indent > 0 and srep("\t", indent) or ""
			for _, v in ipairs(tbl) do
				t[idx] = (t[idx] or "") .. "\n" .. prefix .. v
			end
		end
	end
	-- declare end
	local __ins_mt__ = {
		__tostring = function() return "one of " .. __clsname__ end,
		__index = function(t, k)
			local v = rawget(__clstype__, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__clstype__, k) ~= nil then rawset(t, k, v) end end,
	}
	Out = setmetatable({}, {
		__tostring = function() return "struct " .. __clsname__ end,
		__index = function(_, k) return rawget(__clstype__, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__clstype__, k) ~= nil then rawset(__clstype__, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt__)
			if ins:init(...) == false then return nil end
			return ins
		end,
	})
end
local _global_names = Utils.set({ "_G", "_VERSION", "_ENV", "assert", "collectgarbage", "coroutine", "debug", "dofile", "error", "getfenv", "getmetatable", "io", "ipairs", "jit", "load", "loadfile", "loadstring", "math", "module", "next", "os", "package", "pairs", "pcall", "print", "rawequal", "rawget", "rawlen", "rawset", "require", "select", "setfenv", "setmetatable", "string", "table", "tonumber", "tostring", "type", "unpack", "xpcall", "nil", "true", "false" })
local _scope_global = { ["otype"] = "gl", ["vars"] = _global_names }
local _scope_proj = { ["otype"] = "pj", ["vars"] = {  } }
local Ctx = {}
do
	local __clsname__ = "Ctx"
	local __clstype__ = Ctx
	__clstype__.typename = __clsname__
	__clstype__.typekind = 'struct'
	__clstype__.classtype = __clstype__
	-- declare var and methods
	__clstype__.config = false
	__clstype__.ast = false
	__clstype__.content = false
	__clstype__.scopes = false
	__clstype__.in_defer = false
	__clstype__.in_clsvar = false
	__clstype__.in_clsname = false
	__clstype__.in_supname = false
	__clstype__.err_info = false
	__clstype__.last_pos = 0
	-- MARK:
	function __clstype__:init(config, ast, content)
		self.config = config
		self.ast = ast
		self.content = content
		-- { otype : "gl|pj|fi|cl|fn|lo|if|do|gu", vars : {} }
		self.scopes = { _scope_global, _scope_proj, { ["otype"] = "fi", ["vars"] = {  }, ["loidx"] = 0 } }
	end
	function __clstype__:pushScope(ot, exp)
		local t = self.scopes
		local scope = { ["otype"] = ot, ["vars"] = {  }, ["exp"] = exp }
		t[#t + 1] = scope
		if ot == "lo" then
			t[3].loidx = t[3].loidx + (1)
			scope.loidx = t[3].loidx
		end
	end
	function __clstype__:popScope()
		local t = self.scopes
		t[#t] = nil
	end
	function __clstype__:getScope(otype)
		local t = self.scopes
		for i = #t, 1, -1 do
			local v = t[i]
			if v.otype == otype then
				return v
			end
		end
	end
	function __clstype__:supportDefer()
		local t = self.scopes
		for i = #t, 3, -1 do
			if t[i].otype == "fn" then
				return true
			end
		end
		return false
	end
	function __clstype__:isInLoop()
		local t = self.scopes
		for i = #t, 3, -1 do
			local otype = t[i].otype
			if otype == "fn" then
				return false
			elseif otype == "lo" then
				return true
			end
		end
		return false
	end
	function __clstype__:pushDefer()
		local t = self.scopes
		for i = #t, 3, -1 do
			local v = t[i]
			if v.otype == "fn" then
				v.has_defer = true
				break
			end
		end
	end
	function __clstype__:hasDefers()
		local t = self.scopes
		for i = #t, 3, -1 do
			local v = t[i]
			if v.otype == "fn" then
				return v.has_defer
			end
		end
		return false
	end
	function __clstype__:pushOutInfo(info)
		local t = self.scopes
		t[#t].info = info
	end
	function __clstype__:getOutInfo(otype)
		local t = self.scopes
		for i = #t, 3, -1 do
			local v = t[i]
			if v.otype == otype then
				return v.info
			end
		end
	end
	function __clstype__:globalInsert(n)
		local t = self.scopes
		t[2].vars[n] = true
	end
	function __clstype__:localInsert(n)
		local t = self.scopes
		t[#t].vars[n] = true
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
		elseif etype == "lvar" and checkLeftLocal and not onlyList1st then
			n = e.value
			pos = e.pos
		elseif etype == "rvar" then
			n = e.list and e.list[1] or e.value
			pos = e.pos
		elseif etype == "lexp" and checkLeftLocal and not onlyList1st then
			n = e[1].value
			pos = e[1].pos
		else
			return true
		end
		local t = self.scopes
		for i = #t, 1, -1 do
			if t[i].vars[n] or t[i].vars["*"] then
				return true
			end
		end
		return false, n, pos
	end
	function __clstype__:errorPos(msg, symbol, pos)
		if self.err_info then
			return 
		end
		pos = pos or mathmax(0, self.last_pos - 1)
		local err = Utils.posLine(self.content, pos)
		self.err_info = string.format("%s:%d: %s <%s '%s'>", self.config.fname or "_", err.line, err.message, msg, symbol)
	end
	function __clstype__:hasError()
		return self.err_info
	end
	function __clstype__:updatePos(pos)
		if type(pos) == "number" and not self.err_info then
			self.last_pos = pos
		end
	end
	-- declare end
	local __ins_mt__ = {
		__tostring = function() return "one of " .. __clsname__ end,
		__index = function(t, k)
			local v = rawget(__clstype__, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__clstype__, k) ~= nil then rawset(t, k, v) end end,
	}
	Ctx = setmetatable({}, {
		__tostring = function() return "struct " .. __clsname__ end,
		__index = function(_, k) return rawget(__clstype__, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__clstype__, k) ~= nil then rawset(__clstype__, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt__)
			if ins:init(...) == false then return nil end
			return ins
		end,
	})
end
--[[
]]
-- class and instance metamethod except __tostring, __index, __newindex, __call
local _cls_metafns = Utils.set({ "__add", "__band", "__bnot", "__bor", "__bxor", "__close", "__concat", "__div", "__eq", "__idiv", "__le", "__len", "__lt", "__metatable", "__mod", "__mode", "__mul", "__name", "__pairs", "__pow", "__shl", "__shr", "__sub", "__unm" })
local _no_space_op = Utils.set({ "(", ")", "#", "~", "-" })
local _right_space_op = Utils.set({ "not" })
local M = {}
do
	local __clsname__ = "M"
	local __clstype__ = M
	__clstype__.typename = __clsname__
	__clstype__.typekind = 'struct'
	__clstype__.classtype = __clstype__
	-- declare var and methods
	__clstype__.ctx = false
	__clstype__.out = false
	__clstype__.opfn = {  }
	__clstype__.exfn = {  }
	__clstype__.stfn = {  }
	function __clstype__:init(ctx, out)
		self.ctx = ctx
		self.out = out
	end
	function __clstype__:trOp(t)
		local ctx = self.ctx
		ctx:updatePos(t.pos)
		local op = t.op
		local func = self.opfn[op]
		if func then
			func(self, t)
			return 
		end
		local __sw__ = op
		if __sw__ == ("(") then
			func = self.trOpPara
		elseif __sw__ == (".") then
			func = self.trOpDot
		elseif __sw__ == (":") then
			func = self.trOpColon
		elseif __sw__ == ("[") then
			func = self.trOpSquare
		else
			ctx:errorPos("Invalid op near", (t.op or "unknown"))
			return 
		end
		self.opfn[op] = func
		func(self, t)
	end
	function __clstype__:trExpr(t)
		assert(type(t) == "table", "Invalid expr type")
		local ctx = self.ctx
		local out = self.out
		local etype = t.etype
		local func = self.exfn[etype or t.op]
		ctx:updatePos(t.pos)
		if func then
			func(self, t)
			return 
		end
		local __sw__ = etype
		if __sw__ == ("lvar") then
			func = function(self, t)
				local ctx = self.ctx
				local out = self.out
				if not ctx.in_clsvar then
					ctx:checkName(t)
				end
				if ctx.in_clsname and t.value == "Self" then
					out:append(ctx.in_clsname, true)
				elseif ctx.in_supname and t.value == "Super" then
					out:append(ctx.in_supname, true)
				else
					out:append(t.value, true)
				end
			end
		elseif __sw__ == ("rvar") then
			func = function(self, t)
				local ctx = self.ctx
				local out = self.out
				ctx:checkName(t)
				if ctx.in_clsname and t.value == "Self" then
					out:append(ctx.in_clsname, true)
				elseif ctx.in_supname and t.value == "Super" then
					out:append(ctx.in_supname, true)
				else
					out:append(t.value, true)
				end
			end
		elseif __sw__ == ("number") then
			func = function(self, t)
				self.out:append(t.value, true)
			end
		elseif __sw__ == ("string") then
			func = function(self, t)
				self.out:append(t.value, true)
			end
		elseif __sw__ == ("varg") then
			func = function(self, t)
				self.out:append("...", true)
			end
		elseif __sw__ == ("op") then
			func = function(self, t)
				local out = self.out
				if _no_space_op[t.value] and not t.sub then
					out:append(t.value, true)
				elseif _right_space_op[t.value] then
					out:append(t.value .. " ", true)
				elseif t.value == "!=" then
					out:append(" ~= ", true)
				else
					out:append(" " .. t.value .. " ", true)
				end
			end
		elseif __sw__ == ("{") then
			func = self.trEtTblDef
		elseif __sw__ == ("fn") then
			func = self.trEtFnOnly
		elseif __sw__ == ("rexp") then
			func = self.trEtRexp
		elseif __sw__ == ("lexp") then
			func = self.trEtLexp
		elseif __sw__ == ("sexp") then
			func = self.trEtSexp
		else
			if t.op then
				func = self.trOp
			else
				ctx:errorPos("Invalid expr etype near", (etype or "unknown"))
				return 
			end
		end
		self.exfn[etype or t.op] = func
		func(self, t)
	end
	function __clstype__:trStatement(ast)
		local ctx = self.ctx
		local out = self.out
		local stfn = self.stfn
		local index = 0
		while true do
			index = index + (1)
			if index > #ast then
				break
			end
			local t = ast[index]
			local stype = t.stype
			local func = stfn[stype]
			if func then
				func(self, t)
			else
				local __sw__ = stype
				if __sw__ == ("cm") then
					func = self.trStComment
				elseif __sw__ == ("import") then
					func = self.trStImport
				elseif __sw__ == ("fn") then
					func = self.trStFnDef
				elseif __sw__ == ("(") then
					func = self.trStCall
				elseif __sw__ == ("class") then
					func = self.trStClass
				elseif __sw__ == ("struct") then
					func = self.trStStruct
				elseif __sw__ == ("extension") then
					func = self.trStExtension
				elseif __sw__ == ("ex") then
					func = self.trStExport
				elseif __sw__ == ("return") then
					func = self.trStReturn
				elseif __sw__ == ("defer") then
					func = self.trStDefer
				elseif __sw__ == ("if") or __sw__ == ("elseif") or __sw__ == ("else") or __sw__ == ("ifend") then
					func = self.trStIfElse
				elseif __sw__ == ("switch") then
					func = self.trStSwitch
				elseif __sw__ == ("guard") then
					func = self.trStGuard
				elseif __sw__ == ("break") then
					func = self.trStBreak
				elseif __sw__ == ("continue") then
					func = self.trStContinue
				elseif __sw__ == ("goto") or __sw__ == ("::") then
					func = self.trStGoto
				elseif __sw__ == ("for") then
					func = self.trStFor
				elseif __sw__ == ("while") then
					func = self.trStWhile
				elseif __sw__ == ("repeat") then
					func = self.trStRepeat
				elseif __sw__ == ("=") then
					-- a = b * (2 + 4)
					func = self.trStEqual
				elseif __sw__ == ("do") then
					func = self.trStDo
				elseif __sw__ == ("raw") then
					-- generate by compiler
					func = self.trStRaw
				elseif __sw__ == (";") then
					func = function(self, _)
						self.out:append(";", true)
					end
				elseif __sw__ == ("#!") then
					func = function(self, _)
						if self.ctx.config.shebang then
							self.out:append("#!/usr/bin/env lua")
						end
					end
				else
					if stype and stype:sub(stype:len(), stype:len()) == "=" then
						-- q ..= "hello"
						func = self.trStTwoEqual
					else
						ctx:errorPos("Invalid stype near", (stype or "uknown stype"))
						return 
					end
				end
				stfn[stype] = func
				func(self, t)
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
						out:append('["' .. vk.value .. '"]', true)
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
				if i < #t then
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
		ctx:pushScope("fn", t)
		out:append("function(" .. Utils.seqReduce(args, "", function(init, i, v)
			ctx:localInsert(v.value)
			return init .. (i > 1 and ", " or "") .. v.value
		end) .. ")")
		out:incIndent()
		ctx:pushOutInfo(out:getInfo())
		if #body > 0 then
			out:changeLine()
			self:trStatement(body)
			if ctx:hasDefers() and body[#body].stype ~= "return" then
				out:append((#t > 0 and ", " or "") .. "__df_run__()")
				out:changeLine()
			end
		end
		out:decIndent()
		out:append("end")
		ctx:popScope()
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
		ctx:checkName(t[1], (#t - 1) > 0)
		for i, e in ipairs(t) do
			if e.etype then
				self:trExpr(e)
			elseif e.op then
				self:trOp(e)
			end
		end
	end
	function __clstype__:trEtSexp(t)
		assert(t.etype == "sexp", "Invalid etype sexp")
		local out = self.out
		out:pushInline()
		for i, e in ipairs(t) do
			local prefix = i > 1 and " .. " or ""
			if e.etype == "strraw" then
				if e.value:len() > 0 then
					out:append(prefix .. '"' .. e.value .. '"')
				end
			else
				out:append(prefix .. "tostring(")
				for _, v in ipairs(e) do
					self:trExpr(v)
				end
				out:append(")")
			end
		end
		out:popInline()
	end
	-- MARK: Statement
	function __clstype__:trStEqual(t)
		assert(t.stype == "=", "Invalid stype equal")
		assert(#t == 2, "Invalid asign count")
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		for i, v in ipairs(t[1]) do
			if i == 1 then
				if not ctx:isVarDeclared(v, true) then
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
			if e.etype == "lexp" and #e == 1 then
				ctx:localInsert(e[1].value)
			end
		end
	end
	function __clstype__:trStTwoEqual(t)
		local tlen = t.stype:len()
		assert(t.stype:sub(tlen, tlen) == "=", "Invalid stype two equal")
		local ctx = self.ctx
		local out = self.out
		assert(#t == 2, "Invalid asign count")
		out:pushInline()
		ctx:checkName(t[1], true)
		self:trExpr(t[1])
		out:append(" = ")
		self:trExpr(t[1])
		out:append(" " .. t.stype:sub(1, tlen - 1) .. " (")
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
		if #t <= 0 then
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
		elseif t.slib or t.tlib then
			local lt = t[1]
			local rt = t[2]
			if #rt <= 0 then
				rt = lt
			end
			out:append(Utils.seqReduce(lt, "local ", function(init, i, v)
				ctx:localInsert(v.value)
				return init .. (i <= 1 and "" or ", ") .. v.value
			end))
			if t.slib then
				out:append("do")
				out:incIndent()
				out:append("local __lib__ = require(" .. t.slib.value .. ")")
				out:append(Utils.seqReduce(lt, "", function(init, i, v)
					return init .. (i <= 1 and "" or ", ") .. v.value
				end))
				out:append(" = " .. Utils.seqReduce(rt, "", function(init, i, v)
					return init .. (i <= 1 and "__lib__." or ", __lib__.") .. v.value
				end), true)
				out:decIndent()
				out:append("end")
			else
				ctx:checkName(t.tlib, true)
				local tfirst, tnext = t.tlib.value .. ".", ", " .. t.tlib.value .. "."
				out:append(" = " .. Utils.seqReduce(rt, "", function(init, i, v)
					return init .. (i <= 1 and tfirst or tnext) .. v.value
				end), true)
			end
		else
			assert(nil, "Invalid import AST")
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
			if t.op == "*" then
				ctx:localInsert("*")
			else
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
		if name:find(".", 1, true) then
			attr = ""
		end
		ctx:pushScope("fn", t)
		if name:find(":", 1, true) then
			ctx:localInsert("self")
			attr = ""
		end
		out:append(attr .. "function " .. name .. "(" .. Utils.seqReduce(args, "", function(init, i, v)
			ctx:localInsert(v.value)
			return init .. (i > 1 and ", " or "") .. v.value
		end) .. ")")
		out:incIndent()
		ctx:pushOutInfo(out:getInfo())
		if #body > 0 then
			out:changeLine()
			self:trStatement(body)
			if ctx:hasDefers() and body[#body].stype ~= "return" then
				out:append((#t > 0 and ", " or "") .. "__df_run__()")
			end
		end
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	function __clstype__:trStCall(t)
		assert(t.stype == "(", "Invalid stype fn call")
		local ctx = self.ctx
		local out = self.out
		local n = 0
		out:pushInline()
		if t[1].etype == "lvar" then
			n = 1
			ctx:checkName(t[1], true)
			if ctx.in_clsname and t[1].value == "Self" then
				out:append(ctx.in_clsname, true)
			elseif ctx.in_supname and t[1].value == "Super" then
				out:append(ctx.in_supname, true)
			else
				out:append(t[1].value, true)
			end
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
			for _, v in ipairs(t.cond) do
				self:trExpr(v)
			end
			out:popInline()
			out:append(" then", true)
			ctx:pushScope("if", t)
			out:changeLine()
			out:incIndent()
			self:trStatement(t.body)
			ctx:popScope()
			out:decIndent()
		elseif t.stype == "else" then
			ctx:pushScope("if", t)
			out:append("else")
			out:changeLine()
			out:incIndent()
			self:trStatement(t.body)
			out:decIndent()
			ctx:popScope()
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
		out:append("local __sw__ = ")
		out:pushInline()
		for _, v in ipairs(t.cond) do
			self:trExpr(v)
		end
		out:popInline()
		out:changeLine()
		for i = 1, #t do
			local c = t[i]
			out:pushInline()
			if c.stype == "case" then
				if i == 1 then
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
	function __clstype__:trStGuard(t)
		assert(t.stype == "guard", "Invalid stype guard")
		local ctx = self.ctx
		local out = self.out
		local body = t.body
		local bt = body[#body]
		if #body <= 0 or not (bt.stype == "return" or bt.stype == "goto" or bt.stype == "break" or bt.stype == "continue") then
			ctx:errorPos("guard statement need return/goto/break/continue at last", "guard", t.pos - 1)
			return 
		end
		out:append("if not (")
		out:pushInline()
		for _, v in ipairs(t.cond) do
			self:trExpr(v)
		end
		out:append(") then", true)
		out:popInline()
		out:changeLine()
		out:incIndent()
		ctx:pushScope("gu", t)
		self:trStatement(body)
		ctx:popScope()
		out:decIndent()
		out:append("end")
	end
	function __clstype__:trStFor(t)
		assert(t.stype == "for", "Invalid stype for")
		local list = t.list
		local staments = t.body
		local ctx = self.ctx
		local out = self.out
		ctx:pushScope("lo", t)
		out:pushInline()
		out:append("for ")
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
				if i == #list then
					out:append(" in ")
				elseif i > 1 then
					out:append(", ")
				end
				if i == #list then
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
				if i ~= #list then
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
		ctx:popScope()
	end
	function __clstype__:trStWhile(t)
		assert(t.stype == "while", "Invalid stype while")
		local ctx = self.ctx
		local out = self.out
		ctx:pushScope("lo", t)
		out:append("while ")
		out:pushInline()
		for _, v in ipairs(t.cond) do
			self:trExpr(v)
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
	function __clstype__:trStRepeat(t)
		assert(t.stype == "repeat", "Invalid repeat op")
		local ctx = self.ctx
		local out = self.out
		ctx:pushScope("lo", t)
		out:append("repeat")
		out:changeLine()
		out:incIndent()
		self:trStatement(t.body)
		out:decIndent()
		out:append("until ")
		out:pushInline()
		for _, v in ipairs(t.cond) do
			self:trExpr(v)
		end
		out:popInline()
		ctx:popScope()
	end
	function __clstype__:trStBreak(t)
		assert(t.stype == "break", "Invalid stype break")
		local ctx = self.ctx
		local out = self.out
		if not ctx:isInLoop() then
			ctx:errorPos("not in loop", t.stype, t.pos - 1)
			return 
		end
		out:append("break")
	end
	function __clstype__:trStContinue(t)
		assert(t.stype == "continue", "Invalid continue op")
		local ctx = self.ctx
		local out = self.out
		if not ctx:isInLoop() then
			ctx:errorPos("not in loop", t.stype, t.pos - 1)
			return 
		end
		local scope = ctx:getScope("lo")
		if scope and scope.exp and scope.exp.body then
			local label = "__continue" .. tostring(scope.loidx) .. "__"
			out:append("goto " .. label)
			local le = scope.exp.body
			local v = le[#le]
			if v.stype == "return" or v.stype == "break" then
				ctx:errorPos("try do { " .. v.stype .. " } for continue will insert label after", v.stype, v.pos - 1)
			elseif #le == 0 or le[#le].stype ~= "raw" or le[#le].sub ~= "continue" then
				le[#le + 1] = { ["stype"] = "raw", ["sub"] = "continue", "::" .. label .. "::" }
			end
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
		if ctx:hasDefers() then
			out:append((#t > 0 and ", " or "") .. "__df_run__()")
		end
		out:popInline()
	end
	function __clstype__:trStDefer(t)
		assert(t.stype == "defer", "Invalid stype defer")
		local ctx = self.ctx
		local out = self.out
		if not ctx:supportDefer() then
			ctx:errorPos("not in function", t.stype, t.pos)
			return 
		end
		if not ctx:hasDefers() then
			ctx:pushDefer()
			local info = ctx:getOutInfo("fn")
			if info then
				out:appendExt(info, { "local __df_fns__ = {}", "local __df_run__ = function() local t=__df_fns__; for i=#t, 1, -1 do t[i]() end; end" })
			end
		end
		if not ctx.in_defer then
			ctx.in_defer = true
			out:append("__df_fns__[#__df_fns__ + 1] = function()")
			out:changeLine()
			out:incIndent()
			ctx:pushScope("df")
			self:trStatement(t.body)
			ctx:popScope()
			out:decIndent()
			out:append("end")
			ctx.in_defer = false
		end
	end
	function __clstype__:trStDo(t)
		assert(t.stype == "do", "Invalid stype do end")
		local ctx = self.ctx
		local out = self.out
		ctx:pushScope("do")
		out:append("do")
		out:changeLine()
		out:incIndent()
		self:trStatement(t.body)
		out:decIndent()
		out:append("end")
		ctx:popScope()
	end
	-- generated by compiler 1st pass
	function __clstype__:trStRaw(t)
		assert(t.stype == "raw", "Invalid stype raw")
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
		ctx.in_clsname = clsname
		ctx.in_supname = supertype or false
		if t.attr == "export" then
			ctx:globalInsert(clsname)
		else
			ctx:localInsert(clsname)
		end
		if supertype then
			ctx:checkName(t.super, true)
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
		out:append("__clstype__.typename = __clsname__")
		out:append("__clstype__.typekind = 'class'")
		out:append("__clstype__.classtype = __clstype__")
		out:append("__clstype__.supertype = __stype__")
		if not supertype then
			out:append("__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end")
		end
		--
		ctx:pushScope("cl")
		ctx:localInsert("Self")
		if ctx.in_supname then
			ctx:localInsert("Super")
		end
		local cls_fns, ins_fns = {  }, {  }
		local fn_init, fn_deinit = self:hlVarAndFns(t, "__clstype__", ctx, out, cls_fns, ins_fns)
		--
		out:append("local __ins_mt__ = {")
		out:incIndent()
		out:append('__tostring = function() return "instance of " .. __clsname__ end,')
		out:append("__index = function(t, k)")
		out:incIndent()
		out:append("local v = __clstype__[k]")
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
		--
		out:append("setmetatable(__clstype__, {")
		out:incIndent()
		out:append('__tostring = function() return "class " .. __clsname__ end,')
		out:append('__index = function(_, k)')
		out:incIndent()
		out:append('local v = __stype__ and __stype__[k]')
		out:append('if v ~= nil then rawset(__clstype__, k, v) end')
		out:append('return v')
		out:decIndent()
		out:append('end,')
		out:append("__call = function(_, ...)")
		out:incIndent()
		out:append("local ins = setmetatable({}, __ins_mt__)")
		if fn_deinit then
			out:append('if _VERSION == "Lua 5.1" then')
			out:incIndent()
			out:append("rawset(ins, '__gc_proxy', newproxy(true))")
			out:append("getmetatable(ins.__gc_proxy).__gc = function() ins:deinit() end")
			out:decIndent()
			out:append("end")
		end
		if fn_init then
			out:append("if ins:init(...) == false then return nil end")
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
		--
		out:decIndent()
		out:append("end")
		ctx:popScope()
		ctx.in_clsname = false
		ctx.in_supname = false
	end
	function __clstype__:trStStruct(t)
		assert(t.stype == "struct", "Invalid stype struct")
		local ctx = self.ctx
		local out = self.out
		local attr = (t.attr == "export") and "" or "local "
		local strname = t.name.value
		ctx.in_clsname = strname
		if t.attr == "export" then
			ctx:globalInsert(strname)
		else
			ctx:localInsert(strname)
		end
		out:append(attr .. strname .. " = {}")
		out:append("do")
		out:changeLine()
		out:incIndent()
		out:append('local __clsname__ = "' .. strname .. '"')
		out:append("local __clstype__ = " .. strname)
		out:append("__clstype__.typename = __clsname__")
		out:append("__clstype__.typekind = 'struct'")
		out:append("__clstype__.classtype = __clstype__")
		--
		ctx:pushScope("cl")
		ctx:localInsert("Self")
		local cls_fns, ins_fns = {  }, {  }
		local fn_init, fn_deinit = self:hlVarAndFns(t, "__clstype__", ctx, out, cls_fns, ins_fns)
		--
		out:append("local __ins_mt__ = {")
		out:incIndent()
		out:append('__tostring = function() return "one of " .. __clsname__ end,')
		out:append("__index = function(t, k)")
		out:incIndent()
		out:append("local v = rawget(__clstype__, k)")
		out:append("if v ~= nil then rawset(t, k, v) end")
		out:append("return v")
		out:decIndent()
		out:append("end,")
		out:append("__newindex = function(t, k, v) if rawget(__clstype__, k) ~= nil then rawset(t, k, v) end end,")
		if fn_deinit then
			out:append("__gc = function(t) t:deinit() end,")
		end
		for _, e in ipairs(ins_fns) do
			out:append(e.name.value .. " = function(")
			self:hlFnArgsBody(e, false, true)
		end
		out:decIndent()
		out:append("}")
		--
		out:append(strname .. " = setmetatable({}, {")
		out:incIndent()
		out:append('__tostring = function() return "struct " .. __clsname__ end,')
		out:append('__index = function(_, k) return rawget(__clstype__, k) end,')
		out:append('__newindex = function(_, k, v) if v ~= nil and rawget(__clstype__, k) ~= nil then rawset(__clstype__, k, v) end end,')
		out:append("__call = function(_, ...)")
		out:incIndent()
		out:append("local ins = setmetatable({}, __ins_mt__)")
		if fn_init then
			out:append("if ins:init(...) == false then return nil end")
		end
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
		--
		out:decIndent()
		out:append("end")
		ctx:popScope()
		ctx.in_clsname = false
	end
	function __clstype__:trStExtension(t)
		assert(t.stype == "extension", "Invalid stype extension")
		local ctx = self.ctx
		local out = self.out
		local clsname = t.name.value
		local extype = t.extend and t.extend.value
		ctx.in_clsname = clsname
		ctx:checkName(t.name, true)
		if extype then
			ctx:checkName(t.extend, true)
		end
		out:append("do")
		out:changeLine()
		out:incIndent()
		out:append("local __extype__ = " .. (extype or "nil"))
		out:append("local __clstype__ = " .. clsname)
		out:append('assert(type(__clstype__) == "table" and type(__clstype__.classtype) == "table")')
		out:append("__clstype__ = __clstype__.classtype")
		if extype then
			-- extype can be class or struct
			out:append('assert(type(__extype__) == "table" and type(__extype__.classtype) == "table")')
			out:append('for k, v in pairs(__extype__.classtype) do')
			out:incIndent()
			out:append('if __clstype__[k] == nil and k:sub(1, 2) ~= "__" and k ~= "supertype" and k ~= "isKindOf" then')
			out:incIndent()
			out:append('__clstype__[k] = v')
			out:decIndent()
			out:append("end")
			out:decIndent()
			out:append("end")
		end
		--
		ctx:pushScope("cl")
		ctx:localInsert("Self")
		self:hlVarAndFns(t, "__clstype__", ctx, out, {  }, {  })
		out:decIndent()
		out:append("end")
		ctx:popScope()
		ctx.in_clsname = false
	end
	function __clstype__:hlVarAndFns(t, sname, ctx, out, cls_fns, ins_fns)
		out:append("-- declare struct var and methods")
		out:changeLine()
		local fn_init = false
		local fn_deinit = false
		for _, e in ipairs(t) do
			local stype = e.stype
			if stype == "=" then
				ctx.in_clsvar = true
				out:append(sname .. ".")
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
				if fn_name == "init" then
					fn_init = true
				elseif fn_name == "deinit" then
					fn_deinit = true
				end
				local fn_ins = e.attr ~= "static"
				if _cls_metafns[fn_name] then
					if fn_ins then
						ins_fns[#ins_fns + 1] = e
					else
						cls_fns[#cls_fns + 1] = e
					end
				else
					out:append("function " .. sname .. (fn_ins and ":" or ".") .. fn_name .. "(")
					self:hlFnArgsBody(e, fn_ins)
				end
			elseif stype == "cm" then
				self:trStComment(e)
			end
		end
		out:append("-- declare end")
		return fn_init, fn_deinit
	end
	function __clstype__:hlFnArgsBody(e, fn_ins, comma_end)
		local ctx = self.ctx
		local out = self.out
		out:pushInline()
		ctx:pushScope("fn", e)
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
		out:incIndent()
		out:popInline()
		out:changeLine()
		ctx:pushOutInfo(out:getInfo())
		self:trStatement(e.body)
		out:decIndent()
		out:append("end" .. (comma_end and "," or ""))
		out:changeLine()
		ctx:popScope()
	end
	-- declare end
	local __ins_mt__ = {
		__tostring = function() return "one of " .. __clsname__ end,
		__index = function(t, k)
			local v = rawget(__clstype__, k)
			if v ~= nil then rawset(t, k, v) end
			return v
		end,
		__newindex = function(t, k, v) if rawget(__clstype__, k) ~= nil then rawset(t, k, v) end end,
	}
	M = setmetatable({}, {
		__tostring = function() return "struct " .. __clsname__ end,
		__index = function(_, k) return rawget(__clstype__, k) end,
		__newindex = function(_, k, v) if v ~= nil and rawget(__clstype__, k) ~= nil then rawset(__clstype__, k, v) end end,
		__call = function(_, ...)
			local ins = setmetatable({}, __ins_mt__)
			if ins:init(...) == false then return nil end
			return ins
		end,
	})
end
--[[
    config as { fname : "filename", shebang : false }    
    data as { content : CONTENT, ast : AST_TREE }
]]
local function compile(config, data)
	if not (type(data) == "table" and data.ast and data.content) then
		return false, "Invalid data"
	end
	local ctx = Ctx(config, data.ast, data.content)
	local out = Out()
	local comp = M(ctx, out)
	comp:trStatement(ctx.ast)
	if ctx:hasError() then
		return false, ctx.err_info
	end
	return true, table.concat(out._output, "\n")
end
-- clear proj exports
local function clearproj()
	_scope_proj.vars = {  }
end
return { compile = compile, clearproj = clearproj }
