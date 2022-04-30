local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #number", function()
    local mnstr=[[
        return 123, 123.45, .67, 0xFF, 1e3, 1e-3, .2e2
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
        local a, b, c, d, e, f, g = f()
        assert.is_equal(a, 123)
        assert.is_equal(b, 123.45)
        assert.is_equal(c, 0.67)
        assert.is_equal(d, 255)
        assert.is_equal(e, 1000)
        assert.is_equal(f, 0.001)
        assert.is_equal(g, 20)
    end)
end)

describe("test success_2 #number", function()
    local mnstr=[[return 0xF]]

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
        local a = f()
        assert.is_equal(a, 15)
    end)
end)

describe("test success_3 #number", function()
    local mnstr=[[return .2]]

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
        local a = f()
        assert.is_equal(a, 0.2)
    end)
end)

describe("test success_4 #number", function()
    local mnstr=[[return 3]]

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
        local a = f()
        assert.is_equal(a, 3)
    end)
end)

describe("test success_5 #number", function()
    local mnstr=[[return .1e-2]]

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
        local a = f()
        assert.is_equal(a, 0.001)
    end)
end)

describe("test failed_1 #number", function()
    local mnstr=[[
        return 123.12.2
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "malformed number")
        assert.is_equal(ast.pos, 21)
    end)
end)

describe("test failed_2 #number", function()
    local mnstr=[[
        return 123e23e
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "malformed number")
        assert.is_equal(ast.pos, 21)
    end)
end)

describe("test failed_3 #number", function()
    local mnstr=[[return 0x]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "malformed number")
        assert.is_equal(ast.pos, 9)
    end)
end)