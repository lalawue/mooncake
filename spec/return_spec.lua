local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #return", function()
    local mnstr=[[
        while true {
            return 1, _G, "99", fn(a){}, table.remove
        }        
        if false {
            return (loadstring or load)("", "", unpack({}))
        }
        return 0 -- hello
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
        local a = f()
        assert.is_equal(a, 1)
    end)
end)

describe("test failed 1 #return", function()
    local mnstr=[[
        return 9
        do {
            return 1
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_false(ret)
        assert.is_true(type(ast) == "table")
    end)
end)

describe("test failed 2 #return", function()
    local mnstr=[[
        fn abc() {
            defer {
                return 9
            }
        }
    ]]
    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
        assert.is_true(ret)
        assert.is_true(type(ast) == "table")
    end)

    it("has error", function()
        local ret, code = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(code, "_:3:                 return 9 <defer statement can not return value 'return'>")
   end)
end)