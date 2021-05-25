local parser = require("mn_parser")
local compile = require("mn_compile")

describe("test success #defer", function()
    local mnstr=[[
        var_test_a = 0
        fn test(a) {
            a += 1
            if a < 1 {
                return
            } elseif a < 3 {
                defer {
                    var_test_a += 1
                }
            } elseif a < 5 {
                defer {
                    var_test_a += 10
                    defer {
                        var_test_a += 100
                    }
                }
            } else {
                return a
            }
            return 10
        }
        
        var_test_c = 0
        cc = fn(b, d) {
            b += 1
            defer {
                var_test_c += 1
            }
            if b < 1 {
                return
            } elseif b < 3 {
                defer {
                    var_test_c += 10
                }
            } elseif b < 5 {
                defer {
                    var_test_c += 100
                }
            } else {
                return 9
            }
        }
        
        test(2)
        cc(4)
        return var_test_a, var_test_c
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
        local va, vc = f()
        assert.is_equal(va, 10)
        assert.is_equal(vc, 1)
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