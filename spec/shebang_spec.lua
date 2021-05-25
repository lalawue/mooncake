local parser = require("mnscript.parser")
local compile = require("mnscript.compile")

describe("test success #shebang", function()
    local mnstr=[[#!/usr/bin/env lua ./core/mn_loader.lua

        fn echo() {
            return "hello, mnscript!"
        }
        return echo()
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({ shebang = true }, ast)
    it("should get compiled lua with shebang", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    ret, content = compile.compile({}, ast)
    it("should get compiled lua no shebang", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f, err = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local a = f()
        assert.is_equal(a, "hello, mnscript!")
    end)
end)