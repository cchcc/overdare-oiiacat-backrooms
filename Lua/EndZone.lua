-- EndZone

local gameZoneFolder = workspace:WaitForChild("GameZone")
local endZone = gameZoneFolder.EndZone

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")

local canTouch = true
local TOUCH_DELAY = 0.3

local inEndZone = false

local function restartCount(player)
	local count = G.MAX_RESTART_COUNT
	local readyCount = player.PlayerGui.ScreenGui.ReadyCount
	readyCount.Visible = true
	
	while count >= 0 and inEndZone do
		readyCount.Text = "FINISH\n" .. count
		count = count - 1
		if count < 0 then
			C2SEvent:FireServer(G.C2S.RESTART)
			readyCount.Visible = false
			readyCount.Text = ""
			
			local character = player.Character
			local equippedTool = character:FindFirstChildOfClass("Tool")
			if equippedTool then  -- 혹시 기존 장착 tool 있으면 제거
				equippedTool:Destroy()
				player.PlayerGui.ScreenGui.AttackButton.Visible = false
			end
			player.PlayerGui.ScreenGui.Clear.Visible = true
		else
			readyCount.Visible = true
		end
		wait(1)
	end
end

if RunService:IsStudio() then
	endZone.Touch.Transparency = 0.5
end

endZone.Touch.Touched:Connect(function(touched)
	local player = G.getPlayerFromTouched(touched)
	if player and player.Name == Players.LocalPlayer.Name then
		--print("endZone.Touched: " .. player.Name)
		
		inEndZone = true
		if canTouch then
			canTouch = false
			restartCount(player)
		end
		
		wait(TOUCH_DELAY)
			canTouch = true
	end
end)

endZone.Touch.TouchEnded:Connect(function(touched)
	local player = G.getPlayerFromTouched(touched)
	if player and player.Name == Players.LocalPlayer.Name then
		inEndZone = false
		local readyCount = player.PlayerGui.ScreenGui.ReadyCount
		readyCount.Visible = false
		readyCount.Text = ""
	end
end)