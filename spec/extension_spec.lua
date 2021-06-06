local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

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
        assert.is_equal(content, "_:3:         extension ClsA: StructB {             <undefined variable 'ClsA'>")
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
        assert.is_equal(content, "_:3:         extension ClsA: StructB {             <undefined variable 'StructB'>")
    end)    
end)