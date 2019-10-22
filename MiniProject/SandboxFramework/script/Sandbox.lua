-- Sandbox.lua
-- 2019年10月8日
-- author@zoloypzuo
--
-- 寻路
-- Sandbox.FindPath
-- Sandbox.RandomPoint
--
-- 路径信息
-- 离智能体最近的导航点 nearest = Agent.GetNearestPointOnPath(agent, agent:GetPosition())
-- 离出发点的通行距离（即智能体已经走了多远了） offset = Agent.GetDistanceAlongPath(agent, nearest)
-- 得到一个路径点 point = Agent.GetPointOnPath(agent, distance + offset)


local Sandbox_C_Module = Sandbox

---@class Sandbox @沙箱框架
local Sandbox = Class(function(self)

end)

--{{{Create*
---@type fun() @创建平面，指定宽度，高度；并创建半空间并添加到物理模拟中
---@param sandbox Sandbox
---@param width number
---@param height number
---@return nil
function Sandbox:CreatePlane(width, height)
    return Sandbox_C_Module.CreatePlane(self, width, height)
end

---@type fun() @创建天空盒，指定材质名和rotation，以欧拉角，以角度
--- 天空盒的ogre材质位于media/materials/skybox.material
--- Sandbox.CreateSkyBox(sandbox, "ThickCloudsWaterSkyBox", Vector.new(0, 180, 0));
function Sandbox:CreateSkyBox(s, vector)
    return Sandbox_C_Module.CreateSkyBox(self, s, vector)
end

---@type fun() @local agent = Sandbox.CreateAgent(sandbox, "Agent.lua")
function Sandbox.CreateAgent(sandbox, scriptPath)

end

function Sandbox.CreateObject(sandbox, meshPath)

end
function Sandbox.CreateAgent(sandbox)
end
function Sandbox.CreateBox(sandbox)
end
function Sandbox.CreateCapsule(sandbox)
end
function Sandbox.CreateInfluenceMap(sandbox)
end
function Sandbox.CreateNavigationMesh(sandbox)
end
function Sandbox.CreateObject(sandbox)
end
function Sandbox.CreatePhysicsCapsule(sandbox)
end
function Sandbox.CreatePhysicsSphere(sandbox)
end
function Sandbox.CreatePlane(sandbox)
end
function Sandbox.CreateSkyBox(sandbox)
end
function Sandbox.CreateUIComponent(sandbox)
end

-- 这个和上面的CreateUIComponent都是返回一个UIComponent
-- 相当于参数列表重载
-- 这个函数，lua层没有脚本用过
function Sandbox.CreateUIComponent3d(sandbox)
end
--}}}

--{{{Get*
function Sandbox.GetCameraPosition(sandbox)

end

function Sandbox.GetCameraForward(sandbox)

end

function Sandbox.GetCameraOrientation(sandbox)

end

function Sandbox.GetAgents(sandbox)
end
function Sandbox.GetCameraForward(sandbox)
end
function Sandbox.GetCameraLeft(sandbox)
end
function Sandbox.GetCameraOrientation(sandbox)
end
function Sandbox.GetCameraPosition(sandbox)
end
function Sandbox.GetCameraUp(sandbox)
end
function Sandbox.GetDrawPhysicsWorld(sandbox)
end
function Sandbox.GetInertia(sandbox)
end
function Sandbox.GetMarkupColor(sandbox)
end
function Sandbox.GetObjects(sandbox)
end
function Sandbox.GetRenderTime(sandbox)
end
function Sandbox.GetSimulationTime(sandbox)
end
function Sandbox.GetTotalSimulationTime(sandbox)
end
function Sandbox.GetScreenHeight(sandbox)
end
function Sandbox.GetScreenWidth(sandbox)
end
function Sandbox.GetTimeInSeconds(sandbox)
end
function Sandbox.GetTimeInMillis(sandbox)
end
--}}}

--{{{Set*
function Sandbox.SetAmbientLight(sandbox)
end
function Sandbox.SetCameraForward(sandbox)
end
function Sandbox.SetCameraOrientation(sandbox)
end
function Sandbox.SetCameraPosition(sandbox)
end
function Sandbox.SetDebugNavigationMesh(sandbox)
end
function Sandbox.SetDrawInfluenceMap(sandbox)
end
function Sandbox.SetDrawPhysicsWorld(sandbox)
end
function Sandbox.SetFalloff(sandbox)
end
function Sandbox.SetInertia(sandbox)
end
function Sandbox.SetInfluence(sandbox)
end
function Sandbox.SetMarkupColor(sandbox)
end
--}}}

--{{{其他
function Sandbox.AddCollisionCallback(sandbox)
end
function Sandbox.AddEvent(sandbox)
end
function Sandbox.AddEventCallback(sandbox)
end
function Sandbox.ClearInfluenceMap(sandbox)
end
function Sandbox.DrawInfluenceMap(sandbox)
end
function Sandbox.FindClosestPoint(sandbox)
end

-- 仅考虑几何距离，返回最短路径（不考虑通行代价）
-- 返回一个waypoints列表，如果不存在路径返回空表
-- path = Sandbox.FindPath(sandbox, "default", startPoint, endPoint)
function Sandbox.FindPath(sandbox)
end

-- 在nav-mesh上返回一个随机的点
-- randomPoint = Sandbox.RandomPoint(sandbox, "default")
function Sandbox.RandomPoint(sandbox)
end
function Sandbox.RayCastToObject(sandbox)
end
function Sandbox.RemoveObject(sandbox)
end

function Sandbox.SpreadInfluenceMap(sandbox)
end
--}}}
return Sandbox
