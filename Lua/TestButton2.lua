local button = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
button.Visible = RunService:IsStudio()


-- 버튼 클릭시
button.Activated:Connect(function()
	C2SEvent:FireServer(G.C2S.EQUIP_OR_ATTACK)
end)
