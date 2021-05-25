
describe("test success #loader", function()
    local match = require("luassert.match")
    local utils = require("mn_utils")
    stub(utils, "debug")
    stub(utils, "dump")

    local Loader = require("mn_loader")

    it("shoud called help", function()
        Loader.main()
        assert.stub(utils.debug).was.called_with(match.is_string())
    end)

    it("shoud output ast", function()
        Loader.main("-a", "examples/exp_all.mn")
        assert.stub(utils.dump).was.called_with(match.is_table())
    end)

    it("should output source", function()
        Loader.main("-s", "examples/exp_all.mn")
        assert.stub(utils.debug).was.called_with(match.is_string())        
    end)

    it("should run source", function()
        Loader.main("examples/exp_all.mn")
        stub(Loader, "run")   
        assert.is_function(Loader.main)        
        Loader.main("examples/exp_all.mn")
        assert.stub(Loader.run).was.called()
    end)

    it("should failed help", function()
        Loader.main("")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed parse", function()
        assert.is_function(Loader.main)
        Loader.main("examples/exp_failed_parse.mn")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed tocode", function()
        Loader.main("-s", "examples/not_exist.mn")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed compile", function()
        Loader.main("examples/exp_failed_compile.mn")
        assert.stub(utils.debug).was.called()
    end)

    it("should failed run", function()
        assert.is_function(Loader.main)
        Loader.main("examples/exp_failed_run.mn")
    end)

    it("should run proj", function()
        Loader.main("-p", "examples/proj/proj_config.mn")
    end)

    it("should run version", function()
        Loader.main("-v")
    end)

    it("should run config", function()
        Loader.main("examples/proj/proj_config.mn")
    end)
end)