local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success 1 #export", function()
    local mnstr=[[
        local aa
        local b, c
        local d, e, f = 1, {2}, fn() {}
        local fn call(b, c) {
            return b
        }
        
        export a
        export b, c
        export d, e, f = "h", { c : "y", d : b }, _ENV
        export fn closeDoor(d, e) {
            return e
        }
        return d, e, closeDoor
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
 
    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        local d, e, c = f()
        assert.is_equal(d, "h")
        assert.is_equal(e.c, "y")
        assert.is_equal(c(11, 10), 10)
    end)
end)

describe("test success 2 #export", function()
    local mnstr=[[
        fn testScope() {
            export *
            return outer_a + outer_b
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
end)

describe("test failed 1 #export", function()
    local mnstr=[[
        local import b from "cc"
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed 2 #export", function()
    local mnstr=[[
        fn testScope() {
            while false {
                export *
            }
            return outer_a
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    local ret, content = compile.compile({}, ast)
    it("should get compiled lua", function()
        assert.is_false(ret)
        assert.is_equal(content, "_:5:             return outer_a <undefined variable 'outer_a'>")
    end)
end)