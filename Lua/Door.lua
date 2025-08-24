wait(0.5)

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")

local canTouch = true
local TOUCH_DELAY = 0.3


-- 문 터치 영역 추가 피벗 스크립트, 터치 파트랑 항상 쌍으로 넣어야함
local doors = {
	--{
		--PivotScript = "return workspace.Pivot",
		--TouchPart = workspace.Pivot.Door.Touch
	--},
}

if G.tableSize(doors) > 0 then 
	setDoors() 
end
	
function setDoors()
	
	for i, door in ipairs(doors) do
	
		local touch = door.TouchPart
	
		touch.Touched:Connect(function(touched)
			--print("door.Touched:")
			
			local player = G.getPlayerFromTouched(touched)
			if player and player.Name == Players.LocalPlayer.Name and G.visibleActionUi() == false then
				local actionButton = player.PlayerGui.ScreenGui.ActionButton
				actionButton.Visible = true
				actionButton:SetAttribute(G.ACTION_TYPE, G.Action.DOOR)
			end
		end)
		
		touch.TouchEnded:Connect(function(touched)
			--print("door.TouchEnded:")
			
			local player = G.getPlayerFromTouched(touched)
			if player and player.Name == Players.LocalPlayer.Name then
				local actionButton = player.PlayerGui.ScreenGui.ActionButton
				actionButton.Visible = false
				actionButton:SetAttribute(G.ACTION_TYPE, nil)
			end
		end)
	
	end
end

