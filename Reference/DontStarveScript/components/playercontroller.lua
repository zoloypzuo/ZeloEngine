require "class"

local easing = require "easing"

local trace = function()
end

local START_DRAG_TIME = (1 / 30) * 8

local PlayerController = Class(function(self, inst)
    self.inst = inst
    self.enabled = true

    self.handler = TheInput:AddGeneralControlHandler(function(control, value)
        self:OnControl(control, value)
    end)
    self.inst:StartUpdatingComponent(self)
    self.draggingonground = false
    self.startdragtestpos = nil
    self.startdragtime = nil

    self.inst:ListenForEvent("buildstructure", function(inst, data)
        self:OnBuild()
    end, GetPlayer())

    self.inst:ListenForEvent("equip", function(inst, data)
        self:OnEquip(data)
    end, GetPlayer())
    self.inst:ListenForEvent("unequip", function(inst, data)
        self:OnUnequip(data)
    end, GetPlayer())
    self.reticule = nil

    self.terraformer = nil

    self.LMBaction = nil
    self.RMBaction = nil

    self.mousetimeout = 10
    self.time_direct_walking = 0
    self.deploy_mode = not TheInput:ControllerAttached()
    --TheInput:AddMoveHandler(function(x,y) self.using_mouse = true self.mousetimeout = 3 end)
end)

function PlayerController:OnBuild()
    self:CancelPlacement()
end

function PlayerController:IsEnabled()
    return self.enabled and self.inst.HUD and not self.inst.HUD:IsControllerCraftingOpen() and not self.inst.HUD:IsControllerInventoryOpen()
end

function PlayerController:OnEquip(data)
    local controller_mode = TheInput:ControllerAttached()
    --Blink Staff
    if data.item.components.reticule and data.eslot == EQUIPSLOTS.HANDS then
        self.reticule = data.item.components.reticule
        if controller_mode and self.reticule and not self.reticule.reticule then
            self.reticule:CreateReticule()
        end
    end
end

function PlayerController:OnUnequip(data)
    if self.reticule and data.item.components.reticule and data.eslot == EQUIPSLOTS.HANDS then
        self.reticule:DestroyReticule()
        self.reticule = nil
    end
end

function PlayerController:OnControl(control, down)
    if not self:IsEnabled() then
        return
    end
    if not IsPaused() then

        if control == CONTROL_PRIMARY then
            self:OnLeftClick(down)
            return
        elseif control == CONTROL_SECONDARY then
            self:OnRightClick(down)
            return
        end

        if down then
            if self.placer_recipe and control == CONTROL_CANCEL then
                self:CancelPlacement()
            else
                if control == CONTROL_INSPECT then
                    self:DoInspectButton()
                elseif control == CONTROL_ACTION then
                    self:DoActionButton()
                elseif control == CONTROL_ATTACK then
                    self:DoAttackButton()
                elseif control == CONTROL_CONTROLLER_ALTACTION then
                    self:DoControllerAltAction()
                elseif control == CONTROL_CONTROLLER_ACTION then
                    self:DoControllerAction()
                elseif control == CONTROL_CONTROLLER_ATTACK then
                    self:DoControllerAttack()
                end

                local inv_obj = self:GetCursorInventoryObject()

                if inv_obj then
                    local is_equipped = (inv_obj.components.equippable and inv_obj.components.equippable:IsEquipped())

                    if control == CONTROL_INVENTORY_DROP then
                        self.inst.components.inventory:DropItem(inv_obj, true)
                    elseif control == CONTROL_INVENTORY_EXAMINE then
                        self.inst.components.locomotor:PushAction(BufferedAction(self.inst, inv_obj, ACTIONS.LOOKAT))
                    elseif control == CONTROL_INVENTORY_USEONSELF and is_equipped then
                        self.inst.components.locomotor:PushAction(BufferedAction(self.inst, nil, ACTIONS.UNEQUIP, inv_obj))
                    elseif control == CONTROL_INVENTORY_USEONSELF and not is_equipped then
                        if inv_obj.components.deployable and not self.deploy_mode and inv_obj.components.inventoryitem:GetGrandOwner() == self.inst then
                            self.deploy_mode = true
                        else
                            if not self.inst.sg:HasStateTag("busy") then
                                self.inst.components.locomotor:PushAction(self:GetItemSelfAction(inv_obj), true)
                            end
                        end
                    elseif control == CONTROL_INVENTORY_USEONSCENE and not is_equipped then
                        if inv_obj.components.inventoryitem:GetGrandOwner() ~= self.inst then
                            self.inst.components.inventory:GiveItem(inv_obj)
                        else
                            self:DoAction(self:GetItemUseAction(inv_obj))
                        end
                    elseif control == CONTROL_INVENTORY_USEONSCENE and is_equipped then
                        local action = self:GetItemSelfAction(inv_obj)
                        if action.action ~= ACTIONS.UNEQUIP then
                            self.inst.components.locomotor:PushAction(action)
                        end
                    end
                end
            end
        end
    end
end

function PlayerController:GetCursorInventoryObject()
    if self.inst.HUD and self.inst.HUD.controls and self.inst.HUD.controls.inv then
        return self.inst.HUD.controls.inv:GetCursorItem()
    end
end

function PlayerController:DoControllerAction()
    self.time_direct_walking = 0
    if self.placer then
        if self.placer.components.placer.can_build then
            self.inst.components.builder:MakeRecipe(self.placer_recipe, Vector3(self.placer.Transform:GetWorldPosition()))
            return true
        end
    elseif self.deployplacer then
        if self.deployplacer.components.placer.can_build then
            local act = self.deployplacer.components.placer:GetDeployAction()
            act.distance = 1
            self:DoAction(act)
        end
    elseif self.controller_target then
        self:DoAction(self:GetSceneItemControllerAction(self.controller_target))
    end
end

function PlayerController:DoControllerAltAction()
    self.time_direct_walking = 0

    if self.placer_recipe then
        self:CancelPlacement()
        return
    end

    if self.deployplacer then
        self:CancelDeployPlacement()
        return
    end

    local l, r = self:GetGroundUseAction()
    if r then
        self:DoAction(r)
        return
    end

    if self.controller_target then
        local l, r = self:GetSceneItemControllerAction(self.controller_target)
        if r then
            self:DoAction(r)
            return
        end
    end

    local rider = self.inst.components.rider
    if rider and rider:IsRiding() then
        r = BufferedAction(self.inst, self.inst, ACTIONS.DISMOUNT)
        self:DoAction(r)
        return
    end
end

function PlayerController:DoControllerAttack()
    self.time_direct_walking = 0

    local attack_target = self.controller_attack_target

    if attack_target and self.inst.components.combat.target ~= attack_target then
        local action = BufferedAction(self.inst, attack_target, ACTIONS.ATTACK)
        self.inst.components.locomotor:PushAction(action, true)
    elseif not attack_target and not self.inst.components.combat.target then
        local action = BufferedAction(self.inst, nil, ACTIONS.FORCEATTACK)
        self.inst.components.locomotor:PushAction(action, true)
    else
        return -- already doing it!
    end
end

function PlayerController:RotLeft()
    local rotamount = 45 ---90-- GetWorld():IsCave() and 22.5 or 45
    if TheCamera:CanControl() then

        if IsPaused() then
            if GetWorld().minimap.MiniMap:IsVisible() then
                TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount)
                TheCamera:Snap()
            end
        else
            TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() - rotamount)
            --UpdateCameraHeadings()
        end
    end
end

function PlayerController:RotRight()
    local rotamount = 45 --90--GetWorld():IsCave() and 22.5 or 45
    if TheCamera:CanControl() then

        if IsPaused() then
            if GetWorld().minimap.MiniMap:IsVisible() then
                TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount)
                TheCamera:Snap()
            end
        else
            TheCamera:SetHeadingTarget(TheCamera:GetHeadingTarget() + rotamount)
            --UpdateCameraHeadings()
        end
    end
end

function PlayerController:OnRemoveEntity()
    self.handler:Remove()
end

function PlayerController:GetHoverTextOverride()
    if self.placer_recipe then
        return STRINGS.UI.HUD.BUILD .. " " .. (STRINGS.NAMES[string.upper(self.placer_recipe.name)] or STRINGS.UI.HUD.HERE)
    end
end

function PlayerController:CancelPlacement()
    if self.placer then
        self.placer:Remove()
        self.placer = nil
    end
    self.placer_recipe = nil
end

function PlayerController:CancelDeployPlacement()
    self.deploy_mode = not TheInput:ControllerAttached()
    if self.deployplacer then
        self.deployplacer:Remove()
        self.deployplacer = nil
    end
end

function PlayerController:StartBuildPlacementMode(recipe, testfn)
    self.placer_recipe = recipe
    if self.placer then
        self.placer:Remove()
        self.placer = nil
    end
    self.placer = SpawnPrefab(recipe.placer)
    self.placer.components.placer:SetBuilder(self.inst, recipe)
    self.placer.components.placer.testfn = testfn
end

function PlayerController:Enable(val)
    self.enabled = val
end

function PlayerController:GetAttackTarget(force_attack)

    local x, y, z = self.inst.Transform:GetWorldPosition()

    local rad = self.inst.components.combat:GetAttackRange()

    if not self.directwalking then
        rad = rad + 6
    end --for autowalking

    --To deal with entity collision boxes we need to pad the radius.
    local nearby_ents = TheSim:FindEntities(x, y, z, rad + 5)
    local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local has_weapon = tool and tool.components.weapon

    local playerRad = self.inst.Physics:GetRadius()

    for k, guy in ipairs(nearby_ents) do

        if guy ~= self.inst and
                guy:IsValid() and
                not guy:IsInLimbo() and
                not (guy.sg and guy.sg:HasStateTag("invisible")) and
                guy.components.health and not guy.components.health:IsDead() and
                guy.components.combat and guy.components.combat:CanBeAttacked(self.inst) and
                not (guy.components.follower and guy.components.follower.leader == self.inst) and
                --Now we ensure the target is in range.
                distsq(guy:GetPosition(), self.inst:GetPosition()) <= math.pow(rad + playerRad + guy.Physics:GetRadius() + 0.1, 2) then
            if (guy:HasTag("monster") and has_weapon) or
                    guy:HasTag("hostile") or
                    self.inst.components.combat:IsRecentTarget(guy) or
                    guy.components.combat.target == self.inst or
                    force_attack then
                return guy
            end
        end
    end

end

--

function PlayerController:DoAttackButton()
    local attack_target = self:GetAttackTarget(TheInput:IsControlPressed(CONTROL_FORCE_ATTACK))
    if attack_target and self.inst.components.combat.target ~= attack_target then
        local action = BufferedAction(self.inst, attack_target, ACTIONS.ATTACK)
        self.inst.components.locomotor:PushAction(action, true)
    else
        return -- already doing it!
    end
end

function notriding(inst)
    return not inst.components.rider or not inst.components.rider:IsRiding()
end

function PlayerController:GetActionButtonAction()
    if self.actionbuttonoverride then
        return self.actionbuttonoverride(self.inst)
    end

    if self:IsEnabled() and not (self.inst.sg:HasStateTag("working") or self.inst.sg:HasStateTag("doing")) then

        local tool = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

        --bug catching (has to go before combat)
        if tool and tool.components.tool and tool.components.tool:CanDoAction(ACTIONS.NET) then
            local target = FindEntity(self.inst, 5,
                    function(guy)
                        return guy.components.health and not guy.components.health:IsDead() and
                                guy.components.workable and
                                guy.components.workable.action == ACTIONS.NET
                    end)
            if target then
                return BufferedAction(self.inst, target, ACTIONS.NET, tool)
            end
        end


        --catching
        local rad = 8
        local projectile = FindEntity(self.inst, rad, function(guy)
            return guy.components.projectile
                    and guy.components.projectile:IsThrown()
                    and self.inst.components.catcher
                    and self.inst.components.catcher:CanCatch()
        end)
        if projectile then
            return BufferedAction(self.inst, projectile, ACTIONS.CATCH)
        end

        rad = self.directwalking and 3 or 6
        --pickup
        local pickup = FindEntity(self.inst, rad, function(guy)
            return (guy.components.inventoryitem and guy.components.inventoryitem.canbepickedup) or
                    (tool and tool.components.tool and guy.components.workable and tool.components.tool:CanDoAction(guy.components.workable.action)) or
                    (guy.components.pickable and guy.components.pickable:CanBePicked() and guy.components.pickable.caninteractwith) or
                    (guy.components.stewer and guy.components.stewer.done) or
                    (guy.components.crop and guy.components.crop:IsReadyForHarvest()) or
                    (guy.components.harvestable and guy.components.harvestable:CanBeHarvested()) or
                    (guy.components.trap and guy.components.trap.issprung) or
                    (guy.components.dryer and guy.components.dryer:IsDone()) or
                    (guy.components.activatable and guy.components.activatable.inactive)
        end)

        local has_active_item = self.inst.components.inventory:GetActiveItem() ~= nil
        if pickup then
            --  and not has_active_item
            local action = nil

            if notriding(self.inst) and (tool and tool.components.tool and pickup.components.workable and tool.components.tool:CanDoAction(pickup.components.workable.action)) then
                action = pickup.components.workable.action
            elseif notriding(self.inst) and pickup.components.trap and pickup.components.trap.issprung then
                action = ACTIONS.CHECKTRAP
            elseif notriding(self.inst) and pickup.components.mine and not pickup.components.mine.inactive then
                if pickup.components.mine.issprung then
                    action = ACTIONS.RESETMINE
                end
            elseif notriding(self.inst) and pickup.components.activatable and pickup.components.activatable.inactive then
                action = ACTIONS.ACTIVATE
            elseif notriding(self.inst) and pickup.components.inventoryitem and pickup.components.inventoryitem.canbepickedup then
                action = ACTIONS.PICKUP
            elseif notriding(self.inst) and pickup.components.pickable and pickup.components.pickable:CanBePicked() then
                action = ACTIONS.PICK
            elseif notriding(self.inst) and pickup.components.harvestable and pickup.components.harvestable:CanBeHarvested() then
                action = ACTIONS.HARVEST
            elseif notriding(self.inst) and pickup.components.crop and pickup.components.crop:IsReadyForHarvest() then
                action = ACTIONS.HARVEST
            elseif notriding(self.inst) and pickup.components.dryer and pickup.components.dryer:IsDone() then
                action = ACTIONS.HARVEST
            elseif notriding(self.inst) and pickup.components.stewer and pickup.components.stewer.done then
                action = ACTIONS.HARVEST
            end

            if action then
                local ba = BufferedAction(self.inst, pickup, action, tool)
                --ba.distance = self.directwalking and rad or 1
                return ba
            end
        end
    end
end

function PlayerController:DoActionButton()
    --do the placement
    if self.placer then
        if self.placer.components.placer.can_build then
            self.inst.components.builder:MakeRecipe(self.placer_recipe, Vector3(self.placer.Transform:GetWorldPosition()))
            return true
        end
    else
        local ba = self:GetActionButtonAction()
        if ba then
            self.inst.components.locomotor:PushAction(ba, true)
        end
        return true
    end
end

function PlayerController:DoInspectButton()
    if self.controller_target and GetPlayer():CanExamine() then
        self.inst.components.locomotor:PushAction(BufferedAction(self.inst, self.controller_target, ACTIONS.LOOKAT))
    end
    return true
end

function PlayerController:UsingMouse()
    if TheInput:ControllerAttached() then
        return false
    else
        return true
    end
end

function PlayerController:OnUpdate(dt)


    if not TheInput:IsControlPressed(CONTROL_PRIMARY) then
        if self.draggingonground then
            self.draggingonground = false
            TheFrontEnd:LockFocus(false)
            self.startdragtime = nil
        end
    end

    local controller_mode = TheInput:ControllerAttached()

    if not self:IsEnabled() then
        if self.directwalking then
            self.inst.components.locomotor:Stop()
            self.directwalking = false
        end

        if self.placer then
            self.placer:Remove()
            self.placer = nil
        end

        self:CancelDeployPlacement()

        if self.reticule and self.reticule.reticule then
            self.reticule.reticule:Hide()
        end

        if self.terraformer then
            self.terraformer:Remove()
            self.terraformer = nil
        end

        return
    end

    local new_highlight = nil
    if controller_mode then
        self:UpdateControllerInteractionTarget(dt)
        self:UpdateControllerAttackTarget(dt)
        new_highlight = self.controller_target
    else
        self.LMBaction, self.RMBaction = self.inst.components.playeractionpicker:DoGetMouseActions()
        new_highlight = (self.LMBaction and self.LMBaction.target) or (self.RMBaction and self.RMBaction.target)
        self.controller_attack_target = nil
    end

    if new_highlight ~= self.highlight_guy then
        if self.highlight_guy and self.highlight_guy:IsValid() then
            if self.highlight_guy.components.highlight then
                self.highlight_guy.components.highlight:UnHighlight()
            end
        end
        self.highlight_guy = new_highlight
    end

    if self.highlight_guy and self.highlight_guy:IsValid() then
        if not self.highlight_guy.components.highlight then
            self.highlight_guy:AddComponent("highlight")
        end

        local override = self.highlight_guy.highlight_override
        if override then
            self.highlight_guy.components.highlight:Highlight(override[1], override[2], override[3])
        else
            self.highlight_guy.components.highlight:Highlight()
        end
    else
        self.highlight_guy = nil
    end

    self:DoCameraControl()

    local active_item = self.inst.components.inventory:GetActiveItem()

    if not controller_mode then
        if self.reticule then
            self.reticule:DestroyReticule()
            self.reticule = nil
        end
    end
    -- hack so that the wall placer doesn't show when you are in fact going to repair instead.
    local hidePlacer = false
    if self.RMBaction and self.RMBaction.action.id == "REPAIR" then
        hidePlacer = true
    end

    local placer_item = nil
    if controller_mode then
        placer_item = self:GetCursorInventoryObject()
    else
        placer_item = active_item
    end

    local show_deploy_placer = placer_item and (placer_item.components.deployable and self.deploy_mode) and self.placer == nil and not hidePlacer

    if show_deploy_placer then
        local placer_name = placer_item.components.deployable.placer or ((placer_item.prefab or "") .. "_placer")
        if self.deployplacer and self.deployplacer.prefab ~= placer_name then
            self:CancelDeployPlacement()
        end

        if not self.deployplacer then
            self.deployplacer = SpawnPrefab(placer_name)
            if self.deployplacer then
                self.deployplacer.components.placer:SetBuilder(self.inst, nil, placer_item)

                self.deployplacer.components.placer.testfn = function(pt)
                    return placer_item.components.deployable:CanDeploy(pt)
                end

                self.deployplacer.components.placer:OnUpdate(0)  --so that our position is accurate on the first frame
            end
        end
    else
        self:CancelDeployPlacement()
    end

    local terraform = false
    if controller_mode then
        local l, r = self:GetGroundUseAction()
        terraform = r and r.action == ACTIONS.TERRAFORM
    else
        local action_r = self:GetRightMouseAction()
        terraform = action_r and action_r.action == ACTIONS.TERRAFORM and action_r
    end

    local show_rightaction_reticule = self.placer == nil and self.deployplacer == nil

    if show_rightaction_reticule then

        if terraform and not self.terraformer then
            self.terraformer = SpawnPrefab("gridplacer")
            if self.terraformer then
                self.terraformer.components.placer:SetBuilder(GetPlayer())
                self.terraformer.components.placer:OnUpdate(0)
            end
        elseif not terraform and self.terraformer then
            self.terraformer:Remove()
            self.terraformer = nil
        end

        if self.reticule and self.reticule.reticule then
            self.reticule.reticule:Show()
        end

    else
        if self.terraformer then
            self.terraformer:Remove()
            self.terraformer = nil
        end

        if self.reticule and self.reticule.reticule then
            self.reticule.reticule:Hide()
        end
    end

    if self.startdragtime and not self.draggingonground and TheInput:IsControlPressed(CONTROL_PRIMARY) then
        local now = GetTime()
        if now - self.startdragtime > START_DRAG_TIME then
            TheFrontEnd:LockFocus(true)
            self.draggingonground = true
        end
    end

    if self.draggingonground and TheFrontEnd:GetFocusWidget() ~= self.inst.HUD then
        TheFrontEnd:LockFocus(false)
        self.draggingonground = false

        self.inst.components.locomotor:Stop()
    end

    if not self.inst.sg:HasStateTag("busy") then

        if self.draggingonground then
            local pt = TheInput:GetWorldPosition()
            local dst = distsq(pt, Vector3(self.inst.Transform:GetWorldPosition()))

            if dst > 1 then
                local angle = self.inst:GetAngleToPoint(pt)
                self.inst:ClearBufferedAction()
                self.inst.components.locomotor:RunInDirection(angle)
            end
            self.directwalking = false
        else
            self:DoDirectWalking(dt)
        end
    end

    --do automagic control repeats
    if self.inst.sg:HasStateTag("idle") then
        if TheInput:IsControlPressed(CONTROL_ACTION) then
            self:OnControl(CONTROL_ACTION, true)
        elseif TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION) then
            self:OnControl(CONTROL_CONTROLLER_ACTION, true)
        end
    end

    if not self.inst.sg:HasStateTag("busy") and not self.directwalking then
        if TheInput:IsControlPressed(CONTROL_ATTACK) then
            self:OnControl(CONTROL_ATTACK, true)
        elseif TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK) then
            self:OnControl(CONTROL_CONTROLLER_ATTACK, true)
        end
    end
end

function PlayerController:GetWorldControllerVector()
    local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
    local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    local deadzone = .3

    if math.abs(xdir) < deadzone and math.abs(ydir) < deadzone then
        xdir = 0
        ydir = 0
    end
    if xdir ~= 0 or ydir ~= 0 then
        local CameraRight = TheCamera:GetRightVec()
        local CameraDown = TheCamera:GetDownVec()
        local dir = CameraRight * xdir - CameraDown * ydir
        dir = dir:GetNormalized()
        return dir
    end
end

function PlayerController:CanAttackWithController(target)
    return target ~= self.inst and
            target:IsValid() and
            (target.components.health and target.components.health.currenthealth > 0) and
            not target:IsInLimbo() and
            not target:HasTag("wall") and
            not (target.sg and target.sg:HasStateTag("invisible")) and
            target.components.health and not target.components.health:IsDead() and
            target.components.combat and target.components.combat:CanBeAttacked(self.inst)
end

local must_have_attack = { "HASCOMBATCOMPONENT" }
local cant_have_attack = { "FX", "NOCLICK", "DECOR", "INLIMBO" }

function PlayerController:UpdateControllerAttackTarget(dt)
    if self.controllerattacktargetage then
        self.controllerattacktargetage = self.controllerattacktargetage + dt
    end

    --if self.controller_attack_target and self.controllerattacktargetage and self.controllerattacktargetage < .3 then return end

    local heading_angle = -(self.inst.Transform:GetRotation())
    local dir = Vector3(math.cos(heading_angle * DEGREES), 0, math.sin(heading_angle * DEGREES))

    local me_pos = Vector3(self.inst.Transform:GetWorldPosition())

    local min_rad = 4
    local max_range = self.inst.components.combat:GetAttackRange() + 3

    local rad = 8
    if self.controller_attack_target and self.controller_attack_target:IsValid() and self:CanAttackWithController(self.controller_attack_target) then
        local distsq = self.inst:GetDistanceSqToInst(self.controller_attack_target)
        if distsq <= max_range * max_range then
            rad = math.min(rad, math.sqrt(distsq) * .5)
        end
    end

    local x, y, z = me_pos:Get()
    local nearby_ents = TheSim:FindEntities(x, y, z, rad, must_have_attack, cant_have_attack)

    local target = nil
    local target_score = nil
    local target_action = nil

    if self.controller_attack_target then
        table.insert(nearby_ents, self.controller_attack_target)
    end

    for k, v in pairs(nearby_ents) do

        local canattack = self:CanAttackWithController(v)

        if canattack then

            local px, py, pz = v.Transform:GetWorldPosition()
            local ox, oy, oz = px - me_pos.x, py - me_pos.y, pz - me_pos.z
            local dsq = ox * ox + oy * oy + oz * oz
            local dist = dsq > 0 and math.sqrt(dsq) or 0

            local dot = 0
            if dist > 0 then
                local nx, ny, nz = ox / dist, oy / dist, oz / dist
                dot = nx * dir.x + ny * dir.y + nz * dir.z
            end

            if (dist < min_rad or dot > 0) and dist < max_range then

                local score = (1 + dot) * (1 / math.max(min_rad * min_rad, dsq))

                if (v.components.follower and v.components.follower.leader == self.inst) or v.prefab == "chester" then
                    score = score * .25
                elseif v:HasTag("monster") then
                    score = score * 4
                end

                if v.components.combat.target == self.inst then
                    score = score * 6
                end

                if self.controller_attack_target == v then
                    score = score * 10
                end

                if not target or target_score < score then
                    target = v
                    target_score = score
                end
            end
        end
    end

    if not target and self.controller_target and self.controller_target:HasTag("wall") and self.controller_target.components.health and self.controller_target.components.health.currenthealth > 0 then
        target = self.controller_target
    end

    if target ~= self.controller_attack_target then
        self.controller_attack_target = target
        self.controllerattacktargetage = 0
    end


end

function PlayerController:UpdateControllerInteractionTarget(dt)

    if self.controller_target and (not self.controller_target:IsValid() or self.controller_target:IsInLimbo() or self.controller_target:HasTag("NOCLICK")) then
        self.controller_target = nil
    end

    if self.placer or (self.deployplacer and self.deploy_mode) then
        self.controller_target = nil
        self.controllertargetage = 0
        return
    end

    if self.controllertargetage then
        self.controllertargetage = self.controllertargetage + dt
    end

    if self.controllertargetage and self.controllertargetage < .2 then
        return
    end

    local heading_angle = -(self.inst.Transform:GetRotation())
    local dir = Vector3(math.cos(heading_angle * DEGREES), 0, math.sin(heading_angle * DEGREES))

    local me_pos = Vector3(self.inst.Transform:GetWorldPosition())

    local inspect_rad = .75
    local min_rad = 1.5
    local max_rad = 10 -- has to be at least this big to catch "FARSELECT" objects
    local practical_max = 6 -- but most objects will cap at this selection radius
    local rad = max_rad
    if self.controller_target and self.controller_target:IsValid() then
        local dsq = self.inst:GetDistanceSqToInst(self.controller_target)
        rad = math.max(min_rad, math.min(rad, math.sqrt(dsq)))
    end

    local x, y, z = me_pos:Get()

    local nearby_ents = TheSim:FindEntities(x, y, z, rad, nil, { "FX", "NOCLICK", "DECOR", "INLIMBO" })

    if self.controller_target and not self.controller_target:IsInLimbo() then
        table.insert(nearby_ents, self.controller_target) --may double add.. should be harmless?
    end

    local target = nil
    local target_score = nil
    local target_action = nil
    local target_dist = nil

    for k, v in pairs(nearby_ents) do
        if v ~= self.inst then
            if v.entity:GetParent() == self.inst and v:HasTag("bundle") then
                --bundling or constructing
                target = v
                break
            end

            local px, py, pz = v.Transform:GetWorldPosition()
            local ox, oy, oz = px - me_pos.x, py - me_pos.y, pz - me_pos.z
            local dsq = ox * ox + oy * oy + oz * oz

            local already_target = self.controller_target == v or self.controller_attack_target == v

            local should_consider = dsq < min_rad * min_rad or
                    (ox * dir.x + oy * dir.y + oz * dir.z) > 0 or
                    already_target

            if (not v:HasTag("FARSELECT") and dsq > practical_max * practical_max) or dsq > max_rad * max_rad then
                should_consider = false
            end

            if should_consider then

                local dist = dsq > 0 and math.sqrt(dsq) or 0

                local dot = 0
                if dist > 0 then
                    local nx, ny, nz = ox / dist, oy / dist, oz / dist
                    dot = nx * dir.x + ny * dir.y + nz * dir.z
                end

                --keep the angle component between [0..1]
                local angle_component = (dot + 1) / 2

                --distance doesn't matter when you're really close, and then attenuates down from 1 as you get farther away
                local dist_component = dsq < min_rad * min_rad and 1
                        or (v:HasTag("FARSELECT") and 1 / (dsq / 3 / (min_rad * min_rad))) -- some objects are targeted further away
                        or (1 / (dsq / (min_rad * min_rad)))
                local add = 0

                --for stuff that's *really* close - ie, just dropped
                if dsq < .25 * .25 then
                    add = 1
                end
                local mult = 1

                if v == self.controller_target and not v:HasTag("wall") then
                    mult = 1.5--just a little hysteresis
                end

                local score = angle_component * dist_component * mult + add

                --print (v, angle_component, dist_component, mult, add, score)

                if not target_score or score > target_score or not target_action then

                    --this is kind of expensive, so ideally we don't get here for many objects
                    local l, r = self:GetSceneItemControllerAction(v)
                    local action = l or r

                    if not action then
                        local inv_obj = self:GetCursorInventoryObject()
                        if inv_obj then
                            action = self:GetItemUseAction(inv_obj, v)
                        end
                    end

                    if ((action or v.components.inspectable) and (not target_score or score > target_score)) --better real action
                    --or ((action or v.components.inspectable) and ((not target or (target and not target_action)) )) --it's inspectable, so it's better than nothing
                    --or (target and not target_action and action and not( dist > inspect_rad and target_dist < inspect_rad))  --replacing an inspectable with an actual action
                    then
                        target = v
                        target_dist = dist
                        target_score = score
                        target_action = action
                    end
                end
            end
        end
    end

    if target ~= self.controller_target then
        self.controller_target = target
        self.controllertargetage = 0
    end

end

function PlayerController:DoDirectWalking(dt)

    local dir = self:GetWorldControllerVector()
    if dir then
        local ang = -math.atan2(dir.z, dir.x) / DEGREES

        self.inst:ClearBufferedAction()
        self.inst.components.locomotor:SetBufferedAction(nil)
        self.inst.components.locomotor:RunInDirection(ang)
        if not self.directwalking then
            self.time_direct_walking = 0
        end

        self.directwalking = true

        self.time_direct_walking = self.time_direct_walking + dt

        if self.time_direct_walking > .2 then
            if not self.inst.sg:HasStateTag("attack") then
                self.inst.components.combat:SetTarget(nil)
            end
        end
    else
        if self.directwalking then
            self.inst.components.locomotor:Stop()
            self.directwalking = false
        end
    end
end

function PlayerController:WalkButtonDown()
    return TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)
end

function PlayerController:DoCameraControl()
    --camera controls
    local time = GetTime()

    local ROT_REPEAT = .25
    local ZOOM_REPEAT = .1

    if TheCamera:CanControl() then

        if not self.lastrottime or time - self.lastrottime > ROT_REPEAT then

            if TheInput:IsControlPressed(CONTROL_ROTATE_LEFT) then
                self:RotLeft()
                self.lastrottime = time
            elseif TheInput:IsControlPressed(CONTROL_ROTATE_RIGHT) then
                self:RotRight()
                self.lastrottime = time
            end
        end

        if not TheCamera:CanControl()
                or (self.inst.HUD ~= nil and
                self.inst.HUD:IsCraftingOpen()) then
            --Check crafting again because this time
            --we block even with mouse crafting open
            return
        end

        if not self.lastzoomtime or time - self.lastzoomtime > ZOOM_REPEAT then
            if TheInput:IsControlPressed(CONTROL_ZOOM_IN) then
                TheCamera:ZoomIn()
                self.lastzoomtime = time
            elseif TheInput:IsControlPressed(CONTROL_ZOOM_OUT) then
                TheCamera:ZoomOut()
                self.lastzoomtime = time
            end
        end
    end

end

function PlayerController:OnLeftUp()

    if not self:IsEnabled() then
        return
    end

    if self.draggingonground then

        if not self:WalkButtonDown() then
            self.inst.components.locomotor:Stop()
        end
        self.draggingonground = false
        TheFrontEnd:LockFocus(false)
    end
    self.startdragtime = nil

end

function PlayerController:DoAction(buffaction)
    if buffaction then

        if self.inst.bufferedaction then
            if self.inst.bufferedaction.action == buffaction.action and self.inst.bufferedaction.target == buffaction.target then
                return ;
            end
        end

        if buffaction.target then
            if not buffaction.target.components.highlight then
                buffaction.target:AddComponent("highlight")
            end

            buffaction.target.components.highlight:Flash(.2, .125, .1)
        end

        if buffaction.invobject and
                buffaction.invobject.components.equippable and
                buffaction.invobject.components.equippable.equipslot == EQUIPSLOTS.HANDS and
                (buffaction.action ~= ACTIONS.DROP and buffaction.action ~= ACTIONS.STORE) then

            if not buffaction.invobject.components.equippable.isequipped then
                self.inst.components.inventory:Equip(buffaction.invobject)
            end

            if self.inst.components.inventory:GetActiveItem() == buffaction.invobject then
                self.inst.components.inventory:SetActiveItem(nil)
            end
        end

        self.inst.components.locomotor:PushAction(buffaction, true)
    end

end

function PlayerController:OnLeftClick(down)

    if not self:UsingMouse() then
        return
    end

    if not down then
        return self:OnLeftUp()
    end

    self.startdragtime = nil

    if not self:IsEnabled() then
        return
    end

    if TheInput:GetHUDEntityUnderMouse() then
        self:CancelPlacement()
        return
    end

    if self.placer_recipe and self.placer then
        --do the placement
        if self.placer.components.placer.can_build then
            local pos = self.placer.components.placer.targetPos or TheInput:GetWorldPosition()
            self.inst.components.builder:MakeRecipe(self.placer_recipe, TheInput:GetWorldPosition())

            self:CancelPlacement()
        end
        return
    end

    self.inst.components.combat.target = nil

    if self.inst.inbed then
        self.inst.inbed.components.bed:StopSleeping()
        return
    end

    local action = self:GetLeftMouseAction()
    if action then
        self:DoAction(action)
    else

        self:DoAction(BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, TheInput:GetWorldPosition()))
        local clicked = TheInput:GetWorldEntityUnderMouse()
        if not clicked then
            self.startdragtime = GetTime()
        end
    end

end

function PlayerController:OnRightClick(down)

    if not self:UsingMouse() then
        return
    end

    if not down then
        return
    end

    self.startdragtime = nil

    if self.placer_recipe then
        self:CancelPlacement()
        return
    end

    if not self:IsEnabled() then
        return
    end

    if TheInput:GetHUDEntityUnderMouse() then
        return
    end

    if not self:GetRightMouseAction() then
        self.inst.components.inventory:ReturnActiveItem()
    end

    if self.inst.inbed then
        self.inst.inbed.components.bed:StopSleeping()
        return
    end

    local action = self:GetRightMouseAction()
    if action then
        self:DoAction(action)
    end


end

function PlayerController:ShakeCamera(inst, shakeType, duration, speed, maxShake, maxDist)
    local distSq = self.inst:GetDistanceSqToInst(inst)
    local t = math.max(0, math.min(1, distSq / (maxDist * maxDist)))
    local scale = easing.outQuad(t, maxShake, -maxShake, 1)
    if scale > 0 then
        TheCamera:Shake(shakeType, duration, speed, scale)
    end
end

function PlayerController:GetLeftMouseAction()
    return self.LMBaction
end

function PlayerController:GetRightMouseAction()
    return self.RMBaction
end

function PlayerController:GetItemSelfAction(item)
    if not item or self.deploy_mode then
        return
    end
    local lmb = self.inst.components.playeractionpicker:GetInventoryActions(item, false)
    local rmb = self.inst.components.playeractionpicker:GetInventoryActions(item, true)

    local action = (rmb and rmb[1]) or (lmb and lmb[1])
    if action.action ~= ACTIONS.LOOKAT then
        return action
    end
end

function PlayerController:GetSceneItemControllerAction(item)

    local lmb, rmb = nil, nil

    local acts = self.inst.components.playeractionpicker:GetClickActions(item)
    if acts and #acts > 0 then
        local action = acts[1]
        if action.action ~= ACTIONS.LOOKAT and action.action ~= ACTIONS.ATTACK and action.action ~= ACTIONS.WALKTO then
            lmb = acts[1]
        end
    end

    acts = self.inst.components.playeractionpicker:GetRightClickActions(item)
    if acts and #acts > 0 then
        local action = acts[1]
        if action.action ~= ACTIONS.LOOKAT and action.action ~= ACTIONS.ATTACK and action.action ~= ACTIONS.WALKTO then
            rmb = action
        end
    end

    if rmb and lmb and rmb.action == lmb.action then
        rmb = nil
    end

    return lmb, rmb

end

function PlayerController:GetGroundUseAction()
    local position = (self.reticule and self.reticule.targetpos) or
            (self.terraformer and self.terraformer:GetPosition()) or
            (self.placer and self.placer:GetPosition()) or
            (self.deployplacer and self.deployplacer:GetPosition()) or
            self.inst:GetPosition()

    --local position = Vector3(self.inst.Transform:GetWorldPosition())

    local tile = GetWorld().Map:GetTileAtPoint(position.x, position.y, position.z)
    local passable = tile ~= GROUND.IMPASSABLE
    if passable then
        local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equipitem then
            local l, r = self.inst.components.playeractionpicker:GetPointActions(position, equipitem, false), self.inst.components.playeractionpicker:GetPointActions(position, equipitem, true)
            l = l and l[1]
            r = r and r[1]

            if l and l.action == ACTIONS.DROP then
                l = nil
            end
            if l or r then
                if l and l.action == ACTIONS.TERRAFORM then
                    l.distance = 2
                end
                if r and r.action == ACTIONS.TERRAFORM then
                    r.distance = 2
                end
                return l, r
            end

        end
    end

end

local function ValidateItemUseAction(self, act, active_item, target)
    if act and active_item.components.tool and active_item.components.equippable and active_item.components.tool:CanDoAction(act.action) then
        return
    end

    if act and act.action == ACTIONS.STORE and target and target.components.inventoryitem and target.components.inventoryitem:GetGrandOwner() == self.inst then
        return
    end

    if act and act.action ~= ACTIONS.COMBINESTACK and act and act.action ~= ACTIONS.ATTACK then
        return act
    end
end

function PlayerController:GetItemUseAction(active_item, target)
    if not active_item then
        return
    end

    local act

    target = target or self.controller_target
    if target then
        local lmb = self.inst.components.playeractionpicker:GetUseItemActions(target, active_item, false)
        local rmb = self.inst.components.playeractionpicker:GetUseItemActions(target, active_item, true)
        lmb = ValidateItemUseAction(self, lmb and lmb[1], active_item, target)
        rmb = ValidateItemUseAction(self, rmb and rmb[1], active_item, target)
        act = rmb or lmb
    end

    --V2C: Use self actions blocked by controller R.Dpad "TOGGLE_DEPLOY_MODE"
    --     e.g. Murder/Plant, Eat/Plant
    if act ~= nil or not (active_item.components.inventoryitem:IsDeployable(self.inst) and active_item.components.inventoryitem:IsGrandOwner(self.inst)) then
        return act
    end
    act = --[[rmb]] self.inst.components.playeractionpicker:GetInventoryActions(active_item, true)
    act = act[1] ~= nil and act[1].action ~= ACTIONS.TOGGLE_DEPLOY_MODE and act[1] or act[2]
    if act == nil then
        act = --[[lmb]] self.inst.components.playeractionpicker:GetInventoryActions(active_item, false)
        act = act[1] ~= nil and act[1].action ~= ACTIONS.TOGGLE_DEPLOY_MODE and act[1] or act[2]
    end
    return act ~= nil and act.action ~= ACTIONS.LOOKAT and act or nil
end

return PlayerController
