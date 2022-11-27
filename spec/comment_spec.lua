local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

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
    end)

    local ret, content = compiler.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
    end)
end)

describe("test sucess #comment", function()
    local mnstr=[[
        -- and content]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
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