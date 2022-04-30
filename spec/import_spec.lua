local parser = require("moocscript.parser")
local compile = require("moocscript.compile")
local utils = require("moocscript.utils")

describe("test success #import", function()
    local mnstr=[[
        import "moocscript.utils"
        import utils from "moocscript.utils"
        import ut from utils
        import split, trim from ut {}
        fn call() {
            import s from "moocscript.utils" { split }
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
 
    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local s = f()
        assert.is_equal(s[1], utils.split)
        assert.is_equal(s[2], utils.trim)
        assert.is_equal(s[3], utils)
    end)
end)

describe("test failed #import", function()
    local mnstr=[[
        import from "moocscript.utils"
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
        assert.is_equal(content.err_msg, "undefined variable")
    end)
end)

describe("test failed #import", function()
    local mnstr=[[
        import sort, concat from "table" { sort }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "from too few sub lib")
        assert.is_equal(ast.pos, 48)
    end)
end)

describe("test failed #import", function()
    local mnstr=[[
        import sort from "table" { sort, concat }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "from too much sub lib")
        assert.is_equal(ast.pos, 40)
    end)
end)