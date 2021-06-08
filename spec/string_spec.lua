local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #string", function()
    local mnstr=[=====[
        return 'a',
        "b",
        'ab',
        "abc",
        'ab\'cd',
        "ab\"cd",
        [[abcde]],
        [[a\]bcd]],
        [[ab'c"d]],
        [[ab
          cd]],
        [==[ab[=[ cc ]=]
            cde]==]
    ]=====]

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
        local _, _, _, _, _, _, _, _, _, _, a = f()
        assert.is_equal(a, [==[ab[=[ cc ]=]
            cde]==])
    end)
end)

describe("test success 2 #string", function()
    local mnstr=[=====[
        fn getName() {
            return "guess"
        }
        return "my name is \(getName())"
    ]=====]

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
        local ret = f()
        assert.is_equal(ret, "my name is guess")
    end)
end)

describe("test failed #string", function()
    local mnstr=[===[
        return [=[abcde]==]
    ]===]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
    end)
end)