-- local core = require("moocscript.core")

-- describe("test success #core", function()
--     package.path = package.path .. ";./spec/?.lua"

--     it("should loadfile", function()
--         local f, err = core.loadfile("./spec/_success_class.mooc")        
--         core.appendloader()
--         assert.is_function(f)
--         local ClsA = f()
--         assert.is_table(ClsA)
--         assert.is_function(ClsA.echo)
--         local ret = ClsA.echo()
--         assert.is_equal(ret, "Hello, world")
--     end)

--     local clsa = core.dofile("./spec/_success_class.mooc")
--     it("should do", function()
--         local ret = clsa.echo()
--         assert.is_equal(ret, "Hello, world")
--     end)

--     it("should load lib", function()
--         local ClsA = require("_success_class")
--         assert.is_table(ClsA)
--         assert.is_function(ClsA.echo)
--         local ret = ClsA.echo()
--         assert.is_equal(ret, "Hello, world")
--     end)

--     it("should load ast failed", function()
--         assert.has_error(function()
--             require("_failed_parse")
--         end)
--     end)

--     it("should load compile failed", function()
--         assert.has_error(function()
--             require("_failed_compile")
--         end)
--     end)

--     it("should remove loader", function()
--         local ret = core.removeloader()
--         assert.is_true(ret)
--         assert.is_false(core.loaded())
--         ret = core.removeloader()
--         assert.is_nil(ret)
--     end)

--     it("should get version", function()
--         local ret = core.version()
--         assert.is_equal(ret:find("moocscript"), 1)
--     end)

--     it("should failed toAST", function()
--         local _, emsg = core.toAST({}, {})
--         assert.is_equal(emsg, "expecting string (got table)")
--     end)

--     it("should failed compile", function()
--         local _, emsg = core.toLua({}, "")
--         assert.is_equal(emsg, "Invalid data")
--     end)

--     it("should failed loadfile", function()
--         local _, emsg = core.loadfile("not_exist_lib")
--         assert.is_equal(emsg, "not_exist_lib: No such file or directory")
--     end)

--     it("should loadstring parse failed", function()
--         local mnstr=[[
--             and = 10
--         ]]
--         local ret = core.loadstring(mnstr, "mnstr")
--         assert.is_equal(ret, "parse error mnstr:1:             and = 10")
--     end)

--     it("should loadstring compile failed", function()
--         core.appendloader()
--         local emsg = core.loadstring("if true { break }", "mnstr")
--         assert.is_equal(emsg, "mnstr:1: if true { break } <not in loop 'break'>")
--     end)
-- end)