local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success 1 #table", function()
    local mnstr=[[
        b = 9 + ...
        a =  {
            --- 111
             3,
             [4] = 3, --- 222
             [fn(){}] = 4,
             [{fn(){}}] = fn(){}, --[=[ 90123d ]=]
             "false" = tonumber("10"),
             'class' = 12,
             c = 1 + ...,
             =b,
             d = b,
             [b] = b
             -- 999
        }
        a [ "d"] = 3
        return a
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
        local t = f(10)
        assert.is_equal(t.c, 11)
        assert.is_equal(t.b, 19)
        assert.is_equal(t.d, 3)
    end)
end)

describe("test success 2 #table", function()
    local mnstr=[[
        b = 9 + ...
        a =  {
            --- 111
             3,
             [4] = 3, --- 222
             [fn(){}] = 4,
             [{fn(){}}] = fn(){}, --[=[ 90123d ]=]
             [false] = tonumber("10"),
             ['class'] = 12,
             c = 1 + ...,
             =b,
             d = b,
             [b] = b
             -- 999
        }
        a [ "d"] = 3
        return a
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
        local t = f(10)
        assert.is_equal(t.c, 11)
        assert.is_equal(t.b, 19)
        assert.is_equal(t.d, 3)
    end)
end)

describe("test comment #table", function()
    local mnstr=[[
        b = 9 + ...
        a =  {
            --- 111
            --- 222
             3,
             [4] = 3, --- 222
             --[=[ 1231232 ]=]
             --[=[ 212312 ]=]
             [fn(){}] = 4,
             [{fn(){}}] = fn(){}, --[=[ 90123d ]=]
             [false] = tonumber("10"),
             ['class'] = 12,
             c = 1 + ...,
             =b,
             d = b,
             [b] = b
             -- 999
             -- 33
             --[=[ 222 ]=]
        }
        c = {
            -- 111
            -- 222
            --[=[ 12312 ]=]
        }
        a [ "d"] = 3
        return a
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
        local t = f(10)
        assert.is_equal(t.c, 11)
        assert.is_equal(t.b, 19)
        assert.is_equal(t.d, 3)
    end)
end)

describe("test failed #table", function()
    local mnstr=[[
        return { a = a }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
    end)

    it("has error", function()
        local ret, content = compiler.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 21)
   end)
end)