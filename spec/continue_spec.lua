local parser = require("moocscript.parser")
local compile = require("moocscript.compile")

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
            for i=1, 20 {
                if i < a {
                    continue
                }
                for j=20, 1, -1 {
                    if j > a {
                        continue
                    }
                    do {
                        return i + j + a
                    }
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
        local f = f()
        assert.is_equal(f(8), 24)
        assert.is_equal(f(16), 48)
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
         assert.is_false(ret)
         assert.is_equal(ast.err_msg, "continue not in loop")
    end)
end)

describe("test sucess return #continue", function()
    local mnstr=[[
        fn failedContinue(a) {
            for i=1, 2 {
                if a < 2 {
                    continue
                }
                return a
            }
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)

    it("compile success", function()
        local ret, content = compile.compile({}, ast)
        assert.is_true(ret)
   end)
end)

describe("test success break #continue", function()
    local mnstr=[[
        fn failedContinue(a) {
            for i=1, 2 {
                if a < 2 {
                    continue
                }
                break
            }
        }
    ]]

    local ret, ast = parser.parse(mnstr)
    it("should get ast", function()
         assert.is_true(ret)
         assert.is_true(type(ast) == "table")
    end)

    it("compile success", function()
        local ret, content = compile.compile({}, ast)
        assert.is_true(ret)
   end)
end)