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

DebugUtilities = {};
DebugUtilities.Black = Vector.new(0, 0, 0);
DebugUtilities.Blue = Vector.new(0, 0, 1);
DebugUtilities.Green = Vector.new(0, 1, 0);
DebugUtilities.Orange = Vector.new(1, 0.5, 0);
DebugUtilities.Red = Vector.new(1, 0, 0);
DebugUtilities.White = Vector.new(1, 1, 1);

function DebugUtilities_DrawPath(path, cyclic, offset, color)
    assert(type(path) == "table");
    
    color = color or DebugUtilities.Red;
    offset = offset or Vector.new();
    
    for index = 1, #path do
        local endPoint;
    
        if (index == #path) then
            if (cyclic == nil or not cyclic) then
                break;
            end
            endPoint = path[1];
        else
            endPoint = path[index + 1];
        end
        
        local startPoint = path[index];
        
        Core.DrawLine(
            startPoint + offset, endPoint + offset, color);
    end
end

function DebugUtilities_DrawPaths(agents)
    for index, agent in pairs(agents) do
        if (agent:GetHealth() > 0) then
            local path = agent:GetPath();
        
            if (#path > 0) then
                -- Draw the agent's cyclic path, offset slightly above the level
                -- geometry.
                DebugUtilities_DrawPath(
                    path, false, Vector.new(0, 0.02, 0));
                Core.DrawSphere(
                    agent:GetTarget(), 0.1, DebugUtilities.Red, true);
            end
        end
    end
end

function DebugUtilities_DrawBoundingSphere(object)
    Core.DrawSphere(
        Core.GetPosition(object),
        Core.GetRadius(object),
        DebugUtilities.Red,
        true);
end

function DebugUtilities_DrawBoundingSpheres(objects)
    for index = 1, #objects do
        DebugUtilities_DrawBoundingSphere(objects[index]);
    end
end

function DebugUtilities_DrawBoundingSpheres(objects)
    for index = 1, #objects do
        DebugUtilities_DrawBoundingSphere(objects[index]);
    end
end

function DebugUtilities_DrawDynamicBoundingSpheres(objects)
    for index = 1, #objects do
        if Core.GetMass(objects[index]) > 0 then
            DebugUtilities_DrawBoundingSphere(objects[index]);
        end
    end
end
