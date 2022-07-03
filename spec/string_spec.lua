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
        return "my name is '\(getName())' \('what')", 'but "\(getName())" \("no")'
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

    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local r1, r2 = f()
        assert.is_equal(r1, "my name is 'guess' what")
        assert.is_equal(r2, 'but "guess" no')
    end)
end)

describe("test success 3 #string", function()
    local mnstr=[=====[
        fn getName() {
            return "guess"
        }
        return "my name is \(getName()) xixi"
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

    it("should get function", function()
        local f = load(content, "test", "t")
        assert(type(f) == "function")
        local ret = f()
        assert.is_equal(ret, "my name is guess xixi")
    end)
end)

describe("test failed #string", function()
    local mnstr=[===[
        return [=[abcde]==]
    ]===]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "unfinished long string near '<eof>'")
        assert.is_equal(ast.pos, 17)
    end)

    local mnstr=[===[
        return [=<abcde]==]
    ]===]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "invalid long string delimiter")
        assert.is_equal(ast.pos, 17)
    end)

    local mnstr=[===[return "abcde]===]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_equal(ast.err_msg, "unfinished string")
        assert.is_equal(ast.pos, 13)
    end)
end)