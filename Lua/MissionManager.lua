local MissionManager = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local GameManager = require(ReplicatedStorage.GameManager)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local Players = game:GetService("Players")
local gameZoneFolder = workspace:WaitForChild("GameZone")
local missionFolder = gameZoneFolder.Mission


local MISSION_COLLECT_POSITIONS = {
	Vector3.new(1248.310669, 117.643326, 165.69162),
	Vector3.new(1328.310669, 337.643311, -2124.30835),
	Vector3.new(1333.079346, 99.439789, -3934.3125),
	Vector3.new(-841.689392, 107.643326, -2684.30835),
	Vector3.new(-1150.0, 133.822784, 240.0),
	Vector3.new(-1750.0, 143.822784, -3930.0),
	Vector3.new(-1790.0, 153.822784, -1810.0),
}
	
-- 액션 버튼 UI 연결
local function applyActionButtonUi(actionType, obj, index)
	obj.Touched:Connect(function(touched)
	
		local player = G.getPlayerFromTouched(touched)
		if player and player.Name == Players.LocalPlayer.Name and G.visibleActionUi() == false then
			local actionButton = player.PlayerGui.ScreenGui.ActionButton
			actionButton.Visible = true
			actionButton:SetAttribute(G.ACTION_TYPE, actionType)
			actionButton:SetAttribute(G.INDEX, index)
		end
	end)
	
	
	obj.TouchEnded:Connect(function(touched)
		
		local player = G.getPlayerFromTouched(touched)
		if player and player.Name == Players.LocalPlayer.Name then
			local actionButton = player.PlayerGui.ScreenGui.ActionButton
				actionButton.Visible = false
				actionButton:SetAttribute(G.ACTION_TYPE, nil)
				actionButton:SetAttribute(G.INDEX, nil)
		end
	end)
end

local function findMissionPart(index)
	for _, mission in ipairs(missionFolder:GetChildren()) do
		if mission:GetAttribute(G.INDEX) == index then
			return mission
		end
	end
	return nil
end

-- 게임 시작시 미션 초기화
function MissionManager.init(missions)
	local player = Players.LocalPlayer
	local actionButton = player.PlayerGui.ScreenGui.ActionButton
	

	for _, o in pairs(missionFolder:GetChildren()) do
		o:Destroy()
	end
		
	-- 수집미션 랜덤위치
	local collectMissionPosition = G.getRandomSelection(MISSION_COLLECT_POSITIONS, #missions)
	
	for i, mission in pairs(missions) do
		if mission.type == G.MissionType.Collect then
			local missionPart = ReplicatedStorage.Mission.Mission_Collect:Clone()
			missionPart.Position = collectMissionPosition[i]
			missionPart.Name = missionPart.Name .. i
			missionPart:SetAttribute("index", i)
			applyActionButtonUi(G.Action.MISSION_COLLECT, missionPart, i)

			if not RunService:IsStudio() then
				missionPart.Transparency = 1
			end
			
			missionPart.Parent = missionFolder
		end
	end

end

function MissionManager.clickedActionButton(index, missionType)
	if missionType == G.MissionType.Collect then
		local missionPart = findMissionPart(index)
		--missionPart:Destroy()
		
		local disappearCollectScript = ReplicatedStorage.Script.DisappearCollect:Clone()
		disappearCollectScript.Name = missionPart.Name
		disappearCollectScript.Parent = Players.LocalPlayer.PlayerScripts
				
		
		C2SEvent:FireServer(G.C2S.COMPLETE_MISSION, index)
		
		-- jumpscare
		if math.random(1,10) < 5 then
			GameManager.jumpscare(Players.LocalPlayer)
		end		
	end
end

return MissionManager