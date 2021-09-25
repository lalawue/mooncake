--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local LPeg = require("lpeg")
local parse
do
	local __lib__ = require("moocscript.parser")
	parse = __lib__.parse
end
local compile, clearproj
do
	local __lib__ = require("moocscript.compile")
	compile, clearproj = __lib__.compile, __lib__.clearproj
end
local split, posLine, readFile
do
	local __lib__ = require("moocscript.utils")
	split, posLine, readFile = __lib__.split, __lib__.posLine, __lib__.readFile
end
local concat, insert, remove = table.concat, table.insert, table.remove
unpack, assert = unpack or table.unpack, assert
type, error, load, loadstring = type, error, load, loadstring
jit = jit
local sfmt = string.format
-- source to AST
local function toAST(config, text)
	local t = type(text)
	if t ~= "string" then
		return nil, "expecting string (got " .. t .. ")"
	end
	config = config or {  }
	local ret, tbl = parse(text)
	if not ret then
		local err = posLine(tbl.content, tbl.lpos, tbl.cpos)
		local msg = sfmt("parse error %s:%d: %s", config.fname, err.line, err.message)
		return nil, msg
	end
	return tbl
end
-- translate to Lua
local function toLua(config, tbl)
	local ret, code = compile(config, tbl)
	if not ret then
		return nil, code
	end
	return code
end
-- directory separator
local dir_spliter = package.config and package.config[1] or '/'
local tmp_config = {  }
-- register loader
local function mcLoader(name)
	local name_path = name:gsub("%.", dir_spliter)
	local text, file_path = nil, nil
	for path in package.path:gmatch("[^;]+") do
		local len = path:len()
		path = path:sub(1, len - 4) .. ".mooc"
		file_path = path:gsub("?", name_path)
		text = readFile(file_path)
		if text then
			break
		end
	end
	if not (text) then
		return nil, "Could not find .mooc file"
	end
	tmp_config.fname = file_path
	local res, emsg = toAST(tmp_config, text)
	if not res then
		error(emsg)
	end
	res, emsg = toLua(tmp_config, res)
	if not res then
		error(emsg)
	end
	local f, err = load(res, file_path)
	return f
end
local function mcLoadString(text, cname, mode, env)
	tmp_config.fname = cname
	local res, emsg = toAST(tmp_config, text)
	if not res then
		return emsg
	end
	res, emsg = toLua(tmp_config, res)
	if not res then
		return emsg
	end
	local f = (loadstring or load)
	return f(res, cname, unpack({ ["mode"] = mode, ["env"] = env }))
end
local function mcLoadFile(fname, ...)
	local text, err = readFile(fname)
	if not (text) then
		return nil, err
	end
	return mcLoadString(text, fname, ...)
end
local function mcDoFile(...)
	local f = assert(mcLoadFile(...))
	return f()
end
local function mcRemoveLoader()
	if not (package.mooc_loaded) then
		return 
	end
	local loaders = package.loaders or package.searchers
	for i = #loaders, 1, -1 do
		if package.mooc_loaded == loaders[i] then
			remove(loaders, i)
			package.mooc_loaded = nil
			return true
		end
	end
end
local function mcAppendLoader()
	if package.mooc_loaded then
		return 
	end
	local loaders = package.loaders or package.searchers
	insert(loaders, mcLoader)
	package.mooc_loaded = mcLoader
end
local function mcVersion()
	local lver = jit and jit.version or _VERSION
	local pver = type(LPeg.version) == "function" and ("LPeg " .. LPeg.version()) or LPeg.version
	return "moocscript v0.4.20210901, " .. lver .. ", " .. pver
end
local function mcLoaded()
	return package.mooc_loaded ~= nil
end
-- append loader
mcAppendLoader()
return { ["loadstring"] = mcLoadString, ["loadfile"] = mcLoadFile, ["dofile"] = mcDoFile, ["removeloader"] = mcRemoveLoader, ["appendloader"] = mcAppendLoader, ["toAST"] = toAST, ["toLua"] = toLua, ["clearProj"] = clearproj, ["version"] = mcVersion, ["loaded"] = mcLoaded }
