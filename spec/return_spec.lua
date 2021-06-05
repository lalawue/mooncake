local core = require("moocscript.core")

describe("test success #return", function()
    local mnstr=[[
        while true {
            return 1, _G, "99", fn(a){}, table.remove
        }        
        if false {
            return (loadstring or load)("", "", unpack({}))
        }        
        return 0 -- hello
    ]]

    local ast = core.toAST({}, mnstr)
    it("should get ast", function()
        assert.is_table(ast)
    end)

    local code = core.toLua({}, ast)
    it("should get compiled lua", function()
        assert.is_string(code)
    end)
 
    local f = load(code, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local a = f()
        assert.is_equal(a, 1)
    end)
end)

describe("test failed #return", function()
    local mnstr=[[
        return 9
        do {
            return 1
        }
    ]]

    local ast = core.toAST({}, mnstr)
    it("should get ast", function()
        assert.is_nil(ret)
    end)
end)