local Mixer = require("mixer")


local amb = "set_ambience/ambience"
local cloud = "set_ambience/cloud"
local music = "set_music/soundtrack"
local voice = "set_sfx/voice"
local movement ="set_sfx/movement"
local creature ="set_sfx/creature"
local player ="set_sfx/player"
local HUD ="set_sfx/HUD"
local sfx ="set_sfx/sfx"
local slurp ="set_sfx/everything_else_muted"
local twister ="set_sfx/twister_attack"
local mute ="set_sfx/everything_else_muted"
local shadow ="set_sfx/shadow"

--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)

TheMixer:AddNewMix("normal", 2, 1,
{ 
	[amb] = .8,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = 1,
	[creature] = 1,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,
	[slurp] = 1,
	[twister] = 1,
	[twister] = 1,
	[shadow] = 1,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("high", 2, 3,
{ 
	[amb] = .2,
	[cloud] = 1,
	[music] = .5,
	[voice] = .7,
	[movement] = .7,
	[creature] = .7,
	[player] = .7,
	[HUD] = 1,
	[sfx] = .7,
	[slurp] = 1,
	[twister] = 1,
	[shadow] = .7,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("start", 1, 0,
{
	[amb] = .8,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = 1,
	[creature] = 1,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,
	[slurp] = 1,
	[twister] = 1,
	[shadow] = 1,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("pause", 1, 4,
{
	[amb] = .1,
	[cloud] = .1,
	[music] = 0,
	[voice] = 0,
	[movement] = 0,
	[creature] = 0,
	[player] = 0,
	[HUD] = 1,
	[sfx] = 0,
	[slurp] = 0,
	[twister] = 1, --0
	[shadow] = 0,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("death", 1, 6,
{
	[amb] = .2,
	[cloud] = .2,
	[music] = 0,
	[voice] = 1,
	[movement] = .8,
	[creature] = .8,
	[player] = 1,
	[HUD] = 1,
	[sfx] = .8,
	[slurp] = .8,
	[twister] = 1,
	[shadow] = .8,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("slurp", 1, 1,
{
	[amb] = .2,
	[cloud] = .2,
	[music] = .5,
	[voice] = .7,
	[movement] = .7,
	[creature] = .7,
	[player] = .7,
	[HUD] = 1,
	[sfx] = .7,
	[slurp] = 1,
	[twister] = 1,
	[shadow] = .7,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("twister", 1, 7, --3.5
{
	[amb] = .6,
	[cloud] = .6,
	[music] = .8,
	[voice] = .6,
	[movement] = .6,
	[creature] = .5,
	[player] = .6,
	[HUD] = 1,
	[sfx] = .6,
	[slurp] = .1,
	[twister] = 1,
	[shadow] = .5,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("mute", 0, 4,
{
	[amb] = .1,
	[cloud] = .1,
	[music] = 0,
	[voice] = 0,
	[movement] = 0,
	[creature] = 0,
	[player] = 0,
	[HUD] = 1,
	[sfx] = 0,
	[slurp] = 0,
	[twister] = 0, 
	[mute] = 1,
	[shadow] = 0,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("boss_fight", 1, 4,
{
	[amb] = .2,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = .3,
	[creature] = 1,
	[player] = .5,
	[HUD] = 1,
	[sfx] = .7,
	[slurp] = 1,
	[twister] = 1,
	[shadow] = .3,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("fog", 2, 1,
{ 
	[amb] = .5,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = 1,
	[creature] = .5,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,
	[slurp] = 1,
	[twister] = 1,
	[shadow] = .3,
})
--function Mixer:AddNewMix(name, fadetime, priority, levels, reverb)
TheMixer:AddNewMix("shadow", 1, 3,
{ 
	[amb] = .2,
	[cloud] = 0,
	[music] = 1,
	[voice] = 1,
	[movement] = 1,
	[creature] = 1,
	[player] = 1,
	[HUD] = 1,
	[sfx] = 1,
	[slurp] = 1,
	[twister] = 1,
	[shadow] = .3,
})

TheMixer:AddNewMix("boom", 0, 4,
{
	[amb] = .1,
	[cloud] = .1,
	[music] = .5,
	[voice] = 0,
	[movement] = 0,
	[creature] = 1,
	[player] = 0,
	[HUD] = 1,
	[sfx] = 1,
	[slurp] = 0,
	[twister] = 1, --0
	[shadow] = 0,
})