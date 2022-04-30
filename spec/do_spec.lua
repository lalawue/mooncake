local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #do #function #class #struct #call", function()
    local mnstr=[[
        do {
            fn abc() {}
            struct B {}
            do {
                class A {}
                abc()
                extension B: A {
                    fn abc() {
                        return 'dododo'
                    }
                }
            }
            return B:abc()
        }
    ]]

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
        assert.is_equal(f(), 'dododo')
    end)
end)

describe("test success #do", function()
    local mnstr=[[
        a = 2
        do {
            a = 3
            do {
                return a
            }
        }
    ]]

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
        local a = f()
        assert.is_equal(a, 3)
    end)
end)

describe("test failed #do", function()
    local mnstr=[[
        do {
            a = 2
        }
        return a
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_false(ret)
        assert.is_equal(content.err_msg, "undefined variable")
        assert.is_equal(content.pos, 56)
    end)
end)

describe("test failed #do", function()
    local mnstr=[[
    do {
         break
    }]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
         assert.is_equal(ast.err_msg, "break not in loop")
         assert.is_equal(ast.pos, 18)
    end)
end)