local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #ifelse", function()
    local mnstr=[[
        a = 2
        if tonumber(...) < 3 {
            a = 3
        } elseif tonumber(...) > 3 {
            a = 4
        } else {
            a = 5
        }
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
        local a1 = f(3)
        assert.is_equal(a1, 5)
        local a2 = f(2)
        assert.is_equal(a2, 3)
    end)
end)

describe("test failed #ifelse", function()
    local mnstr=[[
        if a == 2 {
            return 3
        }
        return 4
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:1:         if a == 2 { <undefined variable 'a'>")
   end)
end)