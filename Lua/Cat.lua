local part = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)

part.Touched:Connect(function(touched)
	local player = G.getPlayerFromTouched(touched)
	if player then
		-- print(part .. " touched : " .. player)
		local pushBack = ReplicatedStorage.Script.PushBack:Clone()
		pushBack.Parent = player.Character.HumanoidRootPart
	end
end)