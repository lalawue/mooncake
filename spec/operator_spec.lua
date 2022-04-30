local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #operator", function()
    local mnstr=[[
        a = -2;
        a = 10.12 // 2;
        a = ~1;
        a = 1 ~ 1;
        a = 10 % 3;
        a = 2 ^ 2;
        a = 2 << 1;
        a = 3 >> 2;
        a //= 2;
        a %= 3;
        a ^= 1;
        a -= 3;
        a += 4;
        a /= 6;
        a *= 7;
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local result=
[[local a = -2;
a = 10.12 // 2;
a = ~1;
a = 1 ~ 1;
a = 10 % 3;
a = 2 ^ 2;
a = 2 << 1;
a = 3 >> 2;
a = a // 2;
a = a % 3;
a = a ^ 1;
a = a - 3;
a = a + 4;
a = a / 6;
a = a * 7;]]

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_true(ret)
        assert.is_true(type(content) == "string")
        assert.is_equal(content, result)
    end)
end)
