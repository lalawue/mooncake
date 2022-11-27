local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #while", function()
    local mnstr=[[
        a = 1
        while [==[9981]==] and fn(){} {
            a = 2;
            break
        }
        local c
        while _G or table.call or false {
            c = _G
            break
        };
        while (next or next)  (_G) {
            break
        }
        while true {
            break
        }
        return a, c
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

    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local a, c = f(10)
        assert.is_equal(a, 2)
        assert.is_equal(c, _G)
    end)
end)

describe("test failed #while", function()
    local mnstr=[[
        while b {
            break
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
    end)

    it("has error", function()
        local ret, content = compiler.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 14)
   end)
end)