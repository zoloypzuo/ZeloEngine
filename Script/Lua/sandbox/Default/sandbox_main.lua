local _M = {}

function _M.Sandbox_Initialize()
    require("scenes.scene01")

    SpawnPrefab("grid")
end

function _M.Sandbox_Update()

end

function _M.Sandbox_Finalize()

end

return _M