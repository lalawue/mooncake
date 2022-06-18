local parser = require("moocscript.parser")
local compile = require("moocscript.compile")
local clss = require("moocscript.class")

describe("test normal #struct", function()
    local mnstr=[[
        local struct ClsA {
            a = 11
            f = Self.a + 109
            fn init() {
                self.a = 9
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
        ClsA.b = 100
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
    it("should inherit", function()
        assert(type(f) == "function")
        local ClsA = f()
        local a = ClsA()
        assert.is_equal(ClsA.a, 11)
        assert.is_equal(ClsA.b, nil)
        assert.is_equal(ClsA.f, 120)
        assert.is_equal(a.a, 9)
        assert.is_equal(a.b, nil)
        assert.is_equal(a:takeTime(2), 108)
        a.c = 100
        assert.is_equal(a.c, nil)
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
        assert.is_equal(a.b, nil)
        assert.is_equal((ClsA + ClsA), "add")
        assert.is_equal((a + a), 666)
    end)
end)

describe("test success #struct", function()
    local mnstr=[[
        export struct Tbl {
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

    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local c = f(10)
        assert.is_equal(c, "c")
    end)
end)

describe("test create struct from lua side #struct", function()
    local mnstr=[[
        struct A {
            a = 10
            b = 'A'
            fn name() {
                return self.b
            }
            static fn Name() {
                return Self.b
            }
            static fn NName() {
                return 'A'
            }
        }
        return A
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
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

    it("should create struct B", function()
        local RestrictTableB, RawTableB = clss.newMoocStruct('B')
        RawTableB.a = false
        RawTableB.b = false
        function RawTableB:init(a, b)
            self.a = a
            self.b = b
        end
        local b = RestrictTableB(1, 2)
        assert.is_equal(tostring(b):sub(1, 10), "<struct B:")
        assert.is_equal(b.__tn, "B")
        assert.is_equal(b.a, 1)
        assert.is_equal(b.b, 2)
        b.a = nil
        b.b = nil
        assert.is_false(b.a)
        assert.is_false(b.b)
        b.a = 3
        b.b = 2
        assert.is_equal(b.a, 3)
        assert.is_equal(b.b, 2)
    end)
end)

describe("test scope #struct", function()
    local mnstr=[[
        export A
        do {
            struct A {
            }
        }
        return A
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        assert.is_table(f())
    end)
end)

describe("test tostring #struct", function()
    local mnstr=[[
        struct A {
            fn __tostring() {
                return "a"
            }
            static fn __tostring() {
                return "A"
            }
        }
        return A
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local A = f()
        local a = A()
        assert.is_equal(tostring(A), 'A')
        assert.is_equal(tostring(a), 'a')
    end)
end)

describe("test failed #struct", function()
    local mnstr=[[
        struct ClsA {
            c.d = 11
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed #struct", function()
    local mnstr=[[
        struct ClsA {
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
        assert.is_equal(content.pos, 100)
   end)
end)

describe("test failed #struct", function()
    local mnstr=[[
        class ClsB {}
        struct ClsA: ClsB {
            c.d = 11
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
         assert.is_equal(ast.err_msg, "struct can not inherit from super")
         assert.is_equal(ast.pos, 42)
    end)
end)