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