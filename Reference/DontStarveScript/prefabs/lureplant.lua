require "brains/lureplantbrain"
require "stategraphs/SGlureplant"

local assets =
{
	Asset("ANIM", "anim/eyeplant_trap.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("SOUND", "sound/plant.fsb"),
}

local prefabs = 
{
    "eyeplant",
    "lureplantbulb",
    "plantmeat"
}

function adjustIdleSound(inst, vol)
    inst.SoundEmitter:SetParameter("loop", "size", vol)
end

local function TryRevealBait(inst)
    inst.lure = inst.lurefn(inst)
    if inst.lure ~= nil and inst.wakeinfo == nil then --There's something to show as bait!
        inst.lure.onperishfn = function() inst.sg:GoToState("hidebait") end
        inst:ListenForEvent("onremove", inst.lure.onperishfn, inst.lure )
        inst.components.shelf.cantakeitem = true
        inst.components.inventory.nosteal = false
        inst.components.shelf.itemonshelf = inst.lure
        inst.sg:GoToState("showbait")

        if inst.task then
            inst.task = nil
        end

    else --There was nothing to use as bait. Try to reveal bait again until you can.
        
        inst.task = inst:DoTaskInTime(1, TryRevealBait)
    end
end

local function HideBait(inst)
    if not inst.sg:HasStateTag("hiding") and not inst.components.health:IsDead() then   --Won't hide if it's already hiding.        
        if not inst.task then
            inst.components.shelf.cantakeitem = false
            inst.components.inventory.nosteal = true
            inst.sg:GoToState("hidebait")
        end

    end

    if inst.lure then
        if inst.lure.onperishfn then
            inst:RemoveEventCallback("onremove", inst.lure.onperishfn)
        end
        inst.lure = nil
    end


    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    
    inst.task = inst:DoTaskInTime(math.random() * 3 + 2, TryRevealBait)    --Emerge again after some time.
end

local function SetWakeInfo(inst, sleeptime)
    inst.wakeinfo = {}
    inst.wakeinfo.endsleeptime = GetTime() + sleeptime
end

local function WakeUp(inst)
    if not GetSeasonManager():IsWinter() then
        inst.wakeinfo = nil
        inst.components.minionspawner.shouldspawn = true
        inst.components.minionspawner:StartNextSpawn()
        inst.task = inst:DoTaskInTime(1, TryRevealBait)
        inst.sg:GoToState("emerge")
    end
end

local function ResumeSleep(inst, seconds)
    inst.sg:GoToState("hibernate")
    inst.components.shelf.cantakeitem = false
    inst.components.inventory.nosteal = true

    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()
    
    SetWakeInfo(inst, seconds)
    inst:DoTaskInTime(seconds, WakeUp)
end

local function OnPicked(inst)
    if inst.lure then
        if inst.lure.onperishfn then
			inst:RemoveEventCallback("onremove", inst.lure.onperishfn)
		end
		inst.lure = nil
    end
    inst.components.shelf.cantakeitem = false
    inst.components.inventory.nosteal = true
    inst.sg:GoToState("picked")

    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end

    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()

    SetWakeInfo(inst, TUNING.LUREPLANT_HIBERNATE_TIME)

    if inst.hibernatetask then
        inst.hibernatetask:Cancel()
        inst.hibernatetask = nil
    end

    inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
end

local function FreshSpawn(inst)
    inst.components.shelf.cantakeitem = false
    inst.components.inventory.nosteal = true
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()

    SetWakeInfo(inst, TUNING.LUREPLANT_HIBERNATE_TIME)
    inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
end

local function CollectItems(inst)
    if inst.components.minionspawner.minions ~= nil then
        for k,v in pairs(inst.components.minionspawner.minions) do
            if v.components.inventory then                
                for k = 1, v.components.inventory.maxslots do
                    local item = v.components.inventory.itemslots[k]
                    if item and not inst.components.inventory:IsFull() then
                        local it = v.components.inventory:RemoveItem(item)
                        
                        if it.components.perishable then
							local top = it.components.perishable:GetPercent()
							local bottom = .2
							if top > bottom then
								it.components.perishable:SetPercent(bottom + math.random()*(top-bottom))
							end
                        end
						inst.components.inventory:GiveItem(it)
                                        
                        
                    elseif item then
                        local item = v.components.inventory:RemoveItem(item)
                        item:Remove()
                    end
                end
            end
        end
    end
end

local function SelectLure(inst)    
    if inst.components.inventory then
        local lures = {}
        for k = 1, inst.components.inventory.maxslots do
            local item = inst.components.inventory.itemslots[k]
            if item and item.components.edible and inst.components.eater:CanEat(item) and not item:HasTag("preparedfood") and not item.components.weapon then
               table.insert(lures, item)
            end
        end

        if #lures >= 1 then
            return lures[math.random(#lures)]
        else      
            if inst.components.minionspawner.numminions >= inst.components.minionspawner.maxminions / 2 then
                local meat = SpawnPrefab("plantmeat")
                inst.components.inventory:GiveItem(meat)      
                return meat
            end
        end
    end
end

local function OnDeath(inst)
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()
    inst.components.lootdropper:DropLoot(inst:GetPosition())
end

local function CanDigest(owner, item)
    if owner.components.shelf.itemonshelf and owner.components.shelf.itemonshelf.components.stackable and owner.components.shelf.itemonshelf.components.stackable.stacksize <= 5 then
        return item ~= owner.components.shelf.itemonshelf
    else
        return true
    end
end

local function OnLoad(inst, data)
    if data then
        if data.timeuntilwake then
            ResumeSleep(inst, data.timeuntilwake)
        end
    end
end

local function OnSave(inst, data)
    if inst.wakeinfo then
        data.timeuntilwake = inst.wakeinfo.endsleeptime - GetTime()
    end
end

local function OnLongUpdate(inst, dt)
    if inst.wakeinfo and inst.wakeinfo.endsleeptime then
        if inst.hibernatetask then
            inst.hibernatetask:Cancel()
            inst.hibernatetask = nil
        end

        local time_to_wait = inst.wakeinfo.endsleeptime - GetTime() - dt

        if time_to_wait <= 0 then
            WakeUp(inst)
        else
            inst.wakeinfo.endsleeptime = GetTime() + time_to_wait
            inst.hibernatetask = inst:DoTaskInTime(time_to_wait, WakeUp)
        end
    end
end

local function SeasonChanges(inst)
    local sm = GetSeasonManager()
    if sm:IsWinter() then
        --hibernate if you aren't already
        if inst.sg.currentstate.name ~= "hibernate" then
            OnPicked(inst)
        else
            --it's already hibernating & it's still winter. Make it sleep for longer!
            SetWakeInfo(inst, TUNING.LUREPLANT_HIBERNATE_TIME)
            if inst.hibernatetask then
                inst.hibernatetask:Cancel()
                inst.hibernatetask = nil
            end
            inst.hibernatetask = inst:DoTaskInTime(TUNING.LUREPLANT_HIBERNATE_TIME, WakeUp)
        end
    end
end


local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_central_idle", "loop")
    adjustIdleSound(inst, inst.components.minionspawner.numminions/inst.components.minionspawner.maxminions)
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("loop")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("eyeplant.png")

    anim:SetBank("eyeplant_trap")
    anim:SetBuild("eyeplant_trap")
    anim:PlayAnimation("idle_hidden", true)

    inst:AddTag("lureplant")
    inst:AddTag("hostile")
    inst:AddTag("veggie")

    inst:AddComponent("combat")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(300)
    inst:ListenForEvent("death", OnDeath)
    inst:ListenForEvent("hidebait", HideBait)

    inst:AddComponent("shelf")
    inst.components.shelf.ontakeitemfn = OnPicked

    inst:AddComponent("inventory")
    inst.components.inventory.nosteal = true

    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"lureplantbulb"})

    inst:AddComponent("minionspawner")
    inst.components.minionspawner.onminionattacked = HideBait
    inst.components.minionspawner.validtiletypes = {4,5,6,7,8,13,14,15,17}

    inst:AddComponent("digester")
    inst.components.digester.itemstodigestfn = CanDigest

    inst:SetStateGraph("SGlureplant")

    inst:ListenForEvent("startfiredamage", function() 
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner:KillAllMinions()
    end)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeplant/eye_central_idle", "loop")
    adjustIdleSound(inst, inst.components.minionspawner.numminions/inst.components.minionspawner.maxminions)

    inst:ListenForEvent("freshspawn", FreshSpawn)
    inst:ListenForEvent("minionchange", 
    function(inst) adjustIdleSound(inst, inst.components.minionspawner.numminions/inst.components.minionspawner.maxminions) end)

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    MakeMediumBurnableCharacter(inst, "swap_fire")
    MakeLargePropagator(inst)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    inst.OnLongUpdate = OnLongUpdate

    inst.lurefn = SelectLure
    inst:DoPeriodicTask(2, CollectItems) -- Always do this.
    TryRevealBait(inst)

    inst.ListenForWinter = inst:DoPeriodicTask(30, SeasonChanges)
    SeasonChanges(inst)

    local brain = require "brains/lureplantbrain"
    inst:SetBrain(brain)

	return inst
end

return Prefab("cave/lureplant", fn, assets, prefabs)
