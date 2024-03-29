local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #break", function()
    local mnstr=[[
        for i=1, 20, 1 {
            if i < 15 {
                break
            }
            print(i)
        }

        i = 2
        while true {
            i += 1
            if i < 15 {
                break
            }
            print(i)
        }

        repeat {
            i += 1
            if i < 15 {
                break
            }
            print(i)
        } until i >= 20
    ]]

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

describe("test failed #break", function()
    local mnstr=[[
        fn test() {
            break
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
         assert.is_equal(ast.err_msg, 'break not in loop or switch')
    end)
end)