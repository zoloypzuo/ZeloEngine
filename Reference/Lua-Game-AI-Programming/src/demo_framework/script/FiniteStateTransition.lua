FiniteStateTransition = {};

function FiniteStateTransition.new(toStateName, evaluator)
    local transition = {};

    -- The FiniteStateTransition's data members.
    transition.evaluator_ = evaluator;
    transition.toStateName_ = toStateName;

    return transition;
end