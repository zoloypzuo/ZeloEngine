local ShatterFX = Class(function(self, inst)
    self.inst = inst
    self.level = nil
    self.levels = {}
end)

function ShatterFX:SetLevel(level)
    level = math.min(level, #self.levels)
    if level ~= self.level and self.levels[level] then
        if not self.level and self.levels[level].pre then
            self.inst.AnimState:PlayAnimation(self.levels[level].pre)
            self.inst.AnimState:PushAnimation(self.levels[level].anim, true)
        else
            self.inst.AnimState:PlayAnimation(self.levels[level].anim, true)
        end
        self.level = level
    end
end

return ShatterFX