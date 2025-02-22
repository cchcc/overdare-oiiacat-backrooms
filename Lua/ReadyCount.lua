-- ReadyCount > LocalScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")

local readyCount = script.Parent
S2CEvent.OnClientEvent:Connect(function(msg, data)
	-- print("S2C: " .. msg .. ", " .. (data or ""))
	
	if msg == G.S2C.READY_COUNT then
		readyCount.Text = data
		readyCount.Visible = data and string.len(data) > 0
	end
	
end)