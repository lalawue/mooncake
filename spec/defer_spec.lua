local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success_1 #defer", function()
    local mnstr=[[
        a = 0
        fn test_defer() {
            defer {
                a += 10
            }
            a += 10
            return fn() {
                defer {
                    a += 20
                }
                a += 20
            }
        }
        b = 0
        fn last_return() {
            b = 10
            defer {
                b = 20
            }
        }
        test_defer()()
        c = 0
        d = 0
        class C {
            static fn testStatic() {
                defer {
                    c *= 100
                }
                c += 2
            }
            fn testInstance() {
                defer {
                    d *= 100
                }
                d += 2
            }
        }
        return a, last_return(), b, C.testStatic(), C:testInstance(), c, d
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
        local a, _, b, _, _, c, d = f()
        assert.is_equal(a, 60)
        assert.is_equal(b, 20)
        assert.is_equal(c, 200)
        assert.is_equal(d, 200)
    end)
end)

describe("test success_2 #defer", function()
    local mnstr=[[
        a = 0
        fn test_defer() {
            defer {
                a += 1
            }
            b = 2
            for i=1, 2 {
                b += 2
            }
        }
        test_defer()
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

    it("a == 1 ", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local a = f()
        assert.is_equal(a, 1)
    end)
end)

describe("test failed_1 #defer", function()
    local mnstr=[[
        var_test_c = 0
        defer {
            var_test_c += 1
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "defer only support function scope")
    end)
end)

describe("test failed_2 #defer", function()
    local mnstr=[[
        fn abc() {
            a = 0
            defer {
                a += 1
                defer {
                    a += 1
                }
            }
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "defer can not inside another defer")
    end)
end)