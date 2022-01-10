local _M = {}

function _M.Sandbox_Initialize()
    InstallPlugin("EdgePipelinePlugin")
    require("scenes.scene01")
end

function _M.Sandbox_Update()

end

function _M.Sandbox_Finalize()

end

return _M