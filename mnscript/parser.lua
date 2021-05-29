--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local P, R, S, V, C, Cb, Cf, Cg, Cp, Ct, Cmt
do
	local __lib__ = require("lpeg")
	P, R, S, V, C, Cb, Cf, Cg, Cp, Ct, Cmt = __lib__.P, __lib__.R, __lib__.S, __lib__.V, __lib__.C, __lib__.Cb, __lib__.Cf, __lib__.Cg, __lib__.Cp, __lib__.Ct, __lib__.Cmt
end
local fType, fSetmaxstack
do
	local __lib__ = require("lpeg")
	fType, fSetmaxstack = __lib__.type, __lib__.setmaxstack
end
local fSet, fSplit, fTrim
do
	local __lib__ = require("mnscript.utils")
	fSet, fSplit, fTrim = __lib__.set, __lib__.split, __lib__.trim
end
fSetmaxstack(10240)
-- remove keyword pattern
local kwTableR = fSet({ "and", "break", "case", "class", "continue", "default", "defer", "do", "else", "elseif", "end", "export", "fn", "for", "from", "function", "goto", "guard", "if", "import", "in", "local", "not", "or", "repeat", "return", "switch", "then", "until", "while", "...", ".." })
local kwTableL = fSet({ "false", "nil", "true" })
local function fNoKWL(s, p, c)
	local list = fSplit(c, "[%.]", nil, true)
	for _, v in ipairs(list) do
		if kwTableL[v] or kwTableR[v] then
			return false
		end
	end
	return true, { etype = "lvar", value = c, pos = p, list = (#list > 1 and list or nil) }
end

local function fNoKWR(s, p, c)
	local list = fSplit(c, "[%.:]", nil, true)
	for _, v in ipairs(list) do
		if kwTableR[v] then
			return false
		end
	end
	return true, { etype = "rvar", value = c, pos = p, list = (#list > 1 and list or nil) }
end

local function fMarkStype(stype)
	return function(s, p, c)
		return p, { pos = p, value = c, stype = stype }
	end
end

local function fMarkEtype(type)
	return function(s, p, c)
		return p, { pos = p, value = c, etype = type }
	end
end

-- MARK: pattern
local last_pos = 0
local cur_pos = 0
local pBlank = Cmt(S(" \t\r\n"), function(s, p, c)
	if p > last_pos then
		last_pos = p
	end
	cur_pos = p
	return true
end)
local pBlanks = pBlank ^ 0
local pAlphaNum = R("az", "AZ", "__") * R("az", "AZ", "09", "__") ^ 0
local pVarLeft = Cmt(pAlphaNum * (P(".") ^ -1 * pAlphaNum) ^ 0, fNoKWL)
local pVarRight = Cmt(pAlphaNum, fNoKWR)
local pVarArg = Cmt(pAlphaNum, fNoKWL)
local pVArgList = Cmt("...", fMarkEtype("varg"))
local pNumber = Cmt(P("0x") * R("09", "af", "AF") ^ 1 * (S("uU") ^ -1 * S("lL") ^ 2) ^ -1 + R("09") ^ 1 * (S("uU") ^ -1 * S("lL") ^ 2) + (R("09") ^ 1 * (P(".") * R("09") ^ 1) ^ -1 + P(".") * R("09") ^ 1) * (S("eE") * P("-") ^ -1 * R("09") ^ 1) ^ -1, function(s, p, c)
	return p, { etype = "number", pos = p, value = c }
end)
local pComma = pBlanks * P(",") * pBlanks
local pEqual = P("=")
local pColon = P(":")
local pSemi = P(';')
local pPLeft = pBlanks * P("(") * pBlanks
local pPRight = pBlanks * P(")") * pBlanks
local pBLeft = pBlanks * P("{") * pBlanks
local pBRight = pBlanks * P("}") * pBlanks
local pSLeft = pBlanks * P("[") * pBlanks
local pSRight = pBlanks * P("]") * pBlanks
local pCPLeft = pBlanks * Cmt("(", function(s, p, c)
	return p, { etype = "op", pos = p, value = c }
end) * pBlanks
local pCPRight = pBlanks * Cmt(")", function(s, p, c)
	return p, { etype = "op", pos = p, value = c }
end) * pBlanks
local function fSymPatt(prefix, pa, pb)
	local name = "name" .. pa
	local sopen = nil
	if prefix then
		sopen = (prefix .. pa) * Cg(pEqual ^ 0, name) * pa
	else
		sopen = pa * Cg(pEqual ^ 0, name) * pa
	end
	local sclose = pb * C(pEqual ^ 0) * pb
	local scloseeq = Cmt(sclose * Cb(name), function(s, i, a, b)
		return a == b
	end)
	return C(sopen * (P(1) - scloseeq) ^ 0 * sclose) / 1
end

local function fStrPatt(str)
	local m1 = S(str)
	return Cg(m1 * (P("\\\\") + P("\\" .. str) + (1 - m1 - P("\n"))) ^ 0 * m1)
end

local pCmShort = P("--") * (P(1) - S("\r\n")) ^ 0
local pCmLong = fSymPatt("--", "[", "]")
local pStrDot = fStrPatt("'")
local pStrQuote = fStrPatt('"')
local pStr = Cmt(pStrDot + pStrQuote + fSymPatt(nil, "[", "]"), function(s, p, c)
	return p, { etype = "string", pos = p, value = c }
end)
local function fNotCm(s, p, c)
	local ret = s:sub(p, p + 1) == "--" or s:sub(p - 1, p) == "--"
	return not ret, c
end

local function fConj(p, j)
	return p * #j
end

local pSingleOp = Cmt(fConj(P("not"), pBlank) + Cmt("-", fNotCm) + P("#") + P("~"), function(s, p, c)
	return p, { etype = "op", pos = p, value = c }
end)
local pTwoOp = P("*=") + P("/=") + P("%=") + P("+=") + P("-=") + P("..=") + P("or=") + P("and=") + P("^=")
local pOperator = Cmt(P("//") + S("*/%") + P("+") + Cmt("-", fNotCm) + P("^") + P("..") + P(">>") + P("<<") + P("<=") + P(">=") + P("~=") + P("==") + S("><") + fConj(P("and"), pBlank) + fConj(P("or"), pBlank) + P("!="), function(s, p, c)
	return p, { etype = "op", pos = p, value = c, sub = "p" }
end)
local function fName(n)
	return C("") / function()
		return n
	end
end

-- MARK: grammar
local vFile, vShebang, vFnSMT, vClsDef, vClsBody, vClsAsSMT, vClsFnDef, vTbDef, vTbKV, vTbNk, vTbVk, vTbBk, vTbVal, vFnDefKW, vFnDefArg, vFnDefVArg, vFnDefArgs, vFnDefBody, vFnDefName, vFnDefOnly, vFnClosure, vFnCall, vImSMT, vImLib, vImRight, vExSMT, vExLeft, vAsSMT, vAsLeft, vAsRight, vAswSMT, vIfSMT, vElseIfSMT, vElseSMT, vSwSMT, vSwCaSMT, vSwDeSMT, vGuardSMT, vForSMT, vForVar, vForNext, vForList, vRptSMT, vWhileSMT, vBrkSMT, vCntSMT, vGoSMT, vRetSMT, vDeferSMT, vBlkSMT, vCmSMT, vDotExpr, vParaExpr, vSquareExpr, vColonExpr, vEvalExpr, vEvalLeft, vClsOpUnit, vClsExpr, vOpUnit, vExpr = V("vFile"), V("vShebang"), V("vFnSMT"), V("vClsDef"), V("vClsBody"), V("vClsAsSMT"), V("vClsFnDef"), V("vTbDef"), V("vTbKV"), V("vTbNk"), V("vTbVk"), V("vTbBk"), V("vTbVal"), V("vFnDefKW"), V("vFnDefArg"), V("vFnDefVArg"), V("vFnDefArgs"), V("vFnDefBody"), V("vFnDefName"), V("vFnDefOnly"), V("vFnClosure"), V("vFnCall"), V("vImSMT"), V("vImLib"), V("vImRight"), V("vExSMT"), V("vExLeft"), V("vAsSMT"), V("vAsLeft"), V("vAsRight"), V("vAswSMT"), V("vIfSMT"), V("vElseIfSMT"), V("vElseSMT"), V("vSwSMT"), V("vSwCaSMT"), V("vSwDeSMT"), V("vGuardSMT"), V("vForSMT"), V("vForVar"), V("vForNext"), V("vForList"), V("vRptSMT"), V("vWhileSMT"), V("vBrkSMT"), V("vCntSMT"), V("vGoSMT"), V("vRetSMT"), V("vDeferSMT"), V("vBlkSMT"), V("vCmSMT"), V("vDotExpr"), V("vParaExpr"), V("vSquareExpr"), V("vColonExpr"), V("vEvalExpr"), V("vEvalLeft"), V("vClsOpUnit"), V("vClsExpr"), V("vOpUnit"), V("vExpr")
local gG = { vFile, vFile = vShebang ^ -1 * vFnSMT ^ 0, vFnSMT = (vBrkSMT + vCntSMT + vCmSMT + vClsDef + vFnDefName + vIfSMT + vSwSMT + vForSMT + vRptSMT + vWhileSMT + vRetSMT + vGoSMT + vAsSMT + vFnCall + vAswSMT + vExSMT + vImSMT + vDeferSMT + vBlkSMT + vGuardSMT) * Cmt(pSemi * pBlanks / fTrim, fMarkStype(";")) ^ -1, --
vShebang = Ct(Cg("#!", "stype") * C(P(1 - (P("\r") ^ -1 * P("\n"))) ^ 0)), --
vClsDef = pBlanks * Ct(Cg(P("local") + P("export"), "attr") ^ -1 * pBlanks * Cg(P("class"), "stype") * pBlanks * Cg(pVarArg, "name") * pBlanks * (pColon * pBlanks * Cg(pVarArg, "super")) ^ -1 * vClsBody), vClsBody = pBlanks * pBLeft * (vCmSMT + vClsAsSMT + vClsFnDef) ^ 0 * pBRight * pBlanks, vClsAsSMT = pBlanks * Ct(pVarArg * pBlanks * Cg(pEqual, "stype") * pBlanks * vClsExpr) * pBlanks, vClsFnDef = Ct(Cg("class", "attr") ^ -1 * vFnDefKW * Cg(pVarArg, "name") * pPLeft * Cg(vFnDefArgs, "args") ^ 0 * pPRight * Cg(vFnDefBody, "body")), --
vExSMT = pBlanks * Ct(Cg(fName("ex"), "stype") * Cg(P("local") + P("export"), "attr") * vExLeft * (Cg(pEqual, "op") * vAsRight) ^ 0) * pBlanks, vExLeft = pBlanks * Ct(pVarArg * pBlanks * (pComma * pBlanks * pVarArg) ^ 0) * pBlanks, --
vImSMT = pBlanks * Ct(Cg(P("import"), "stype") * pBlanks * (Cg(pStr, "slib") + vExLeft * P("from") * vImLib * Ct(pBLeft * vImRight ^ -1 * pBRight) ^ -1)) * pBlanks, vImLib = pBlanks * (Cg(pStr, "slib") + Cg(pVarLeft, "tlib")) * pBlanks, vImRight = pVarLeft * (pBlanks * pComma * pBlanks * pVarLeft) ^ 0, --
vAsSMT = Ct(vAsLeft * Cg(pEqual, "stype") * vAsRight), vAsLeft = pBlanks * Ct(vEvalLeft * pBlanks * (pComma * pBlanks * vEvalLeft) ^ 0) * pBlanks, vAsRight = pBlanks * Ct(Ct(vExpr) * pBlanks * (pComma * pBlanks * Ct(vExpr)) ^ 0) * pBlanks, vAswSMT = pBlanks * Ct(vEvalLeft * pBlanks * Cg(pTwoOp, "stype") * pBlanks * Ct(vExpr)) * pBlanks, --
vTbDef = Ct(Cg(pBLeft / fTrim, "etype") * (vTbKV * pBlanks * (pComma * pBlanks * vTbKV * pBlanks) ^ 0 * (pComma + vCmSMT) ^ -1) ^ -1 * pBRight), vTbKV = vCmSMT ^ -1 * Ct(vTbNk + vTbVk * vTbVal + vTbBk * vTbVal + vTbVal), vTbNk = pBlanks * pColon * pBlanks * Cg(pVarArg, "nkey"), vTbVk = pBlanks * Cg(pVarArg, "vkey") * pBlanks * pColon, vTbBk = Cg(vExpr, "bkey") * pColon, vTbVal = pBlanks * Cg(Ct(vExpr), "value"), --
vFnDefKW = pBlanks * Cg(P("fn"), "stype") * pBlanks, vFnDefArg = pBlanks * Cg(pVarArg) * pBlanks, vFnDefVArg = pBlanks * Cg(pVArgList) * pBlanks, vFnDefArgs = Ct((vFnDefArg * pComma) ^ 0 * vFnDefVArg + vFnDefArg * (pComma * vFnDefArg) ^ 0), vFnDefBody = pBLeft * Ct(vFnSMT ^ 0) * pBRight, vFnDefName = pBlanks * Ct(Cg(P("local") + P("export"), "attr") ^ -1 * vFnDefKW * Cg(pVarLeft, "name") * pPLeft * Cg(vFnDefArgs, "args") ^ -1 * pPRight * Cg(vFnDefBody, "body")), --    
vFnDefOnly = pBlanks * Ct(Cg(P("fn"), "etype") * pPLeft * Cg(vFnDefArgs, "args") ^ -1 * pPRight * Cg(vFnDefBody, "body")), vFnClosure = pBLeft * Ct(Cg(fName("fn"), "etype") * Cg(vFnDefArgs, "args") ^ -1 * pBlanks * P("in") * pBlanks * Cg(Ct(vFnSMT ^ 0), "body")) * pBRight, --
vFnCall = pBlanks * Ct(Cg(fName("("), "stype") * (pVarArg + pCPLeft * vExpr * pCPRight) * ((vDotExpr + vSquareExpr) ^ 0 * (vColonExpr + vParaExpr)) ^ 1), --
vIfSMT = pBlanks * Ct(Cg(P("if"), "stype") * pBlanks * Cg(Ct(vExpr), "cond") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body")) * vElseIfSMT ^ 0 * vElseSMT ^ -1 * Cmt(pBRight / fTrim, fMarkStype("ifend")), vElseIfSMT = pBRight * Ct(Cg(P("elseif"), "stype") * pBlanks * Cg(Ct(vExpr), "cond") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body")), vElseSMT = pBRight * Ct(Cg(P("else"), "stype") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body")), --
vSwSMT = pBlanks * Ct(Cg(P("switch"), "stype") * pBlanks * Cg(Ct(vExpr), "cond") * pBlanks * pBLeft * vSwCaSMT ^ 1 * vSwDeSMT ^ -1 * pBRight), vSwCaSMT = pBlanks * Ct(Cg(P("case"), "stype") * pBlanks * Ct(vExpr) * (pBlanks * pComma * pBlanks * Ct(vExpr)) ^ 0 * pBlanks * pColon * Cg(Ct(vFnSMT ^ 0), "body")), vSwDeSMT = pBlanks * Ct(Cg(P("default"), "stype") * pBlanks * pColon * Cg(Ct(vFnSMT ^ 0), "body")), --
vGuardSMT = pBlanks * Ct(Cg(P("guard"), "stype") * Cg(Cp(), "pos") * pBlanks * Cg(Ct(vExpr), "cond") * pBlanks * P("else") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body")) * pBRight, --
vForSMT = pBlanks * Ct(Cg(P("for"), "stype") * Cg(Ct(vForVar * vForNext + vForList), "list") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body") * pBRight), vForVar = pBlanks * Cg(pVarArg) * pBlanks * Cg(pEqual, "sub") * pBlanks * Ct(vExpr) * pBlanks * pComma, vForNext = pBlanks * Ct(vExpr) * pBlanks * (pComma * pBlanks * Ct(vExpr)) ^ -1 * pBlanks, vForList = pBlanks * Cg(pVarArg) * pBlanks * (pComma * pBlanks * Cg(pVarArg)) ^ 0 * pBlanks * Cg(P("in"), "sub") * pBlanks * Ct(Ct(vExpr) * pBlanks * (pComma * Ct(vExpr)) ^ -2) * pBlanks, --
vRptSMT = pBlanks * Ct(Cg(P("repeat"), "stype") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body") * pBRight * P("until") * pBlanks * Cg(Ct(vExpr), "cond")) * pBlanks, vWhileSMT = pBlanks * Ct(Cg(P("while"), "stype") * pBlanks * Cg(Ct(vExpr), "cond") * pBlanks * pBLeft * Cg(Ct(vFnSMT ^ 0), "body") * pBRight), --
vBrkSMT = pBlanks * Cmt("break", fMarkStype("break")) * pBlanks, vCntSMT = pBlanks * Cmt("continue", fMarkStype("continue")) * pBlanks, vGoSMT = pBlanks * Ct(Cg("goto", "stype") * pBlanks * Cg(pVarArg, "name") + Cg(P("::"), "stype") * pBlanks * Cg(pVarArg, "name") * pBlanks * P("::")) * pBlanks, --
vRetSMT = pBlanks * Ct(Cg("return", "stype") * (pBlanks * Ct(vExpr) * pBlanks * (pComma * pBlanks * Ct(vExpr) * pBlanks) ^ 0) ^ 0) * pBlanks * (#pBRight + #P("case") + #P("default") + -1), vDeferSMT = pBlanks * Ct(Cg("defer", "stype") * Cg(Cp(), "pos") * pBLeft * Cg(Ct(vFnSMT ^ 0), "body")) * pBRight, vBlkSMT = pBlanks * Ct(Cg("do", "stype") * pBLeft * Cg(Ct(vFnSMT ^ 1), "body") * pBRight) * pBlanks, --
vCmSMT = pBlanks * Cmt(pCmLong + pCmShort, fMarkStype("cm")) * pBlanks, --
vDotExpr = Ct(Cg(P("."), "op") * pVarArg), vParaExpr = Ct(Cg(pPLeft / fTrim, "op") * (pBlanks * Ct(vExpr) * (pBlanks * pComma * pBlanks * Ct(vExpr)) ^ 0) ^ 0 * pPRight), vSquareExpr = Ct(Cg(pSLeft / fTrim, "op") * vExpr * pSRight), vColonExpr = Ct(Cg(P(":"), "op") * pVarArg * vParaExpr), vEvalExpr = pBlanks * Ct(Cg(fName("rexp"), "etype") * pVarRight * (vDotExpr + vColonExpr + vSquareExpr + vParaExpr) ^ 0), vEvalLeft = pBlanks * Ct(Cg(fName("lexp"), "etype") * pVarArg * ((vColonExpr + vParaExpr) ^ 0 * (vDotExpr + vSquareExpr)) ^ 0), --
vClsOpUnit = pBlanks * (pSingleOp * vOpUnit + vTbDef + pStr + pNumber + pVArgList + vEvalExpr) * pBlanks, vClsExpr = pCPLeft * vClsExpr * pCPRight * (pOperator * vClsExpr) ^ 0 + vClsOpUnit * (pOperator * vClsExpr) ^ 0, --
vOpUnit = pBlanks * (pSingleOp * vOpUnit + vTbDef + vFnDefOnly + vFnClosure + pStr + pNumber + pVArgList + vEvalExpr) * pBlanks, vExpr = pCPLeft * vExpr * pCPRight * (pOperator * vExpr + vParaExpr) ^ 0 + vOpUnit * (pOperator * vExpr) ^ 0 }
local grammar = Cf(Ct("") * gG * -1, function(a, b)
	a[#a + 1] = b
	return a
end)
assert(fType(grammar) == "pattern")
-- return true, { content = CONTENT, ast = AST }
-- return false, { content = CONTENT, pos = POSITION }
local function parse(content)
	last_pos = 0
	cur_pos = 0
	local t = grammar:match(content)
	if t == nil then
		return false, { content = content, lpos = last_pos, cpos = cur_pos }
	else
		return true, { content = content, ast = t }
	end
end

return { parse = parse }
