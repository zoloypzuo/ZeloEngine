local MaxwellTalker = Class(function(self, inst)
	self.inst = inst
	self.speech = nil
	self.speeches = nil
	self.canskip = false
	self.defaultvoice = "dontstarve/maxwell/talk_LP"
	self.inputhandlers = {}
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_PRIMARY, function() self:OnClick() end))    
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_SECONDARY, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_ATTACK, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_INSPECT, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_ACTION, function() self:OnClick() end))
    table.insert(self.inputhandlers, TheInput:AddControlHandler(CONTROL_CONTROLLER_ACTION, function() self:OnClick() end))
end)

function MaxwellTalker:OnCancel()

    if self.inst.components.talker then
		self.inst.components.talker:ShutUp()
	end

	if self.inst.speech.disableplayer and self.inst.wilson then
	    if self.inst.wilson.sg.currentstate.name == "sleep" then		
		    self.inst.SoundEmitter:KillSound("talk")	--ensures any talking sounds have stopped
		    if self.inst.speech.disappearanim then
                if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
	                self.inst.SoundEmitter:PlaySound("dontstarve/maxwell/disappear_adventure")

	                local fx = SpawnPrefab("maxwell_smoke")
                    
    				fx.Transform:SetPosition(self.inst.Transform:GetWorldPosition())


	                --PlayFX(Point(self.inst.Transform:GetWorldPosition()), "max_fx", "max_fx", "anim")
		        else
	                self.inst:DoTaskInTime(.4, function()
                        self.inst.SoundEmitter:PlaySound("dontstarve/maxwell/disappear")
                        local fx = SpawnPrefab("maxwell_smoke")
    					fx.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
						self.inst.DynamicShadow:Enable(false)        
	                end)
		        end
		        self.inst.AnimState:PlayAnimation(self.inst.speech.disappearanim, false)
		    end	--plays the disappear animation and removes from scene
			self.inst:ListenForEvent("animqueueover", function() self.inst:Remove() end)		    
		    self.inst.wilson.sg:GoToState("wakeup")
		    self.inst.wilson:DoTaskInTime(1.5, function() self.inst.wilson.components.playercontroller:Enable(true) end)
		else
            self.inst.wilson.components.playercontroller:Enable(true)
        end
        
		GetPlayer().HUD:Show()
		TheCamera:SetDefault()
	end
end

function MaxwellTalker:OnClick()
	if self.inst.speech and self.canskip and self.inst.speech.disableplayer then

		scheduler:KillTask(self.inst.task)
		self:OnCancel()
		for k,v in pairs(self.inputhandlers) do
	        v:Remove()
	    end
	end
end

function MaxwellTalker:StopTalking()
	
    if self.inst.components.talker then
		self.inst.components.talker:ShutUp()
	end

	scheduler:KillTask(self.inst.task)
	self.inst.SoundEmitter:KillSound("talk")
	self.inst.speech = nil


end

function MaxwellTalker:Initialize()
	self.inst.speech = self.speeches[self.speech or "NULL_SPEECH"] --This would be specified through whatever spawns this at the start of a level

	if self.inst.speech and self.inst.speech.disableplayer then
		self.inst.wilson = GetPlayer()
		GetPlayer().HUD:Hide()
        self.inst.wilson.components.playercontroller:Enable(false)
        self.inst.wilson.sg:GoToState("sleep")		

        local pt = Vector3(self.inst.wilson.Transform:GetWorldPosition()) + TheCamera:GetRightVec()*4
        self.inst.Transform:SetPosition(pt.x,pt.y,pt.z)
        self.inst:FacePoint(self.inst.wilson.Transform:GetWorldPosition())
        	
        self.inst:Hide()

        --zoom in
        TheCamera:SetOffset( (Vector3(self.inst.Transform:GetWorldPosition()) - Vector3(self.inst.wilson.Transform:GetWorldPosition()))*.5  + Vector3(0,2,0) )
        TheCamera:SetDistance(15)
        TheCamera:Snap()
        GetPlayer().HUD:Hide()   	
	end
end

function MaxwellTalker:IsTalking()
	return self.inst.speech ~= nil
end

function MaxwellTalker:DoTalk()	
	self.inst.speech = self.speeches[self.speech or "NULL_SPEECH"] --This would be specified through whatever spawns this at the start of a level
	self.inst:Show()
	
	if self.inst.speech then
		--GetPlayer().HUD:Hide()
		if self.inst.speech.delay then
			Sleep(self.inst.speech.delay)
		end
		if self.inst.speech and self.inst.speech.appearanim then self.inst.AnimState:PlayAnimation(self.inst.speech.appearanim) end
		if self.inst.speech and self.inst.speech.idleanim then self.inst.AnimState:PushAnimation(self.inst.speech.idleanim, true) end
		
		if self.inst.speech and self.inst.speech.appearanim then			
            if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
			    self.inst.SoundEmitter:PlaySound("dontstarve/maxwell/appear_adventure")
			    Sleep(1.4)
			else
			    Sleep(0.4)
	            self.inst.SoundEmitter:PlaySound("dontstarve/maxwell/disappear")
	            local fx = SpawnPrefab("maxwell_smoke")
    			fx.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
			    Sleep(1)
			end
		end

		self.canskip = true
		local length = #self.inst.speech or 1
		for k, section in ipairs(self.inst.speech) do --the loop that goes on while the speech is happening
			local wait = section.wait or 1

			if section.anim then --If there's a custom animation it plays it here.
				self.inst.AnimState:PlayAnimation(section.anim)
				if self.inst.speech and self.inst.speech.idleanim then self.inst.AnimState:PushAnimation(self.inst.speech.idleanim, true) end
			end

	        if section.string then --If there is speech to be said, it displays the text and overwrites any custom anims with the talking anims
	        	if self.inst.speech and self.inst.speech.dialogpreanim then self.inst.AnimState:PlayAnimation(self.inst.speech.dialogpreanim) end
	        	if self.inst.speech and self.inst.speech.dialoganim then self.inst.AnimState:PushAnimation(self.inst.speech.dialoganim, true) end
		        self.inst.SoundEmitter:PlaySound(self.inst.speech.voice or self.defaultvoice, "talk")
		        if self.inst.components.talker then
					self.inst.components.talker:Say(section.string, wait)
				end
			end

			if section.sound then	--If there's an extra sound to be played it plays here.
				self.inst.SoundEmitter:PlaySound(section.sound)
			end

			Sleep(wait)	--waits for the allocated time.

			if section.string then	--If maxwell was talking it winds down here and stops the anim.
				self.inst.SoundEmitter:KillSound("talk")
		        if self.inst.speech and self.inst.speech.dialogpostanim then self.inst.AnimState:PlayAnimation(self.inst.speech.dialogpostanim) end
	        end

	       	if self.inst.speech and self.inst.speech.idleanim then  self.inst.AnimState:PushAnimation(self.inst.speech.idleanim, true) end--goes to an idle animation

        	Sleep(section.waitbetweenlines or 0.5)	--pauses between lines
		end
		
		self.inst.SoundEmitter:KillSound("talk")	--ensures any talking sounds have stopped

		if self.inst.speech and self.inst.speech.disappearanim then
            if SaveGameIndex:GetCurrentMode(Settings.save_slot) == "adventure" then
			    self.inst.SoundEmitter:PlaySound("dontstarve/maxwell/disappear_adventure")
			    local fx = SpawnPrefab("maxwell_smoke")
    			fx.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
			else
				self.inst.DynamicShadow:Enable(false)        
	            self.inst.SoundEmitter:PlaySound("dontstarve/maxwell/disappear")
	            local fx = SpawnPrefab("maxwell_smoke")
    			fx.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
			end
			self.inst.AnimState:PlayAnimation(self.inst.speech.disappearanim, false) --plays the disappear animation and removes from scene
			self.inst:ListenForEvent("animqueueover", function()  self.inst:Remove() end)
		end
		if self.inst.speech and self.inst.speech.disableplayer and self.inst.wilson and self.inst.wilson.sg.currentstate.name == "sleep" then		
			self.inst.wilson.sg:GoToState("wakeup") 
			self.inst.wilson:DoTaskInTime(1.5, function() 
				self.inst.wilson.components.playercontroller:Enable(true)			
				GetPlayer().HUD:Show()
				TheCamera:SetDefault()
			end)
		end
		
		
		self.inst.speech = nil --remove the speech after done
	end
	for k,v in pairs(self.inputhandlers) do
	        v:Remove()
	end
end

function MaxwellTalker:SetSpeech(speech)
	if speech then self.speech = speech end
end

return MaxwellTalker