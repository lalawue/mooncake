local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #switch", function()
    local mnstr=[[
        a, b = ...;
        switch a {
        case 1:
            return 10
        case 2, 3:
            switch b {
            case 4:
                return 40
            case 5, 6:
                return 60
            default:
                return 90
            }
        default:
            return 20
        }
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

    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local a1 = f(1)
        local a2 = f(2, 4)
        local a3 = f(3)
        local a4 = f()
        assert.is_equal(a1, 10)
        assert.is_equal(a2, 40)
        assert.is_equal(a3, 90)
        assert.is_equal(a4, 20)
    end)
end)

describe("test success #switch", function()
    local mnstr=[[
        fn abc() {
            a = 0
            while a < 1000 {
                switch a {
                case 0:
                    a += 1
                    continue
                default:
                    if a == 1 {
                        a += 10
                        break
                    }
                    a += 100
                }
                a += 1000
            }
            return a
        }
        return abc()
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

    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local a = f()
        assert.is_equal(a, 1011)
    end)
end)

describe("test failed #switch", function()
    local mnstr=[[
        switch ... {
            default:
                return 10
            default:
                return 9
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, 'too much default case in switch statement')
        assert.is_equal(ast.pos, 80)
    end)
end)

describe("test failed #switch", function()
    local mnstr=[[
        a = 10
        switch a {
            case 10:
                continue
            default:
                return 10
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, 'continue not in loop')
    end)
end)