local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

describe("test success #for", function()
    local mnstr=[[
        for i = 0, 2 {
            j = 2 * 2 / (3 * 4)
        }

        fn fstep() {
            return 1
        }

        fn ftotal() {
            return 10
        }
        
        for j = 9, ftotal(), fstep() {
            j = 7 * 7 + 3
        }
        
        for k, v in ipairs(_G) {
            print(k, v)
        }
        
        for k in ipairs(_G) {
            print(k);
        };

        for k, v in next, _G {
            break
        }

        fn _next(t) {
            return next(t)
        }

        for k, v in (_next or next), _G {
            break
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
 
    local f = load(content, "test", "t")
    it("should get function", function()
        assert(type(f) == "function")
        f()
    end)
end)

describe("test failed #for", function()
    local mnstr=[[
        for f.c = 1, 2 {
            print(f.c)
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
    end)
end)

describe("test failed #for", function()
    local mnstr=[[
        for k, v = next, _G, 1, 2 {
            print(k)
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_false(ret)
         assert.is_true(type(ast) == "table")         
    end)
end)