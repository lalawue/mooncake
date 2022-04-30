-- test_step.lua
local Utils = require("moocscript.utils")
local MoocCore = require("moocscript.core")

-- get filename
local fname = ...
if fname == nil or fname:len() <=0 then
        print("Usage: lua test_step.lua exp_lib.mooc")
        os.exit(0)
end

-- first load file
local text = Utils.readFile(fname)

-- setup config, for error indicating
local config = { fname = fname }

-- get ast
local res, emsg = MoocCore.toAST(config, text)
if res then
        print("--- ast")
        Utils.dump(res.ast)
else
        print("error:", emsg)
        os.exit(0)
end

-- get Lua source
local code, emsg = MoocCore.toLua(config, res)
if code then
        print("--- code")
        print(code)
else
        print("error:", emsg)
end