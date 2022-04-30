local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #call", function()
    local mnstr=[[
        c = fn () {
            t = {}
            t.__index = t
            t.f = fn() {
                return { }
            }
            return t
        }

        d = { f = fn() {
                t = {}
                t.__index = {}
                t.c = fn () {
                    return 1
                }
                return t
            }
        }

        f = fn () {
            return { c = c }
        }

        c():f()[d.f()] = 1

        c(d.f, 9, "9", f(), ...)

        b = fn() { return { d } }

        a = b()[1].f():c()

        tbl = {}
        tbl.a = tbl
        tbl.b = fn() { return tbl }
        tbl.c = fn() { return "v" }
        v = tbl.a:b():c();

        (next or print)(_G)

        fn cc() { return cc }

        return a, v, cc()()
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
        local a, v, c = f()
        assert.is_equal(a, 1)
        assert.is_equal(v, "v")
        assert.is_function(c)
    end)
end)

describe("test no parentheses #call", function()
    local mnstr=[[
        fn f(a) {
            return a
        }
        if not f . 'a' {
            return f. { }
        }
        return f. 'a', f . "b", f .{ "c" }
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

    it("should get result", function()
        local f = load(content, "test", "t")
         assert(type(f) == "function")
         local a, b, c = f()
         assert.is_equal(a, "a")
         assert.is_equal(b, "b")
         assert.is_table(c)
         assert.is_equal(c[1], "c")
    end)
end)

describe("test call table config #call", function()
    local mnstr=[[
        return {
            print. {
                { a = "10", c = '9' },
                "100"
            },
            {
                print. "100",
                print. { b = 99 }
            }
        }
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
end)

describe("test failed 1 #call", function()
    local mnstr=[[
        _G:c:print("Invalid Call")
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed 2 #call", function()
    local mnstr=[[
        print . 'a' "b"
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed 3 #call", function()
    local mnstr=[[
        print(a, b).a
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)