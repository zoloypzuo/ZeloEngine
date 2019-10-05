local Hiddendanger = Class(function(self, inst)
    self.inst = inst        
    self.effect = "hiddendanger_fx"
    self.offset = {x=0,y=0,z=0}
    GetPlayer():ListenForEvent("equip", function() self:TestShouldShowDanger() end )
    GetPlayer():ListenForEvent("unequip", function() self:TestShouldShowDanger() end)
    self.inst:ListenForEvent("entitywake", function() self:TestShouldShowDanger() end)
end)

function  Hiddendanger:TestShouldShowDanger()
    if not self.disabled then
        local player = GetPlayer()
        local inventory = player.components.inventory

        local head = inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        local hands = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local body = inventory:GetEquippedItem(EQUIPSLOTS.BODY)

        local shouldshow = false
        if head and head:HasTag("sees_hiddendanger") then
            shouldshow = true
        end
        if hands and hands:HasTag("sees_hiddendanger") then
            shouldshow = true
        end
        if body and body:HasTag("sees_hiddendanger") then
            shouldshow = true
        end    

        self:ShowDanger(shouldshow)
    else
        self:ShowDanger()
    end
end


function Hiddendanger:ChangeFx(effect)
    self.effect = "identified_marker_fx"
    if self.fx then
        self.fx:Remove()
    end
    self:TestShouldShowDanger()
end

function Hiddendanger:Clear()
    if self.fx then
        self.fx:Remove()
    end
    self.disabled = true
end

function Hiddendanger:ShowDanger(state)
    if state then
        if not self.fx and self.inst:IsValid() then

            self.fx = SpawnPrefab(self.effect)                        
            local x,y,z = self.inst.Transform:GetWorldPosition()
            
            self.fx.Transform:SetPosition(x+self.offset.x,y+self.offset.y,z+self.offset.z)      
            self.fx:ListenForEvent("onremove", function() if self.inst:IsValid() then self.fx = nil end end)
            --self.fx.AnimState:SetSortOrder(3)
            self.fx.AnimState:SetFinalOffset(1)

            self.inst:ListenForEvent("onremove", function() if self.fx then self.fx:Remove() end end)
            self.inst:ListenForEvent("death", function() if self.fx then self.fx:Remove() end end)
        end      
    else
        if self.fx then
            self.fx:Remove()
        end
    end
end

function Hiddendanger:OnSave()
    local data = {}
    if self.disabled then 
        data.disabled = true
    end

    if next(data) then
        return data
    end
end

function Hiddendanger:OnLoad(data)
    if data and data.disabled then
        self.disabled = true
        self:ShowDanger()
    end
end

return Hiddendanger
