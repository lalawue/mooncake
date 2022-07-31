local parser = require("moocscript.parser")
local compile = require("moocscript.compile")
local clss = require("moocscript.class")

describe("test success #extension", function()
    local mnstr=[[
        class ClsA {
            a = 1
            fn add(b) {
                self.a += b
                return self
            }            
        }
        class ClsB {
            a = 2
            fn sub(b) {
                self.a -= b
                return self
            }
        }
        extension ClsA: ClsB {
            fn multi(b) {
                self.a *= b
                return self
            }
        }
        return ClsA
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
        local ClsA = f()
        local a = ClsA()
        local ret = a:add(10):sub(5):multi(3).a
        assert.is_equal(ret, 18)
    end)
end)


describe("test success #extension", function()
    local mnstr=[[
        class ClsA {
            name = Self.__tn
        }
        struct StructA {
            fn getName() {
                return self.name or "none"
            }
        }
        extension StructA : ClsA {
        }
        a = StructA()
        return a:getName()
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
        local name = f()
        assert.is_equal(name, "ClsA")
    end)
end)

describe("test failed parser #extension", function()
    local mnstr=[[
        class ClsA {
        }
        struct StructB {
        }
        struct StructC {
        }
        extension ClsA: StructB, StructC {
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed compile #extension", function()
    local mnstr=[[
        struct StructB {
        }
        extension ClsA: StructB {
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 53)
    end)    
end)


describe("test failed compile #extension", function()
    local mnstr=[[
        class ClsA {
        }
        extension ClsA: StructB {
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 55)
    end)    
end)

describe("test mixed from lua side #extension", function()
    local mnstr=[[
        struct A {
            a = 'A'
            fn name() {
                return 'A'
            }
        }
        struct B {
            a = 'B'
            fn name() {
                return 'B'
            }
        }
        extension B: A {
            a = 'C'
            b = 'CC'
            fn name() {
                return 'C'
            }
            fn Name() {
                return 'CC'
            }
            static fn NName() {
                return 'CCC'
            }
        }
        return B
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
        assert.is_equal(f():name(), "C")
        assert.is_equal(f().Name(), "CC")
        assert.is_equal(f().NName(), "CCC")
    end)

    it("should extension struct B", function()

        local ClassC = clss.newMoocClass('C')
        function ClassC:add(c)
            return self.a + self.b + c
        end

        local RestrictedStructB = f()
        RestrictedStructB.init = function() end
        assert.is_equal(RestrictedStructB.init, nil)

        local RawTableB = clss.extentMoocClassStruct(RestrictedStructB, ClassC)
        function RawTableB:init(a, b)
            self.a = a
            self.b = b
        end

        local b = RestrictedStructB(1, 2)
        assert.is_equal(tostring(b):sub(1, 10), "<struct B:")
        assert.is_equal(b.__tn, "B")
        assert.is_equal(b.a, 1)
        assert.is_equal(b.b, 2)
        assert.is_equal(b:add(4), 7)
    end)
end)

describe("test failed #extension", function()
    local mnstr=[[
        A = nil
        struct B {}
        extension B: A {}
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("has error", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
   end)

   local f = load(content, "test", "t")
   it("should get function", function()
       assert(type(f) == "function")
       local ret = pcall(f)
       assert.is_false(ret)
   end)
end)

describe("test failed #extension", function()
    local mnstr=[[
        A = nil
        B = nil
        extension B: A {}
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("has error", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
   end)

   local f = load(content, "test", "t")
   it("should get function", function()
       assert(type(f) == "function")
       local ret = pcall(f)
       assert.is_false(ret)
   end)
end)

describe("test __index #extension", function()
    local mnstr=[[
        struct A {
        }
        extension A {
            fn __index() {
            }
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "extension not support metamethod")
   end)
end)

describe("test __index #extension", function()
    local mnstr=[[
        struct A {
        }
        extension A {
            static fn __index() {
            }
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "extension not support metamethod")
   end)
end)