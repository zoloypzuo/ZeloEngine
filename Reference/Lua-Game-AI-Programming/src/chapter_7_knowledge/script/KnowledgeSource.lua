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

KnowledgeSource = {};

function KnowledgeSource.Evaluate(self, userData)
    local time = Sandbox.GetTimeInMillis(userData.agent:GetSandbox());
    local nextUpdateTime = time + self.updateFrequency_;

    -- Wait till enough time has passed to re-evaluate the knowledge source.
    if (nextUpdateTime > self.lastUpdateTime_) then
        self.lastUpdateTime_ = time;
        
        local result = self.evaluator_(userData);
        self.confidence_ = result.confidence;
        self.evaluation_ = result.evaluation;
    end
    
    return { evaluation = self.evaluation_, confidence = self.confidence_ };
end

function KnowledgeSource.new(evaluator, updateFrequency)
    local source = {};
    
    -- The KnowledgeSource's data members.
    source.confidence_ = 0;
    source.evaluation_ = nil;
    source.evaluator_ = evaluator;
    source.lastUpdateTime_ = 0;
    source.updateFrequency_ = updateFrequency or 0;
    
    -- The KnowledgeSource's accessor functions.
    source.Evaluate = KnowledgeSource.Evaluate;
    
    return source;
end