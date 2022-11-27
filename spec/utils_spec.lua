local parser = require("spec._tool_bridge").parser

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

    local utils = require("moocscript.utils")
    stub(utils, "debug")

    it("should get compiled lua", function()
        utils.dump(ast.ast)
        assert.stub(utils.debug).was.called()
    end)

    it("should write file", function()
        local path = "_____out.txt"
        utils.writeFile(path, "111222")
        local content = utils.readFile(path)
        assert.is_equal(content, "111222")
        os.remove(path)
    end)

    it("should copy table", function()
        local t1 = {1, 3, a = 2 }
        local t2 = utils.copy(t1)
        for i, v in ipairs(t1) do
            assert.is_equal(t2[i], t1[i])
        end
        for k, v in ipairs(t1) do
            assert.is_equal(t2[k], t1[k])
        end
    end)

    it("should suffix", function()
        assert.is_equal(utils.suffix("aaa.lua"), "lua")
        assert.is_equal(utils.suffix("aaa.mooc"), "mooc")
        assert.is_equal(utils.suffix("abcdef"), "")
    end)

    it("should split", function()
        local mnstr=[[123 456]]
        local arr = utils.split(mnstr, ' ')
        assert.is_equal(arr[1], "123")
        assert.is_equal(arr[2], "456")
    end)

    it("should strim", function()
        local mnstr=[[ 123  ]]
        local ret = utils.trim(mnstr)
        assert.is_equal(ret, '123')
    end)

    local mnstr=[[defer {}]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        local errmsg = utils.errorMessage(mnstr, ast.pos, ast.err_msg, '--')
        assert.is_equal(errmsg:find('Error: defer only support function scope'), 1)
    end)
end)