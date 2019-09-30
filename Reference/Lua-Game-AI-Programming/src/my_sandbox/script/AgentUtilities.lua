-- AgentUtilities.lua

function AgentUtilities_CreateAgentRepresentation(agent, height, radius)
    local capsule = Core.CreateCapsule(agent, height, radius)
    Core.SetMaterial(capsule, "Ground2")
end
