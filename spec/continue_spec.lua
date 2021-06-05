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
        local fn = f()
        assert.is_equal(fn(8), 24)
        assert.is_equal(fn(16), 48)
    end)
end)

describe("test failed 1 #continue", function()
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

describe("test failed return #continue", function()
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

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:6:                 return a <try do { return } for continue will insert label after 'return'>")
   end)
end)

describe("test failed break #continue", function()
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

    it("has error", function()
        local ret, content = compile.compile({}, ast)
        assert.is_false(ret)
        assert.is_equal(content, "_:6:                 break <try do { break } for continue will insert label after 'break'>")
   end)
end)