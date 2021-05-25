local parser = require("mn_parser")
local compile = require("mn_compile")

describe("test success #block #fn", function()
    local mnstr=[[
    {
        a = 10
        c = fn(c) {
            print(9)
            return c
        }
        class B {
        }
    }]]

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
   end)
end)

describe("test failed #block", function()
    local mnstr=[[
    {        
    }]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
         assert.is_true(type(ast) == "table")
    end)
end)