local parser = require("mnscript.parser")
local compile = require("mnscript.compile")

describe("test success #repeat", function()
    local mnstr=[[
        a = 1
        repeat {
            a += 2;
            if a >= 10 {
                break
            }
        } until {} and fn(){};
        return a
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
        local a = f()
        assert.is_equal(a, 3)
    end)
end)

describe("test failed #repeat", function()
    local mnstr=[[
        repeat {
        } until c
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")        
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:2:         } until c <undefined variable 'c'>")
   end)
end)