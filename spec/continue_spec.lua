local parser = require("mn_parser")
local compile = require("mn_compile")

describe("test success #continue", function()
    local mnstr=[[
        i = 1
        for i=1, 20, 1 {
            if i < 15 {
                continue
            }
            if i > 18 {
                continue
            }
        }
        
        while true {
            i += 1
            if i < 15 {
                continue
            }
            if i < 18 {
                continue
            }
            if i >= 20 {
                break
            }
        }
        
        repeat {
            i += 1
            if i < 15 {
                continue
            }
            if i < 18 {
                continue
            }
            if i >= 20 {
                break
            }
        } until i >= 20
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
        local ClsA, ClsB = f()
    end)
end)

describe("test success #continue", function()
    local mnstr=[[
        fn testContinue(a) {
            for i=a, 20, 1 {
                if i < 10 {
                    continue
                }
                elseif i > 15 {
                    continue
                }
                else {
                    return i
                }
            };
            return 0
        }
        return testContinue
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
        local fn = f()
        assert.is_equal(fn(8), 10)
        assert.is_equal(fn(16), 0)
    end)
end)

describe("test failed #continue", function()
    local mnstr=[[
        fn failedContinue(a) {
            if a < 2 {
                continue
            }
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
        assert.is_equal(content, "_:3:                 continue <not in loop 'continue'>")
   end)
end)