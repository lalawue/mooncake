local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #goto", function()
    local mnstr=[[
        ret = 1
        for i = 1, 8 {
            if i == 6 {
                goto no_6
            }
            ret = i
        }
        :: no_6 ::
        return ret
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compiler.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local ret = f()
        assert.is_equal(ret, 5)
    end)
end)

describe("test failed #goto", function()
    local mnstr=[[
        goto no_2
        local j
        ::no_2::
        return j
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compiler.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f = load(content, "test", "t")
    it("should get function", function()
        assert.is_nil(f)
    end)
end)