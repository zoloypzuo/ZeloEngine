

local function MakeFx(name, bank, build, anim, sound, sounddelay, tint, tintalpha, transform, sound2, sounddelay2, fnc, fntime)
    local assets = 
    {
        Asset("ANIM", "anim/"..build..".zip")
    }

    local function fn()
        --print ("SPAWN", debugstack())
    	local inst = CreateEntity()
    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()

        inst.Transform:SetFourFaced()

        if type(anim) ~= "string" then
            anim = anim[math.random(#anim)]
        end

        if sound or sound2 then
            inst.entity:AddSoundEmitter()
        end
        
        if fnc and fntime then
            inst:DoTaskInTime(fntime, fnc)
        end

        if sound then
            inst:DoTaskInTime(sounddelay or 0, function() inst.SoundEmitter:PlaySound(sound) end)
        end

        if sound2 then
            inst:DoTaskInTime(sounddelay2 or 0, function() inst.SoundEmitter:PlaySound(sound2) end)
        end


        inst.AnimState:SetBank(bank)
        inst.AnimState:SetBuild(build)
        inst.AnimState:PlayAnimation(anim)
        if tint or tintalpha then
            inst.AnimState:SetMultColour((tint and tint.x) or (tintalpha or 1),(tint and tint.y)  or (tintalpha or 1),(tint and tint.z)  or (tintalpha or 1), tintalpha or 1)
        end
        --print(inst.AnimState:GetMultColour())
        if transform then
            inst.AnimState:SetScale(transform.x, transform.y, transform.z)
        end

        inst:AddTag("FX")
        inst.persists = false
        inst:ListenForEvent("animover", function() inst:Remove() end)

        return inst
    end
    return Prefab("common/"..name, fn, assets)
end

local prefs = {}
local fx = require("fx") 

for k,v in pairs(fx) do
    table.insert(prefs, MakeFx(v.name, v.bank, v.build, v.anim, v.sound, v.sounddelay, v.tint, v.tintalpha, v.transform, v.sound2, v.sounddelay2, v.fn, v.fntime))
end

return unpack(prefs)
