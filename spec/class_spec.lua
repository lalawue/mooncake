local parser = require("moocscript.parser")
local compile = require("moocscript.compile")
local clss = require("moocscript.class")

describe("test normal #class", function()
    local mnstr=[[
        local class ClsA {
            a = 11
            f = Self.a + 99
            fn init() {
                self.b = 0
            }
            fn takeTime(c) {
                return self.a + 101 - c
            }
            fn deinit() {
            }
            static fn __add(a, b) {
                return "add"
            }
            fn __add(a, b) {
                return 666
            }
            fn deinit() {
            }
        }
        export class ClsB : ClsA {
            -- declare class variable
            b = 9 * 2 * (3 + (8 ^ 2))
            static fn runAway(a) {
                return Self.b + a
            }
            fn takeTime(c, d) {
                return c + d * 2
            }
            fn change(a) {
                Self.a = a
            }
            static fn test() {
                Self.takeTime(Self, 1, 2)
            }
            static fn checksuper() {
                return Super
            }
        }
        ClsA.b = 100
        return ClsA, ClsB
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
    it("should inherit", function()
        assert(type(f) == "function")
        local ClsA, ClsB = f()
        ClsA.c = 9
        assert.is_equal(ClsA.a, 11)
        assert.is_equal(ClsA.b, 100)
        assert.is_equal(ClsB.b, 1206)
        assert.is_equal(ClsA.f, 110)
        assert.is_equal(ClsB.runAway(10), 1216)
        assert.is_equal(ClsB.checksuper(), ClsA)
        local b = ClsB()
        assert.is_true(b:isKindOf(ClsA))
        assert.is_equal(b:takeTime(1, 2), 5)
        assert.is_equal(b.c, 9)
        b:change(99)
        assert.is_equal(ClsB.a, 99)
        b.test()
    end)

    it("should deinit", function()
        assert(type(f) == "function")
        local ClsA = f()
        stub(ClsA, "deinit")
        do
            local a = ClsA()
            a:takeTime(0)
        end
        collectgarbage()
        assert.stub(ClsA.deinit).was.called()
    end)

    it("should invoke class and instance metamethod", function()
        assert(type(f) == "function")
        local ClsA = f()
        local a = ClsA()
        assert.is_equal((ClsA + ClsA), "add")
        assert.is_equal((a + a), 666)
    end)
end)

describe("test success #class", function()
    local mnstr=[[
        class Tbl {
            a = Tbl
    
            static fn b() {
                return Tbl
            }
        
            static fn c() {
                return "c"
            }
        }
        
        return Tbl.a.a:b():c()
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
 
    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local c = f(10)
        assert.is_equal(c, "c")
    end)
end)

describe("test inherit from lua side #class", function()
    local mnstr=[[
        class A {
            a = 10
            b = 'A'
            fn name() {
                return self.b
            }
            fn Name() {
                return Self.b
            }
            fn NName() {
                return 'A'
            }
        }
        return A
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
        assert.is_equal(f():name(), "A")
        assert.is_equal(f().Name(), "A")
        assert.is_equal(f().NName(), "A")
    end)

    it("should create class B", function()
        local B = clss.newMoocClass('B')
        function B:init(a, b)
            self.a = a
            self.b = b
        end
        local b = B(1, 2)
        assert.is_equal(tostring(b):sub(1, 9), "<class B:")
        assert.is_equal(b.__tn, "B")
        assert.is_equal(b.a, 1)
        assert.is_equal(b.b, 2)
    end)

    it("should inherit from class A", function()
        local A = f()
        local C = clss.newMoocClass('C', A)
        function C:init(b)
            self.b = b
        end
        function C:add()
            return self.a + self.b
        end
        local c = C(20)
        assert.is_equal(tostring(c):sub(1, 9), "<class C:")
        assert.is_equal(c.__st, A)
        assert.is_equal(c.a, 10)
        assert.is_equal(c.b, 20)
        assert.is_equal(c:add(), 30)
    end)
end)

describe("test failed #class", function()
    local mnstr=[[
        class ClsA {
            c.d = 11
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed #class", function()
    local mnstr=[[
        class ClsA {
            a = 11
            static fn takeTime(c) {
                return self.a + 101 - c
            }
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
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 99)
   end)
end)

describe("test failed #class", function()
    local mnstr=[[
        class ClsA: ClsC {
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("has error", function()
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 20)
   end)
end)

describe("test failed #class", function()
    local mnstr=[[
        A = nil
        class B : A {}
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