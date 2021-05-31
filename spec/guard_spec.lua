local parser = require("mnscript.parser")
local compile = require("mnscript.compile")

describe("test success #guard", function()
    local mnstr=[[
        while true {
            guard false else {
                break
            }
            return 20
        }
        guard false else {
            goto tagNext
        }
        do {
            return 30
        }
        ::tagNext::
        guard true else {
            return 10
        }
        return 40
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
        local ret = f()
        assert.is_equal(ret, 40)
    end)
end)

describe("test failed #guard", function()
    local mnstr=[[
        guard true else {
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_false(ret)
        assert.is_equal(content, "_:1:         guard true else { <guard statement need return/goto/break at last 'guard'>")
    end)
end)