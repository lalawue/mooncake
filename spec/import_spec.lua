local parser = require("mn_parser")
local compile = require("mn_compile")
local utils = require("mn_utils")

describe("test success #import", function()
    local mnstr=[[
        import "mn_utils"
        import utils from "mn_utils"
        import ut from utils
        import split, trim from ut {}
        fn call() {
            import s from "mn_utils" { split }
            return { s, trim, utils }
        }
        return call()
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)
 
    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local s = f()
        assert.is_equal(s[1], utils.split)
        assert.is_equal(s[2], utils.trim)
        assert.is_equal(s[3], utils)
    end)
end)

describe("test failed #import", function()
    local mnstr=[[
        import from "mn_utils"
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
    end)
end)

describe("test failed #import", function()
    local mnstr=[[
        import s from lpeg
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:1:         import s from lpeg <undefined variable 'lpeg'>")
    end)    
end)