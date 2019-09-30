--[[
  Copyright (c) 2013 David Young dayoung@goliathdesigns.com

  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]

function AgentUtilities_ApplyPhysicsSteeringForce(agent, steeringForce, deltaTimeInSeconds)
    steeringForce.y = 0;
    
    -- Maximize the steering force, essentially forces the agent to max acceleration.
    steeringForce = Vector.Normalize(steeringForce) * agent:GetMaxForce();

    -- Apply force to the physics representation.
    agent:ApplyForce(steeringForce);

    -- Newtons(kg*m/s^2) divided by mass(kg) results in acceleration(m/s^2).
    local acceleration = steeringForce / agent:GetMass();
    
    -- Velocity is measured in meters per second(m/s).
    local currentVelocity = agent:GetVelocity();
    
    -- Acceleration(m/s^2) multiplied by seconds results in velocity(m/s).
    local newVelocity = currentVelocity + (acceleration * deltaTimeInSeconds);

    -- Point the agent in the direction of movement.
    -- NOTE: This implies that agent's can immediately turn in any direction.
    newVelocity.y = 0;
    
    agent:SetForward(newVelocity);
end

function AgentUtilities_ApplySteeringForce2(
    agent, steeringForce, accelerationAccumulator, deltaTimeInSeconds)

    -- Ignore very weak steering forces.
    if (Vector.LengthSquared(steeringForce) < 0.1) then
        return;
    end
    
    -- Agents with 0 mass are immovable.
    if (agent:GetMass() <= 0) then
        return;
    end

    -- Zero out any steering changes in the y axis.
    steeringForce.y = 0;
    
    -- Maximize the steering force, essentially forces the agent to max
    -- acceleration.
    steeringForce = Vector.Normalize(steeringForce) * agent:GetMaxForce();
    
    -- Newtons(kg*m/s^2) divided by mass(kg) results in acceleration(m/s^2).
    local acceleration = steeringForce / agent:GetMass();
    
    -- Interpolate to the new acceleration to dampen jitter in velocity and
    -- forward direction.
    acceleration = accelerationAccumulator +
        (acceleration - accelerationAccumulator) * 0.4;
    
    -- Reassign the new acceleration back to the accumulator.
    accelerationAccumulator.x = acceleration.x;
    accelerationAccumulator.y = acceleration.y;
    accelerationAccumulator.z = acceleration.z;
    
    -- Calculate the new velocity in (m/s)
    local velocity = agent:GetVelocity() + (acceleration * deltaTimeInSeconds);
    
    -- Assign the velocity directly, and orient toward the movement.
    agent:SetVelocity(velocity);
    
    -- Prevent trying to set the forward to a Zero vector.
    if (Vector.LengthSquared(velocity) > 0.1) then
        velocity.y = 0;
        
        -- Interpolate to the new forward direction to dampen jitter.
        local forward = agent:GetForward();
        forward = forward + (Vector.Normalize(velocity) - forward) * 0.2;
        agent:SetForward(forward);
    end
end

function AgentUtilities_ClampHorizontalSpeed(agent)
    local velocity = agent:GetVelocity();
    local downwardVelocity = velocity.y;
    velocity.y = 0;
    
    local maxSpeed = agent:GetMaxSpeed();
    local squaredSpeed = maxSpeed * maxSpeed;
    
    if (Vector.LengthSquared(velocity) > squaredSpeed) then
        local newVelocity = Vector.Normalize(velocity) * maxSpeed;
        newVelocity.y = downwardVelocity;
        
        agent:SetVelocity(newVelocity);
    end
end

function AgentUtilities_CreateAgentRepresentation(agent, height, radius)
    local capsule = Core.CreateCapsule(agent, height, radius);
    Core.SetMaterial(capsule, "Ground2");
end

function AgentUtilities_DrawLineToTarget(agent)
    Core.DrawLine(
        agent:GetPosition(), agent:GetTarget(), Vector.new(0, 1, 0));
end

function AgentUtilities_DrawTargetRadius(agent)
    Core.DrawCircle(
        agent:GetTarget(), agent:GetTargetRadius(), Vector.new(1, 0, 0));
end
