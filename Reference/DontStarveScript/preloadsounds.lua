require "dlcsupport"

local DLCSounds = 
{
	"amb_stream.fsb",
	"amb_stream_SW.fsb",
	"bearger.fsb",
	"buzzard.fsb",
	"catcoon.fsb",
	"decidous.fsb",
	"DLC_music.fsb",
	"dontstarve_DLC001.fev",
	"dragonfly.fsb",
	"glommer.fsb",
	"goosemoose.fsb",
	"lightninggoat.fsb",
	"mole.fsb",
	"stuff.fsb",
	"vargr.fsb",
	"wathgrithr.fsb",
	"webber.fsb",
	--"wyro.fsb",
}

local MainSounds = 
{
	"bat.fsb",
	"bee.fsb",
	"beefalo.fsb",
	"birds.fsb",
	"bunnyman.fsb",
	"cave_AMB.fsb",
	"cave_mem.fsb",
	"chess.fsb",
	"chester.fsb",
	"common.fsb",
	"deerclops.fsb",
	"dontstarve.fev",
	"dontstarve_wagstaff.fev",
	"forest.fsb",
	"forest_stream.fsb",
	"frog.fsb",
	"ghost.fsb",
	"gramaphone.fsb",
	"hound.fsb",
	"koalefant.fsb",
	"krampus.fsb",
	"leif.fsb",
	"mandrake.fsb",
	"maxwell.fsb",
	"mctusky.fsb",
	"merm.fsb",
	"monkey.fsb",
	"music.fsb",
	"pengull.fsb",
	"perd.fsb",
	"pig.fsb",
	"plant.fsb",
	"rabbit.fsb",
	"rocklobster.fsb",
	"sanity.fsb",
	"sfx.fsb",
	"slurper.fsb",
	"slurtle.fsb",
	"spider.fsb",
	"tallbird.fsb",
	"tentacle.fsb",
	"wallace.fsb",
	"wendy.fsb",
	"wickerbottom.fsb",
	"willow.fsb",
	"wilson.fsb",
	"wilton.fsb",
	"winnie.fsb",
	"wolfgang.fsb",
	"woodie.fsb",
	"woodrow.fsb",
	"worm.fsb",
	"wx78.fsb",
	"wyro.fsb",
	"wagstaff.fsb",
}

function PreloadSoundList(list)
	for i,v in pairs(list) do
		TheSim:PreloadFile("sound/"..v)
	end
end

function PreloadSounds()
	-- preload DLC sounds
	if IsDLCInstalled(REIGN_OF_GIANTS) then
		PreloadSoundList(DLCSounds)
	end
	PreloadSoundList(MainSounds)
end
