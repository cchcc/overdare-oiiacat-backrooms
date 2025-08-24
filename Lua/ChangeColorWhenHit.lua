-- local loadstring = require(script:WaitForChild("Loadstring"))

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local target = script:GetAttribute(G.TARGET)
local part = nil
if target == "door" then
	part = workspace.GameZone.DoorWall
end
local CollectionService = game:GetService("CollectionService")

if part then
	part.Touched:Connect(function(touched)
		--print(part .. " touched :" .. touched)
		if CollectionService:HasTag(touched, G.Tag.HitRange) then
			--print("hit range")
			wait(0.15)
			local lastColor = part.Color
			part.Color = Color3.new(151, 0, 0)  -- red
			wait(0.15)
			part.Color = lastColor
		end
	end)
end