--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
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
local split, posLine
do
	local __lib__ = require("moocscript.utils")
	split, posLine = __lib__.split, __lib__.posLine
end
local concat, insert, remove
do
	local __lib__ = table
	concat, insert, remove = __lib__.concat, __lib__.insert, __lib__.remove
end
unpack = unpack or table.unpack
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
-- register loader
local function mcLoader(name)
	local name_path = name:gsub("%.", dir_spliter)
	local file, file_path = nil, nil
	for path in package.path:gmatch("[^;]+") do
		local len = path:len()
		path = path:sub(1, len - 4) .. ".mooc"
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
	return f(res, cname, unpack({ mode = mode, env = env }))
end
local function mcLoadFile(fname, ...)
	local f, err = io.open(fname)
	if not f then
		return nil, err
	end
	local text = assert(f:read(all_option))
	f:close()
	return mcLoadString(text, fname, ...)
end
local function mcDoFile(...)
	local f = assert(mcLoadFile(...))
	return f()
end
local _mc_loaded = false
local function mcRemoveLoader()
	if not _mc_loaded then
		return 
	end
	local loaders = package.loaders or package.searchers
	for i, loader in ipairs(loaders) do
		if loader == mcLoader then
			remove(loaders, i)
			_mc_loaded = false
			return true
		end
	end
	return false
end
local function mcAppendLoader()
	if _mc_loaded then
		return 
	end
	local loaders = package.loaders or package.searchers
	local has_loader = false
	for i = 1, #loaders do
		if loaders[i] == mcLoader then
			has_loader = true
		end
	end
	if not has_loader then
		_mc_loaded = true
		insert(loaders, mcLoader)
	end
end
local function mcVersion()
	return "moocscript v0.3.20210605, " .. _VERSION
end
local function mcLoaded()
	return _mc_loaded
end
-- append loader
mcAppendLoader()
return { loadstring = mcLoadString, loadfile = mcLoadFile, dofile = mcDoFile, removeloader = mcRemoveLoader, appendloader = mcAppendLoader, toAST = toAST, toLua = toLua, clearProj = clearproj, version = mcVersion, loaded = mcLoaded }