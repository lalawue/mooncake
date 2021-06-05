local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #block #fn", function()
    local mnstr=[[
    do {
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

describe("test success #block", function()
    local mnstr=[[
    do {        
    }]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)
end)

describe("test failed #block", function()
     local mnstr=[[
     do {
          break          
     }]]
 
     local ret, ast = parser.parse(mnstr)
     it("should get ast", function()
          assert.is_true(ret)
          assert.is_true(type(ast) == "table")
     end)

     local ret, content = compile.compile({}, ast)
     it("should get compiled lua", function()
          assert.is_false(ret)     
          assert.is_equal(content, "_:2:           break           <not in loop 'break'>")
     end)
 end)