--
-- Copyright (c) 2021 lalawue
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--
local Utils = require("mn_utils")
local Core = require("mn_core")
local Loader = {}
do
	local __stype__ = nil
	local __clsname__ = "Loader"
	local __clstype__ = Loader
	__clstype__.classname = __clsname__
	__clstype__.classtype = __clstype__
	__clstype__.supertype = __stype__
	__clstype__.isKindOf = function(cls, a) return a and ((cls.classtype == a) or (cls.supertype and cls.supertype:isKindOf(a))) or false end
	__clstype__.isMemberOf = function(cls, a) return cls.classtype == a end
	__clstype__.init = function() end
	-- declare class var and methods
	function __clstype__.help()
		Utils.debug("Usage: [OPTIONS] FILE")
		Utils.debug("\t-h print this help")
		Utils.debug("\t-a print AST")
		Utils.debug("\t-s output Lua source only")
		Utils.debug("\t-v version")
	end
	function __clstype__.option(...)
		local a, b = ...
		if a == nil or a == "-h" then
			Loader.help()
			return 
		end
		local config = {  }
		a = (b and a) or ( not b and a) or "-"
		do 
			local __sw__ = a
			if __sw__ == ("-a") then
				config.option = "ast"
				config.opcount = 2
				config.fname = b
			elseif __sw__ == ("-s") then
				config.option = "source"
				config.opcount = 2
				config.fname = b
				config.shebang = true
			elseif __sw__ == ("-p") then
				config.option = "project"
				config.opcount = 2
				config.fname = b
				config.shebang = true
			elseif __sw__ == ("-v") then
				Utils.debug(Core.version())
				return 
			else
				if a:len() <= 0 or b then
					Loader.help()
					return 
				else
					config.option = "run"
					config.opcount = 1
					config.fname = a
				end
			end
		end
		return config
	end
	function __clstype__.toCode(config)
		-- read file first
		local text = Utils.readFile(config.fname)
		if  not text then
			Utils.debug("Failed to read file '" .. config.fname .. "'")
			return 
		end
		-- generate AST
		local res, emsg = Core.toAST(config, text)
		if  not res or config.option == "ast" then
			if res then
				Utils.dump(res.ast)
			else
				Utils.debug(emsg)
			end
			return 
		end
		-- generate Lua code
		res, emsg = Core.toLua(config, res)
		if  not res or config.option == "source" then
			if res then
				Utils.debug(res)
			else
				Utils.debug(emsg)
			end
			return 
		end
		return res
	end
	function __clstype__.run(config, content, ...)
		local f, err = load(content, config.fname, "t")
		if type(f) == "function" then
			f(select(config.opcount + 1, ...))
		else
			Utils.debug(err)
		end
	end
	function __clstype__.project(config)
		-- read config
		local config_content = Utils.readFile(config.fname)
		if  not config_content then
			Utils.debug("Failed to read config")
			return 
		end
		-- load config
		local f = Core.loadstring(config_content, config.fname)
		if type(f) ~= "function" then
			Utils.debug("Failed to load config")
		end
		-- get config table
		local pt = f()
		if type(pt) ~= "table" then
			Utils.debug("Invalid config")
			return 
		end
		local lfs = assert(require("lfs"))
		local tmp_config = Utils.copy(config)
		-- generate Lua code recursive
		local function toLuaDir(config, in_dir, out_dir)
			for fname in lfs.dir(in_dir) do
				local flen = fname:len()
				if flen > 0 and fname:sub(1, 1) ~= "." then
					lfs.mkdir(out_dir)
					local inpath = in_dir .. "/" .. fname
					local outpath = out_dir .. "/" .. fname
					local ft = lfs.attributes(inpath)
					if ft.mode == "directory" then
						Utils.debug("into " .. outpath)
						if  not toLuaDir(config, inpath, outpath) then
							return false
						end
					elseif flen > 3 and fname:sub(flen - 2, flen) == ".mn" then
						tmp_config.fname = inpath
						local code = Loader.toCode(tmp_config)
						if  not code then
							return false
						end
						local outname = outpath:sub(1, outpath:len() - 3) .. ".lua"
						Utils.writeFile(outname, code)
					end
				end
			end
			return true
		end
		-- check projects
		for i, proj in ipairs(pt) do
			if proj.name and proj.proj_dir and proj.proj_out then
				Utils.debug("proj: [" .. proj.proj_dir .. ']')
				if  not toLuaDir(config, proj.proj_dir, proj.proj_out) then
					break
				end
			else
				Utils.debug("[" .. (proj.name or "unknown") .. "] project !")
			end
		end
	end
	function __clstype__.main(...)
		local config = Loader.option(...)
		if  not config then
			return 
		end
		-- output SOURCE from project config
		if config.option == "project" then
			Loader.project(config)
			return 
		end
		local code = Loader.toCode(config)
		if  not code then
			return 
		end
		-- run this Lua code
		return Loader.run(config, code, ...)
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
return Loader
