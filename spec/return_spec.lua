local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #return", function()
    local mnstr=[[
        while true {
            return 1, _G, "99", fn(a){}, table.remove
        }
        if false {
            return (loadstring or load)("", "", unpack({}))
        }
        return 0 -- hello
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
        local a = f()
        assert.is_equal(a, 1)
    end)
end)

describe("test failed 1 #return", function()
    local mnstr=[[
        return 9
        do {
            return 1
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_true(ast.err_msg == "'eof' expected after 'return'")
    end)
end)

describe("test failed 2 #return", function()
    local mnstr=[[
        fn abc() {
            defer {
                return 9
            }
        }
    ]]
    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_true(ast.err_msg == "defer block can not return value")
    end)
end)