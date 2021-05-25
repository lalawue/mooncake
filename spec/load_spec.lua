
describe("test success #loader", function()
    local match = require("luassert.match")
    local utils = require("mnscript.utils")
    stub(utils, "debug")
    stub(utils, "dump")

    local CmdLine = require("mnscript.cmdline")

    it("shoud called help", function()
        CmdLine.main()
        assert.stub(utils.debug).was.called_with(match.is_string())
    end)

    it("shoud output ast", function()
        CmdLine.main("-a", "examples/exp_all.mn")
        assert.stub(utils.dump).was.called_with(match.is_table())
    end)

    it("should output source", function()
        CmdLine.main("-s", "examples/exp_all.mn")
        assert.stub(utils.debug).was.called_with(match.is_string())        
    end)

    it("should run source", function()
        CmdLine.main("examples/exp_all.mn")
        stub(CmdLine, "run")   
        assert.is_function(CmdLine.main)        
        CmdLine.main("examples/exp_all.mn")
        assert.stub(CmdLine.run).was.called()
    end)

    it("should failed help", function()
        CmdLine.main("")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed parse", function()
        assert.is_function(CmdLine.main)
        CmdLine.main("examples/exp_failed_parse.mn")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed tocode", function()
        CmdLine.main("-s", "examples/not_exist.mn")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed compile", function()
        CmdLine.main("examples/exp_failed_compile.mn")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed run", function()
        assert.is_function(CmdLine.main)
        CmdLine.main("examples/exp_failed_run.mn")
    end)

    it("should run proj", function()
        CmdLine.main("-p", "examples/proj/proj_config.mn")
    end)

    it("should run version", function()
        CmdLine.main("-v")
    end)

    it("should run config", function()
        CmdLine.main("examples/proj/proj_config.mn")
    end)
end)