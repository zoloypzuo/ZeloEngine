require("mathutil")

local distToStart = 45
local distToStart_SQ = distToStart * distToStart
local distToFinish = 35
local distToFinish_SQ = distToFinish * distToFinish
local distToLerpOver = distToStart_SQ - distToFinish_SQ
local percentFromPlayer = 1

local STARTING_CAMERA_OFFSET = 1.5
local FINAL_CAMERA_OFFSET = 3

local function roundToNearest(numToRound, multiple)
	local half = multiple/2
	return numToRound+half - (numToRound+half) % multiple
end

local function Update(inst)

	local distToTarget = inst:GetDistanceSqToInst(inst.objToTrack)

	if distToTarget < distToStart_SQ then
		TheCamera:SetControllable(false)
		percentFromPlayer = (distToTarget - distToFinish_SQ)/distToLerpOver
		--if percentFromPlayer < 0 then percentFromPlayer = 0 end
		if percentFromPlayer >= 0 and percentFromPlayer <= 1 then
			local camAngle = Lerp(roundToNearest(inst.prevCamAngle, 360), inst.prevCamAngle, percentFromPlayer)
			local camDist = Lerp(20, inst.prevCamDist, percentFromPlayer)
			TheCamera:SetOffset(Vector3(0,Lerp(FINAL_CAMERA_OFFSET,STARTING_CAMERA_OFFSET,percentFromPlayer),0))
			TheCamera:SetDistance(camDist)
			TheCamera:SetHeadingTarget(camAngle)
			TheCamera:Apply()
		elseif percentFromPlayer < 0 then			
			if TheCamera:GetHeadingTarget() ~= roundToNearest(inst.prevCamAngle, 360) then
				TheCamera:SetOffset(Vector3(0,FINAL_CAMERA_OFFSET,0))
				TheCamera:SetDistance(20)
				TheCamera:SetHeadingTarget(roundToNearest(inst.prevCamAngle, 360))
				TheCamera:Apply()
			end						
		end
	else
		if not TheCamera:IsControllable() then
			TheCamera:SetDistance(inst.prevCamDist)
			TheCamera:SetHeadingTarget(inst.prevCamAngle)
			TheCamera:Apply()
		end
		TheCamera:SetControllable(true)
		inst.prevCamAngle = TheCamera:GetHeadingTarget()
		inst.prevCamDist = TheCamera:GetDistance()
	end
end

local function OnLoad(inst, scenariorunner)
	inst.objToTrack = GetPlayer()
	inst.updatetask = inst:DoPeriodicTask(0.05, Update)
	inst.prevCamDist = 30
	inst.prevCamAngle = 45
end

return 
{
	OnLoad = OnLoad,
}