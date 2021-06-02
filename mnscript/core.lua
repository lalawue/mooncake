--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local parse
do
	local __lib__ = require("mnscript.parser")
	parse = __lib__.parse
end
local compile
do
	local __lib__ = require("mnscript.compile")
	compile = __lib__.compile
end
local split, posLine
do
	local __lib__ = require("mnscript.utils")
	split, posLine = __lib__.split, __lib__.posLine
end
local concat, insert, remove
do
	local __lib__ = table
	concat, insert, remove = __lib__.concat, __lib__.insert, __lib__.remove
end
unpack = unpack or table.unpack
-- mn source to AST
local function toAST(config, text)
	local t = type(text)
	if t ~= "string" then
		return nil, "expecting string (got " .. t .. ")"
	end
	config = config or {  }
	local ret, tbl = parse(text)
	if not ret then
		local err = posLine(tbl.content, tbl.lpos, tbl.cpos)
		local msg = string.format("parse error %s:%d: %s", config.fname, err.line, err.message)
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
local all_option = _VERSION == "Lua 5.1" and "*a" or "a"
local tmp_config = {  }
-- register ?.mn loader
local function mnLoader(name)
	local name_path = name:gsub("%.", dir_spliter)
	local file, file_path = nil, nil
	for path in package.path:gmatch("[^;]+") do
		local len = path:len()
		path = path:sub(1, len - 4) .. ".mn"
		file_path = path:gsub("?", name_path)
		file = io.open(file_path)
		if file then
			break
		end
	end
	local text = nil
	if file then
		text = file:read(all_option)
		file:close()
	else
		return nil, "Could not find mn file"
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
local function mnLoadString(text, cname, mode, env)
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
	return f(res, cname, unpack({ mode = mode, env = env }))
end
local function mnLoadFile(fname, ...)
	local f, err = io.open(fname)
	if not f then
		return nil, err
	end
	local text = assert(f:read(all_option))
	f:close()
	return mnLoadString(text, fname, ...)
end
local function mnDoFile(...)
	local f = assert(mnLoadFile(...))
	return f()
end
local _mn_loaded = false
local function mnRemoveLoader()
	if not _mn_loaded then
		return 
	end
	local loaders = package.loaders or package.searchers
	for i, loader in ipairs(loaders) do
		if loader == mnLoader then
			remove(loaders, i)
			_mn_loaded = false
			return true
		end
	end
	return false
end
local function mnAppendLoader()
	if _mn_loaded then
		return 
	end
	local loaders = package.loaders or package.searchers
	local has_loader = false
	for i = 1, #loaders do
		if loaders[i] == mnLoader then
			has_loader = true
		end
	end
	if not has_loader then
		_mn_loaded = true
		insert(loaders, mnLoader)
	end
end
local function mnVersion()
	return "mnscript v0.3.20210601, " .. _VERSION
end
local function mnLoaded()
	return _mn_loaded
end
-- append loader
mnAppendLoader()
return { loadstring = mnLoadString, loadfile = mnLoadFile, dofile = mnDoFile, removeloader = mnRemoveLoader, appendloader = mnAppendLoader, toAST = toAST, toLua = toLua, version = mnVersion, loaded = mnLoaded }
