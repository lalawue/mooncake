local core = require("moocscript.core")

describe("test success #core", function()
    package.path = package.path .. ";./spec/?.lua"

    local f, err = core.loadfile("./spec/_success_class.mooc")
    it("should loadfile", function()
        assert.is_function(f)
        local ClsA = f()
        assert.is_table(ClsA)
        assert.is_function(ClsA.echo)
        local ret = ClsA.echo()
        assert.is_equal(ret, "Hello, world")
    end)

    local clsa = core.dofile("./spec/_success_class.mooc")
    it("should do", function()
        local ret = clsa.echo()
        assert.is_equal(ret, "Hello, world")
    end)

    it("should load lib", function()
        local ClsA = require("_success_class")
        assert.is_table(ClsA)
        assert.is_function(ClsA.echo)
        local ret = ClsA.echo()
        assert.is_equal(ret, "Hello, world")
    end)

    it("should parse failed", function()
        local mnstr=[[
            and = 10
        ]]
        local ret = core.loadstring(mnstr, "mnstr")
        assert.is_equal(ret, "parse error mnstr:1:             and = 10")
    end)

    it("should remove loader", function()
        local ret = core.removeloader()
        assert.is_true(ret)
        assert.is_false(core.loaded())
    end)
end)