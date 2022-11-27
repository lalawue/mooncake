local parser = require("spec._tool_bridge").parser
local compiler = require("spec._tool_bridge").compiler

describe("test success #shebang", function()
    local mnstr=[[#!/usr/bin/env lua ./moocscript/core.lua

        fn echo() {
            return "hello, MoonCake !"
        }
        return echo()
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
        assert.is_true(ast.ast[1].value == "#!/usr/bin/env lua ./moocscript/core.lua")
    end)

    local ret, content = compiler.compile({ shebang = true }, ast)
    it("should get compiled lua with shebang", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    ret, content = compiler.compile({}, ast)
    it("should get compiled lua no shebang", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
    end)

    local f, err = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local a = f()
        assert.is_equal(a, "hello, MoonCake !")
    end)
end)

describe("test failed #shebang", function()
    local mnstr=[[#!/usr/bin/env lua ./moocscript/core.lua
    #!/usr/bin/env lua ./moocscript/core.lua
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "unexpected symbol near '#'")
    end)
end)