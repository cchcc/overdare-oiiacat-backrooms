-- ReadyZone

local readyZoneFolder = workspace:WaitForChild("ReadyZone")

local readyZone = readyZoneFolder.ReadyZone
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")

local canTouch = true
local TOUCH_DELAY = 0.3

if RunService:IsStudio() then
	--readyZone.Touch.Transparency = 0.5
end

readyZone.Touch.Touched:Connect(function(touched)
	local player = G.getPlayerFromTouched(touched)
	if player and player.Name == Players.LocalPlayer.Name then
		if canTouch then
			canTouch = false
			C2SEvent:FireServer(G.C2S.READY_ZONE_IN)
			wait(TOUCH_DELAY)
			canTouch = true
		end
	end
end)

readyZone.Touch.TouchEnded:Connect(function(touched)
	local player = G.getPlayerFromTouched(touched)
	if player and player.Name == Players.LocalPlayer.Name then
		C2SEvent:FireServer(G.C2S.READY_ZONE_OUT)
	end
end)