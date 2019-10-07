FiniteState = {};

function FiniteState.new(name, action)
    local state = {};
    
    -- The FiniteState's data members.
    state.name_ = name;
    state.action_ = action;
    
    return state;
end