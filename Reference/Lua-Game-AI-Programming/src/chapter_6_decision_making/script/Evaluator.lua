-- Evaluator.lua
-- 2019年10月8日

-- 求值器
-- 求值器是决策，它的输入是userdata，代表决策需要的信息，输出是bool
-- 求值器是函数式的，行为树跑多少次都要有确定性的结果，所以尽管可以，求值器禁止修改userdata
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