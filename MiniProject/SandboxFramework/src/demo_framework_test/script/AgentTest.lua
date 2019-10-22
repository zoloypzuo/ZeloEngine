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

function Sandbox_TestAgent(sandbox)
    -- The agent will already be initialized before being returned.
    local agent = Sandbox.CreateAgent(sandbox, "Tutorial for EmmyDoc.lua");
    
    local forward = agent:GetForward();
    local mass = agent:GetMass();
    local maxForce = agent:GetMaxForce();
    local maxSpeed = agent:GetMaxSpeed();
    local position = agent:GetPosition();
    local radius = agent:GetRadius();
    local speed = agent:GetSpeed();
    local velocity = agent:GetVelocity();
    
    local seekForce = agent:SeekForceToPosition(Vector.new(10, 0, 0));
    local fleeForce = agent:FleeForceFromPosition(Vector.new(10, 0, 0));
    
    agent:SetMass(mass);
    agent:SetPosition(position);
    agent:SetRadius(radius);
    agent:SetSpeed(speed);
    agent:SetMaxForce(maxForce);
    agent:SetMaxSpeed(maxSpeed);
    
    -- test calls from the "Agent" package
    Agent.SetSpeed(agent, speed);
    return;
end
