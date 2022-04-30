local Utils = require("moocscript.utils")
local parse
do
	local __l = require("moocscript.parser")
	parse = __l.parse
end
local compile, clearproj
do
	local __l = require("moocscript.compile")
	compile, clearproj = __l.compile, __l.clearproj
end
local split, readFile
do
	local __l = require("moocscript.utils")
	split, readFile = __l.split, __l.readFile
end
local concat, insert, remove = table.concat, table.insert, table.remove
local unpack, assert = unpack or table.unpack, assert
local type, error, load, loadstring = type, error, load, loadstring
local jit = jit
local sfmt = string.format
local srep = string.rep
local function toAST(config, text)
	local t = type(text)
	if t ~= "string" then
		return nil, "expecting string (got " .. t .. ")"
	end
	config = config or {  }
	local ret, tbl = parse(text)
	if not ret then
		return nil, Utils.errorMessage(tbl.content, tbl.pos, tbl.err_msg, config.fname)
	end
	return tbl
end
local function toLua(config, tbl)
	local ret, code = compile(config, tbl)
	if not ret then
		return nil, Utils.errorMessage(tbl.content, code.pos, code.err_msg, config.fname)
	end
	return code
end
local dir_spliter = package.config and package.config[1] or '/'
local tmp_config = {  }
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
	return f(res, cname, unpack({ mode = mode, env = env }))
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
	return "moocscript v0.7.20220501, " .. (jit and jit.version or _VERSION)
end
local function mcLoaded()
	return package.mooc_loaded ~= nil
end
mcAppendLoader()
return { loadstring = mcLoadString, loadfile = mcLoadFile, dofile = mcDoFile, removeloader = mcRemoveLoader, appendloader = mcAppendLoader, toAST = toAST, toLua = toLua, clearProj = clearproj, version = mcVersion, loaded = mcLoaded }
