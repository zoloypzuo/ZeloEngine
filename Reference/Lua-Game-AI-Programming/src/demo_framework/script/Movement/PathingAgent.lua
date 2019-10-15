require "AgentUtilities";
require "DebugUtilities";

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
end

function Agent_Initialize(agent)
    AgentUtilities_CreateAgentRepresentation(
            agent, agent:GetHeight(), agent:GetRadius());

    -- Randomly assign a position to the agent.
    agent:SetPosition(
            Vector.new(math.random(-50, 50), 0, math.random(-50, 50)));
end

function Agent_Update(agent, deltaTimeInMillis)
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;

    -- Force to continue moving along the path, can cause the agent to
    -- veer away from the path.
    local followForce = agent:ForceToFollowPath(1.25);

    -- Force to move to the closest point on the path.
    local stayForce = agent:ForceToStayOnPath(1);

    -- Slight deviation force to alleviate bumping other pathing agents.
    local wanderForce = agent:ForceToWander(deltaTimeInMillis);

    -- Sum steering forces using scalars.
    local totalForces = Vector.Normalize(followForce) +
            Vector.Normalize(stayForce) * 0.25 +
            Vector.Normalize(wanderForce) * 0.25;

    local targetSpeed = 3;

    -- Accelerate pathing agents to a minimum speed.
    if (agent:GetSpeed() < targetSpeed) then
        local speedForce = agent:ForceToTargetSpeed(targetSpeed);
        totalForces = totalForces + Vector.Normalize(speedForce);
    end

    -- Apply the summation of all forces.
    AgentUtilities_ApplyPhysicsSteeringForce(agent, totalForces, deltaTimeInSeconds);
    AgentUtilities_ClampHorizontalSpeed(agent);

    -- Draw the agent's path as a looping path.
    DebugUtilities_DrawPath(agent:GetPath(), true);
end
