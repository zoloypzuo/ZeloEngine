Evaluator = {};

-- Type of object an Evalutor is.
Evaluator.Type = "Evaluator";

function Evaluator.Evaluate(self)
    return self.function_(self.userData_);
end

function Evaluator.new(name, evalFunction, userData)
    local evaluator = {};

    -- The Evaluator's data members.
    evaluator.function_ = evalFunction;
    evaluator.name_ = name or "";
    evaluator.type_ = Evaluator.Type;
    evaluator.userData_ = userData;

    -- The Evaluator's accessor functions.
    evaluator.evaluate_ = Evaluate;

    return evaluator;
end