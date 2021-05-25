local parser = require("mnscript.parser")
local compile = require("mnscript.compile")

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
        
        d = { f : fn() { 
                t = {}
                t.__index = {}
                t.c = fn () {
                    return 1
                }
                return t
            }
        }
        
        f = fn () {
            return { c : c }
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
 
    local f = load(content, "test", "t")
    it("should get function", function()
         assert(type(f) == "function")
         local a, v, c = f()
         assert.is_equal(a, 1)
         assert.is_equal(v, "v")
         assert.is_function(c)
    end)
end)

describe("test failed #call", function()
    local mnstr=[[
        _G:c:print("Invalid Call")
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)