local core = require("moocscript.core")
local utils = require('moocscript.utils')

describe("test success #core", function()
    it("should loaded", function()
        assert.is_true(core.loaded())
        assert.is_equal(core.version():find('moocscript'), 1)
        --
        core.removeloader()
        assert.is_false(core.loaded())
        --
        core.appendloader()
        assert.is_true(core.loaded())
        --
        core.dofile('./moocscript/core.mooc')
        --
        local f, emsg = core.loadfile('./moocscript/core.mooc')
        assert.is_equal(f().version(), core.version())
        --
        local f, emsg = core.loadstring([[fn abc(){ return 'abc'}; return abc()]])
        assert.is_equal(f(), 'abc')
        --
        local f, emsg = core.loadbuffer([[fn abc(){ return 'abc'}; return abc()]])
        assert.is_true(f)
        f = loadstring(emsg)
        assert.is_equal(f(), 'abc')
        --
        local ast = core.toAST(nil, [[fn name(){}]])
        local code = core.toLua({fname=''}, ast)
        assert.is_equal(code,
[[local function name()
end]])
        --
        local fpath = nil
        if package.path == "./out/?.lua" then
            local content = utils.readFile('./moocscript/core.mooc')
            fpath = './out/moocscript/core.mooc'
            utils.writeFile(fpath, content)
        end
        assert.is_function(package.mooc_loaded)
        if fpath ~= nil then
            os.remove(fpath)
        end
    end)
end)