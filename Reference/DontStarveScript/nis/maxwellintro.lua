local maxwell_intro_nis = 
{
    name = "maxwell_intro",
    
    init = function(dat)
        --find wilson, put him to sleep.
        dat.wilson = GetPlayer()
        dat.wilson.components.playercontroller:Enable(false)
        dat.wilson.sg:GoToState("sleep")

        --put maxell to the right of wilson
        dat.maxwell = SpawnPrefab("maxwell")
        local pt = Vector3(dat.wilson.Transform:GetWorldPosition()) + TheCamera:GetRightVec()*4
        dat.maxwell.Transform:SetPosition(pt.x,pt.y,pt.z)
        dat.maxwell:FacePoint(dat.wilson.Transform:GetWorldPosition())

        dat.maxwell:Hide()
        --zoom in
        TheCamera:SetOffset( (Vector3(dat.maxwell.Transform:GetWorldPosition()) - Vector3(dat.wilson.Transform:GetWorldPosition()))*.5  + Vector3(0,2,0) )
        TheCamera:SetDistance(15)
        TheCamera:Snap()        
    end,
		
    script = function(nis, dat, lines)
        
        dat.maxwell:Show()
        dat.maxwell.AnimState:PlayAnimation("appear")
        dat.maxwell.AnimState:PushAnimation("idle", true)
        Sleep(.3)
        dat.maxwell.SoundEmitter:PlaySound("dontstarve/maxwell/disappear")
        PlayFX(dat.maxwell.Transform:GetWorldPosition(), "max_fx", "max_fx", "anim")        
        Sleep(.7)
        nis.skippable = true
        Sleep(1.5)

        if lines ~= nil then
        	for k,v in ipairs(lines) do
	            dat.maxwell.AnimState:PlayAnimation("dialog_pre") 
	            dat.maxwell.AnimState:PushAnimation("dial_loop", true)
	            dat.maxwell.SoundEmitter:PlaySound("dontstarve/maxwell/talk_LP", "talk")
	            dat.maxwell.components.talker:Say{Line(v, 2.5)}
	            Sleep(2.5)
	            dat.maxwell.SoundEmitter:KillSound("talk")
	            dat.maxwell.AnimState:PlayAnimation("dialog_pst")
	            
	            if k ~= #lines then
	                dat.maxwell.AnimState:PushAnimation("idle", true)
	                Sleep(1)
	            end
	       end
        end
        
        nis.skippable = false
        --make maxwell disappear, and wake up wilson
        dat.maxwell:DoTaskInTime(.4, function() 
                dat.maxwell.SoundEmitter:PlaySound("dontstarve/maxwell/disappear") 
                PlayFX(dat.maxwell.Transform:GetWorldPosition(), "max_fx", "max_fx", "anim")
        end)

        dat.maxwell.AnimState:PushAnimation("disappear", false)
        dat.wilson.sg:GoToState("wakeup")
        dat.maxwell:ListenForEvent("animqueueover", function(inst) inst:Remove() end)
        Sleep(1.5)

        --make game state normal again
        dat.wilson.components.playercontroller:Enable(true)
        TheCamera:SetDefault()
        
    end,

    cancel = function(dat)
        
        dat.wilson.sg:GoToState("idle")
        --dat.maxwell:Remove()
        dat.maxwell:DoTaskInTime(.4, function() dat.maxwell.SoundEmitter:PlaySound("dontstarve/maxwell/disappear") end)
        dat.maxwell.AnimState:PlayAnimation("disappear")
        --dat.maxwell.SoundEmitter:PlaySound("dontstarve/maxwell/disappear")
        
        dat.maxwell:ListenForEvent("animover", function(inst) inst:Remove() end)
        dat.wilson.components.playercontroller:Enable(true)
        
        TheCamera:SetDefault()
    end
}

return maxwell_intro_nis
