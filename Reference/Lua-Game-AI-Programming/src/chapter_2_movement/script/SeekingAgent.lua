-- p48

require "AgentUtilities";

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
end

function Agent_Initialize(agent)
    AgentUtilities_CreateAgentRepresentation(
            agent, agent:GetHeight(), agent:GetRadius());

    -- Assign a default target and acceptable target radius.
    agent:SetTarget(Vector.new(50, 0, 0));
    agent:SetTargetRadius(1.5);
end

function Agent_Update(agent, deltaTimeInMillis)
    local destination = agent:GetTarget();
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;
    local avoidAgentForce = agent:ForceToAvoidAgents(1.5);
    local avoidObjectForce = agent:ForceToAvoidObjects(1.5);
    local seekForce = agent:ForceToPosition(destination);
    local targetRadius = agent:GetTargetRadius();
    local radius = agent:GetRadius();
    local position = agent:GetPosition();
    local avoidanceMultiplier = 3;

    -- Sum all forces and apply higher priorty to avoidance forces.
    local steeringForces = seekForce +
            avoidAgentForce * avoidanceMultiplier +
            avoidObjectForce * avoidanceMultiplier;

    -- Apply all steering forces.
    AgentUtilities_ApplyPhysicsSteeringForce(
            agent, steeringForces, deltaTimeInSeconds);
    AgentUtilities_ClampHorizontalSpeed(agent);

    local targetRadiusSquared = (targetRadius + radius) * (targetRadius + radius);

    -- Calculate the position where the Agent touches the ground.
    local adjustedPosition = agent:GetPosition() -
            Vector.new(0, agent:GetHeight() / 2, 0);

    -- 到达目标，重新随机选择目标
    -- If the agent is within the target radius pick a new 
    -- random position to move to.
    if (Vector.DistanceSquared(adjustedPosition, destination) <
            targetRadiusSquared) then

        -- New target is within the 100 meter squared movement space.
        local target = agent:GetTarget();
        target.x = math.random(-50, 50);
        target.z = math.random(-50, 50);

        agent:SetTarget(target);
    end

    --
    -- 调试信息
    --

    -- Draw debug information for target and target radius.
    Core.DrawCircle(
            destination, targetRadius, Vector.new(1, 0, 0));
    Core.DrawLine(position, destination, Vector.new(0, 1, 0));

    -- Debug outline representing the space the Agent can move
    -- within.
    Core.DrawSquare(Vector.new(), 100, Vector.new(1, 0, 0));
end
