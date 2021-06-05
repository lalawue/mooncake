local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #assign #export #local", function()
    local mnstr=[[export q
    local a = 1
    q = (2 * 4) / 5;
    x = 8 * ((6 + 4) / 7)
    b, d = '9', false;
   e, f, g = { 3, a}, fn(c) {}
    h, i = e and (f or (not not g and g)) and fn () {}
   m = 8 + -b * 10
   t, v = "\\", not not h
   p = (next or next)(_G)
   o = p != 0
   return p, q, x, b, d, e, f, g, h, i, m, t, v]]

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
   
   local p, _, _, b, d, e, f, _, _, _, m, t, v = f()
   it("should get corect value", function()
        assert.is_equal(p, next(_G))
        assert.is_equal(_G.q, 1.6)
        assert.is_equal(b, "9")
        assert.is_false(d)
        assert.is_table(e)
        assert.is_function(f)
        assert.is_equal(m, -82.0)
        assert.is_equal(t, "\\")
        assert.is_true(v)
   end)
end)

describe("test success #assign", function()
     local mnstr=[[body = {1}
     bt = { stype :"a" }
     if #body <= 0 or not (bt.stype == "return" or bt.stype == "goto" or bt.stype == "break") {
         print("hello")
         return
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

describe("test failed compile #assign", function()
     local mnstr=[[
          q = ((2 * 4) / 5
     ]]
     local ret, ast = parser.parse(mnstr)
     it("should get ast", function()
          assert.is_false(ret)
     end)
end)

describe("test invalid self #assign", function()
     local mnstr=[[
          self = self + 8
     ]]
     local ret, ast = parser.parse(mnstr)
     it("shoul get ast", function()
          assert.is_true(ret)
          assert.is_table(ast)
     end)

     it("has error", function()
          local ret, code = compile.compile({}, ast)
          assert.is_false(ret)
          assert.is_equal(code, "_:1:           self = self + 8 <undefined variable 'self'>")
     end)
end)