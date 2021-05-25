local parser = require("mnscript.parser")


describe("test success #utils", function()
    local mnstr=[[
        c = ... and 1

        fn_end = "9"
        
        _and = 10
        and_ = 11
        and10 = 12
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

    local utils = require("mnscript.utils")
    stub(utils, "debug")

    it("should get compiled lua", function()
        utils.dump(ast.ast)
        assert.stub(utils.debug).was.called()
    end)
end)