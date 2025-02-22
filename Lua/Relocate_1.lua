local part = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local RunService = game:GetService("RunService")

part.Transparency = RunService:IsStudio() and 0.9 or 1

part.Touched:Connect(function(touched)
	local player = G.getPlayerFromTouched(touched)
	if player then
		local character = player.Character
		local humanoid = character.Humanoid
		local humanoidRootPart = character.HumanoidRootPart
		
		local pos = G.getRandomPositionInPart(workspace.GameZone.RelocateJumpZone)
		humanoidRootPart.CFrame = CFrame.new(pos)
	end              
end)