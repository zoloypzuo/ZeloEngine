---@class Core @TODO
local Core = {}

Core.CreateDirectionalLight()

---@type fun() @ 设置ogre材质，于media/materials/base.material中定义
--- Core.SetMaterial(plane, "Ground2")
---@param o any
---@param s string
---@return nil
function Core.SetMaterial(o, matPath)
end

---@type fun() @创建平行光，指定方向
--- local directional = Core.CreateDirectionalLight(sandbox, Vector.new(1, -1, 1))
function Core.CreateDirectionalLight(sandbox, vector)

end

---@type fun() @漫反射
--- Core.SetLightDiffuse(directional, Vector.new(1.8, 1.4, 0.9))
function Core.SetLightDiffuse(directional, vector)

end

---@高光颜色
--- Core.SetLightSpecular(directional, Vector.new(1.8, 1.4, 0.9))
function Core.SetLightSpecular(directional, vector)

end

--- @Core.CreateMesh(sandbox, "models/nobiax_modular/modular_block.mesh")
function Core.CreateMesh(sandbox, meshPath)
end

function Core.SetMass(o, mass)
end

---@Core.SetPosition(mesh, Vector.new(0, 1, 0))
function Core.SetPosition(mesh, v)
end

--- @Core.SetRotation(mesh, Vector.new(0, 45, 0))
function Core.SetRotation(mesh, v)
end

---@local capsule = Core.CreateCapsule(agent, height, radius)
function Core.CreateCapsule(agent, height, radius)
end

--{{{
-- Core.lua
function Core.__towatch(agent)
end
function Core.ApplyForce(agent)
end
function Core.ApplyImpulse(agent)
end
function Core.ApplyAngularImpulse(agent)
end
function Core.CacheResource(agent)
end
function Core.IsVisisble(agent)
end
function Core.Remove(agent)
end
function Core.ResetParticle(agent)
end

---}}}

--{{{Create*
function Core.CreateBox(agent)
end
function Core.CreateCapsule(agent)
end
function Core.CreateCircle(agent)
end
function Core.CreateCylinder(agent)
end
function Core.CreateDirectionalLight(agent)
end
function Core.CreateLine(agent)
end
function Core.CreateMesh(agent)
end
function Core.CreateParticle(agent)
end
function Core.CreatePlane(agent)
end
function Core.CreatePointLight(agent)
end
--}}}

--{{{Draw*
function Core.DrawCircle(agent)
end
function Core.DrawLine(agent)
end
function Core.DrawSphere(agent)
end
function Core.DrawSquare(agent)
end
--}}}

--{{{Set*
function Core.SetAxis(agent)
end
function Core.SetGravity(agent)
end
function Core.SetLightDiffuse(agent)
end
function Core.SetLightRange(agent)
end
function Core.SetLightSpecular(agent)
end
function Core.SetLineStartEnd(agent)
end
function Core.SetMass(agent)
end
function Core.SetMaterial(agent)
end
function Core.SetParticleDirection(agent)
end
function Core.SetPosition(agent)
end
function Core.SetRotation(agent)
end
function Core.SetVisisble(agent)
end
--}}}

--{{{Get*
function Core.GetMass(agent)
end
function Core.GetPosition(agent)
end
function Core.GetRadius(agent)
end
function Core.GetRotation(agent)
end
--}}}
return Core