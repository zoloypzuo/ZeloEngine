local Bundler = Class(function(self, inst)
    self.inst = inst
    self.bundlinginst = nil
    self.itemprefab = nil
    self.wrappedprefab = nil
end)

function Bundler:CanStartBundling()
    return self.inst.sg.currentstate.name == "bundle"
        and self.bundlinginst == nil
        and self.itemprefab == nil
end

function Bundler:IsBundling(bundlinginst)
    return bundlinginst ~= nil
        and self.bundlinginst == bundlinginst
        and self.inst.sg.currentstate.name == "bundling"
end

function Bundler:StartBundling(item)
    if item ~= nil and
        item.components.bundlemaker ~= nil and
        item.components.bundlemaker.bundlingprefab ~= nil and
        item.components.bundlemaker.bundledprefab ~= nil then
        self:StopBundling()
        self.bundlinginst = SpawnPrefab(item.components.bundlemaker.bundlingprefab)
        if self.bundlinginst ~= nil then
            if self.bundlinginst.components.container ~= nil then
                self.bundlinginst.components.container:Open(self.inst)
                if self.bundlinginst.components.container:IsOpenedBy(self.inst) then
                    self.bundlinginst.entity:SetParent(self.inst.entity)
                    self.bundlinginst.persists = false
                    self.itemprefab = item.prefab
                    self.wrappedprefab = item.components.bundlemaker.bundledprefab
                    item.components.bundlemaker:OnStartBundling(self.inst)
                    self.inst.sg.statemem.bundling = true
                    self.inst.sg:GoToState("bundling")
                    return true
                end
            end
            self.bundlinginst:Remove()
            self.bundlinginst = nil
        end
    end
end

local function DropItem(inst, item)
    if item.components.inventoryitem ~= nil then
        item.components.inventoryitem:DoDropPhysics(inst.Transform:GetWorldPosition())
    elseif item.Physics ~= nil then
        item.Physics:Teleport(inst.Transform:GetWorldPosition())
    else
        item.Transform:SetPosition(inst.Transform:GetWorldPosition())
    end
end

function Bundler:StopBundling()
    if self.bundlinginst ~= nil then
        if self.bundlinginst.components.container ~= nil then
            if self.inst.components.inventory ~= nil then
                local pos = self.bundlinginst:GetPosition()
                for i = 1, self.bundlinginst.components.container:GetNumSlots() do
                    local item = self.bundlinginst.components.container:RemoveItemBySlot(i)
                    if item ~= nil then
                        item.prevcontainer = nil
                        item.prevslot = nil
                        self.inst.components.inventory:GiveItem(item, nil, pos)
                    end
                end
            else
                self.bundlinginst.components.container:DropEverything()
            end
        end
        self.bundlinginst:Remove()
        self.bundlinginst = nil
    end
    if self.itemprefab ~= nil then
        local item = SpawnPrefab(self.itemprefab)
        if item ~= nil then
            if self.inst.components.inventory ~= nil then
                self.inst.components.inventory:GiveItem(item, nil, self.inst:GetPosition())
            else
                DropItem(self.inst, item)
            end
        end
        self.itemprefab = nil
        self.wrappedprefab = nil
    end
end

function Bundler:FinishBundling()
    if self.bundlinginst ~= nil and
        self.bundlinginst.components.container ~= nil and
        not self.bundlinginst.components.container:IsEmpty() and
        self.wrappedprefab ~= nil and
        self.inst.sg.currentstate.name == "bundling" then
        self.bundlinginst.components.container:Close()
        self.inst.sg.statemem.bundling = true
        self.inst.sg:GoToState("bundle_pst")
        return true
    end
end

function Bundler:OnFinishBundling()
    if self.bundlinginst ~= nil and
        self.bundlinginst.components.container ~= nil and
        not self.bundlinginst.components.container:IsEmpty() and
        self.wrappedprefab ~= nil then
        local wrapped = SpawnPrefab(self.wrappedprefab)
        if wrapped ~= nil then
            if wrapped.components.unwrappable ~= nil then
                local items = {}
                for i = 1, self.bundlinginst.components.container:GetNumSlots() do
                    local item = self.bundlinginst.components.container:GetItemInSlot(i)
                    if item ~= nil then
                        table.insert(items, item)
                    end
                end
                wrapped.components.unwrappable:WrapItems(items, self.inst)
                self.bundlinginst:Remove()
                self.bundlinginst = nil
                self.itemprefab = nil
                self.wrappedprefab = nil
                if self.inst.components.inventory ~= nil then
                    self.inst.components.inventory:GiveItem(wrapped, nil, self.inst:GetPosition())
                else
                    DropItem(self.inst, wrapped)
                end
            else
                wrapped:Remove()
            end
        end
    end
end

function Bundler:OnSave()
    local data =
    {
        item = self.itemprefab,
        wrapped = self.wrappedprefab,
    }
    if self.bundlinginst ~= nil and
        self.bundlinginst.components.container ~= nil and
        not self.bundlinginst.components.container:IsEmpty() then
        data.bundling = self.bundlinginst:GetSaveRecord()
    end
    return next(data) ~= nil and data or nil
end

function Bundler:OnLoad(data)
    if data.item ~= nil or data.bundling ~= nil then
        local currentitem = self.itemprefab
        local currentwrapped = self.wrappedprefab
        local currentbundling = self.bundlinginst

        self.itemprefab = data.item
        self.wrappedprefab = data.wrapped

        if data.bundling ~= nil then
            self.bundlinginst = SpawnSaveRecord(data.bundling)
            if self.bundlinginst ~= nil then
                self.bundlinginst.entity:SetParent(self.inst.entity)
                self.bundlinginst.persists = false
            end
        end

        if currentitem ~= nil or currentbundling ~= nil then
            self:StopBundling()
            self.itemprefab = currentitem
            self.wrappedprefab = currentwrapped
            self.bundlinginst = currentbundling
        end
    end
end

Bundler.OnRemoveFromEntity = Bundler.StopBundling
Bundler.OnRemoveEntity = Bundler.StopBundling

return Bundler
