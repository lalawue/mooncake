local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #function", function()
    local mnstr=[[
        local fn sub(a, b) {
            return a - b
        }

        export fn devide(...) {
        }

        fn add( d, f, ...) {
        }

        sqrt = fn(j, k) {
        }

        power = { m, n in
            return
        }

        return sub, devide, add, sqrt, power
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
        local sub, devide, add, sqrt, power = f()
        assert.is_function(sub)
        assert.is_function(devide)
        assert.is_function(add)
        assert.is_function(sqrt)
        assert.is_function(power)
        assert.is_equal(sub(12, 10), 2)
    end)
end)

describe("test success 1 #function", function()
    local mnstr=[[
        local tbl = {  }
        tbl.__index = tbl
        tbl.a  = tbl
        tbl.b = fn() {
            return tbl
        };
        tbl.c = fn() {
            return "c"
        }
        return tbl.a.a:b():c()
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
        local c = f()
        assert.is_equal(c, "c")
    end)
end)

describe("test success 2 #function", function()
    local mnstr=[[
        B = { C = {} }
        fn B.C:echo() {
            self.d = 9
            return self.d
        }
        return B.C
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
        local c = f()
        local d = c:echo()
        assert.is_equal(d, 9)
    end)
end)

describe("test success 3 #function", function()
    local mnstr=[[
        Bird = {}

        fn Bird.fly() {
        }

        fn Bird:eat() {
        }
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
end)

describe("test scope #function", function()
    local mnstr=[[
        export funcA
        do {
            fn funcA() {
            }
        }
        return funcA
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
        assert.is_function(f())
    end)
end)

describe("test failed #function", function()
    local mnstr=[[
        fn b.sub() {
            return 0
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compiler.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 11)
   end)
end)

describe("test failed #function", function()
    local mnstr=[[
        fn sub() {
            return self
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compiler.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 38)
   end)
end)