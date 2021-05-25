local parser = require("mn_parser")
local compile = require("mn_compile")

describe("test success #comment", function()
    local mnstr=[=[
        --[===[ hello, world
        ]===]
        --[[aa
        bb]]
        -- end of file
    ]=]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
        for i, v in ipairs(ast.ast) do
            assert.is_equal(v.stype, "cm")
        end
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

describe("test failed #comment", function()
    local mnstr=[[
        --[=[ aabb
        cd]==]
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)