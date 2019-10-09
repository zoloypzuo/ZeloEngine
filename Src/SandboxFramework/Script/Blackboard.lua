Blackboard = {};

local function EvaluateSources(self, sources)
    local bestConfidence = 0;
    local bestResult = nil;

    -- Since there can be multiple data source for a single blackboard
    -- attribute, return the best result based on the confidence of
    -- the knowledge source.
    for index = 1, #sources do
        local eval = sources[index]:Evaluate(self.userData_);

        if (eval.confidence > bestConfidence) then
            bestConfidence = eval.confidence;
            bestResult = eval.evaluation;
        end
    end

    return bestResult;
end

function Blackboard.AddSource(self, attribute, source)
    if (not self.sources_[attribute]) then
        self.sources_[attribute] = {};
    end

    table.insert(self.sources_[attribute], source);
end

function Blackboard.Get(self, attribute)
    -- Return the evaluated information, from a knowledge source.
    if (self.sources_[attribute]) then
        return EvaluateSources(self, self.sources_[attribute]);
    end

    -- Return stored data if there are no knowledge sources to evalute.
    return self.attributes_[attribute];
end

function Blackboard.RemoveSource(self, attribute, source)
    -- Since there can be multiple sources for the same attribute,
    -- iterate over all sources to find the correct one to remove.
    if (self.sources_[attribute]) then
        for index = 1, #self.sources_[attribute] do
            if (self.sources_[attribute][index] == source) then
                table.remove(self.sources_[attribute], index);
                return true;
            end
        end
    end

    return false;
end

function Blackboard.Set(self, attribute, value)
    self.attributes_[attribute] = value;
end

function Blackboard.new(userData)
    local blackboard = {};

    -- The Blackboard's data members.
    blackboard.attributes_ = {};
    blackboard.sources_ = {};
    blackboard.userData_ = userData;

    -- The Blackboard's accessor functions.
    blackboard.AddSource = Blackboard.AddSource;
    blackboard.Get = Blackboard.Get;
    blackboard.RemoveSource = Blackboard.RemoveSource;
    blackboard.Set = Blackboard.Set;

    return blackboard;
end