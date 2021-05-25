local parser = require("mn_parser")
local compile = require("mn_compile")

describe("test success #function", function()
    local mnstr=[[
        local fn sub(a, b) {
            return a - b
        }

        export fn devide(...) {
        }

        fn add( d, f, ...) {
        }
        return sub, devide, add
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
        local sub, devide, add = f()
        assert.is_function(sub)
        assert.is_function(devide)
        assert.is_function(add)
        assert.is_equal(sub(12, 10), 2)        
    end)
end)

describe("test success #function", function()
    local mnstr=[[
        local tbl = {  }
        tbl.__index = tbl
        tbl.a  = tbl
        tbl.b = fn() {
            return tbl
        };
        tbl.c = fn() {
            return "c"
        }
        return tbl.a.a:b():c()
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
        local c = f()
        assert.is_equal(c, "c")     
    end)
end)

describe("test failed #function", function()
    local mnstr=[[
        fn b.sub() {
            return 0
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:1:         fn b.sub() { <undefined variable 'b'>")
   end)
end)

describe("test failed #function", function()
    local mnstr=[[
        fn sub() {
            return self
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:2:             return self <undefined variable 'self'>")
   end)
end)