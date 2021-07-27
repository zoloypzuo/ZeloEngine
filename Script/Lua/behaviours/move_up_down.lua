-- move_up_down
-- created on 2021/7/27
-- author @zoloypzuo
-- Holds data that are shared between functions of this usertype
local MoveUpDown = {
    elapsed = 0
}

-- Called when the scene starts
function MoveUpDown:OnStart()
end

-- Called every frame (The passed deltaTime holds the time elapsed between the current and previous frame in seconds)
function MoveUpDown:OnUpdate(deltaTime)
    -- Here, elapsed is incremented to sum the elapsed time since start
    self.elapsed = self.elapsed + deltaTime

    -- Stores the transform component instance into a variable
    transform = self.owner:GetTransform()

    -- Invoke SetPosition function with `:` to send the transform instance as first parameter to this function
    -- `transform:SetPosition(...)` is equivalent to `transform.SetPosition(transform, ...)`
    transform:SetPosition(Vector3.new(0, math.sin(self.elapsed), 0))

end

-- Returns the usertype so the engine has a reference to it
return MoveUpDown
