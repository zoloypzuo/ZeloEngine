local NightmareAmbientSoundMixer = Class(function(self, inst)
    self.inst = inst

    self.inst:ListenForEvent( "warnstart", function(it, data) 
			self:SetSoundParam(1)
			self.inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_warning")
        end, GetWorld())      

    self.inst:ListenForEvent( "calmstart", function(it, data) 
			self:SetSoundParam(0)
        end, GetWorld())      

    self.inst:ListenForEvent( "nightmarestart", function(it, data) 
			self:SetSoundParam(2)
			self.inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_full")
        end, GetWorld())  

    self.inst:ListenForEvent( "dawnstart", function(it, data) 
		self:SetSoundParam(1)
		self.inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_end")
    end, GetWorld())        
end)

function NightmareAmbientSoundMixer:SetSoundParam(val)
	if not self.inst.SoundEmitter:PlayingSound("nightmare_loop") then
		self.inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare", "nightmare_loop")
	end
	self.inst.SoundEmitter:SetParameter("nightmare_loop", "nightmare", val)
end

return NightmareAmbientSoundMixer
