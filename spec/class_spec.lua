local parser = require("mnscript.parser")
local compile = require("mnscript.compile")

describe("test normal #class", function()
    local mnstr=[[
        local class ClsA {
            a = 11
            fn init() {
                self.b = 0
            }
            fn takeTime(c) {
                return self.a + 101 - c
            }
            fn deinit() {
            }
            class fn __add(a, b) {
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
            class fn runAway(a) {
                return Self.b + a
            }
            fn takeTime(c, d) {
                return c + d * 2
            }
            fn change(a) {
                Self.a = a
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
        assert.is_equal(ClsA.a, 11)
        assert.is_equal(ClsA.b, nil)
        assert.is_equal(ClsB.b, 1206)
        assert.is_equal(ClsB.runAway(10), 1216)
        local b = ClsB()
        assert.is_equal(b:takeTime(1, 2), 5)
        b:change(99)
        assert.is_equal(ClsB.a, 99)
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
        assert.is_equal(a.b, 0)
        assert.is_equal((ClsA + ClsA), "add")
        assert.is_equal((a + a), 666)
    end)
end)

describe("test success #class", function()
    local mnstr=[[
        class Tbl {
            a = Tbl
    
            class fn b() {
                return Tbl
            }
        
            class fn c() {
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
            class fn takeTime(c) {
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
        assert.is_equal(content, "_:4:                 return self.a + 101 - c <undefined variable 'self'>")
   end)
end)