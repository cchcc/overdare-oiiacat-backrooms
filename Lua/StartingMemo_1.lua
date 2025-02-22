-- StartingMemo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")

local gameZoneFolder = workspace:WaitForChild("GameZone")
local startingMemo = gameZoneFolder.StartingMemo

startingMemo.Touched:Connect(function(touched)
	--print("startingMemo.Touched:")
	
	local player = G.getPlayerFromTouched(touched)
	if player and player.Name == Players.LocalPlayer.Name and G.visibleActionUi() == false then
		local actionButton = player.PlayerGui.ScreenGui.ActionButton
		actionButton.Visible = true
		actionButton:SetAttribute(G.ACTION_TYPE, G.Action.STARTING_MEMO)
	end
end)

startingMemo.TouchEnded:Connect(function(touched)
	--print("startingMemo.TouchEnded:")
	
	local player = G.getPlayerFromTouched(touched)
	if player and player.Name == Players.LocalPlayer.Name then
		local actionButton = player.PlayerGui.ScreenGui.ActionButton
		actionButton.Visible = false
		actionButton:SetAttribute(G.ACTION_TYPE, nil)
	end
end)
