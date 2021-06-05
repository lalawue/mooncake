local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #expr", function()
    local mnstr=[[
        fn calcNumber(a) {
            return a + 2
        }
        
        fn calcTwo(a, b) {
            return a+1, b+2
        }
        
        a = calcNumber((8 + 4) / (3 * 2) * 2)
        b = calcNumber("9" == "10" and 1 or 2)
        c, d = calcTwo(11 * (3 - 2), calcNumber(6))
        return a, b, c, d
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
        local a, b, c, d = f()
        assert.is_equal(a, 6)
        assert.is_equal(b, 4)
        assert.is_equal(c, 12)
        assert.is_equal(d, 10)
    end)
end)

describe("test failed #expr", function()
    local mnstr=[[
        fn ret(a) {
            return a
        }
        ret(fn a () {})
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)