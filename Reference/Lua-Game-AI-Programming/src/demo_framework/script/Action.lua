Action = {};

-- The states an instance of an Action can be in.
Action.Status = {
    RUNNING = "RUNNING",
    TERMINATED = "TERMINATED",
    UNINITIALIZED = "UNINITIALIZED"
};

-- Type of object an Action is.
Action.Type = "Action";

function Action.CleanUp(self)
    -- Run the clean up function if one is specified.
    if (self.status_ == Action.Status.TERMINATED) then
        if (self.cleanUpFunction_) then
            self.cleanUpFunction_(self.userData_);
        end
    end
    
    -- Set the action to uninitialized after cleaning up.
    self.status_ = Action.Status.UNINITIALIZED;
end

function Action.Initialize(self)
    -- Run the initialize function if one is specified.
    if (self.status_ == Action.Status.UNINITIALIZED) then
        if (self.initializeFunction_) then
            self.initializeFunction_(self.userData_);
        end
    end
    
    -- Set the action to running after initializing.
    self.status_ = Action.Status.RUNNING;
end

function Action.Update(self, deltaTimeInMillis)
    if (self.status_ == Action.Status.TERMINATED) then
        -- Immediately return if the Action has already terminated.
        return Action.Status.TERMINATED;
    elseif (self.status_ == Action.Status.RUNNING) then
        if (self.updateFunction_) then
            -- Run the update function if one is specified.
            self.status_ = self.updateFunction_(deltaTimeInMillis, self.userData_);

            -- Ensure that a status was returned by the update function.
            assert(self.status_);
        else
            -- If no update function is present move the action into a
            -- terminated state.
            self.status_ = Action.Status.TERMINATED;
        end
    end

    return self.status_;
end

function Action.new(name, initializeFunction, updateFunction, cleanUpFunction, userData)
    local action = {};
    
    -- The Action's data members.
    action.cleanUpFunction_ = cleanUpFunction;
    action.initializeFunction_ = initializeFunction;
    action.updateFunction_ = updateFunction;
    action.name_ = name or "";
    action.status_ = Action.Status.UNINITIALIZED;
    action.type_ = Action.Type;
    action.userData_ = userData;
    
    -- The Action's accessor functions.
    action.CleanUp = Action.CleanUp;
    action.Initialize = Action.Initialize;
    action.Update = Action.Update;
    
    return action;
end