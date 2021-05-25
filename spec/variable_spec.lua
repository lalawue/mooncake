local parser = require("mn_parser")
local compile = require("mn_compile")

describe("test success #variable", function()
    local mnstr=[[
        c = ... and 1;

        fn_end = "9"
        
        _and = 10;
        and_ = 11
        and10 = 12;
        or_and = ( 8 )
        
        a = 2 ^ 9
        
        c =  { ... and ... }
        
        d = not c.f
        
        f = #c
        return fn_end, a, or_and, and_
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
        local e, a, o, d = f()
        assert.is_equal(e, '9')
        assert.is_equal(a, 512)
        assert.is_equal(o, 8)
        assert.is_equal(d, 11)
    end)
end)

describe("test failed #variable", function()
    local mnstr=[[
        _G._bbb = 9
        cccc.variable = 10
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:2:         cccc.variable = 10 <undefined variable 'cccc'>")
   end)    
end)