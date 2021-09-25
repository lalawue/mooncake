local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #defer", function()
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

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)
 
    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local a, _, b, _, _, c, d = f()
        assert.is_equal(a, 60)
        assert.is_equal(b, 20)
        assert.is_equal(c, 200)
        assert.is_equal(d, 200)
    end)
end)

describe("test failed #defer", function()
    local mnstr=[[
        var_test_c = 0
        defer {
            var_test_c += 1
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:2:         defer { <not in function 'defer'>")
   end)
end)