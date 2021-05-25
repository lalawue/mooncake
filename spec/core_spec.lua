local core = require("mn_core")

describe("test success #core", function()
    package.mnpath = package.mnpath .. ";./examples/?.mn"

    local f, err = core.loadfile("./examples/exp_class.mn")
    it("should loadfile", function()
        assert.is_function(f)
        local ClsA = f()
        assert.is_table(ClsA)
        assert.is_function(ClsA.echo)
        local ret = ClsA.echo()
        assert.is_equal(ret, "Hello, world")
    end)

    local clsa = core.dofile("./examples/exp_class.mn")
    it("should do", function()
        local ret = clsa.echo()
        assert.is_equal(ret, "Hello, world")
    end)

    it("should load lib", function()
        local ClsA = require("exp_class")
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

    it("should remove mn loader", function()
        local ret = core.removeloader()
        assert.is_true(ret)
        assert.is_nil(package.mnpath)
    end)
end)