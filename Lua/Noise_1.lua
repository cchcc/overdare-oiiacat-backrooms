local imageLabel = script.Parent
while true do
	
	local randomOffsetX = math.random(-50, 50) / 100 
	local randomOffsetY = math.random(-30, 30) / 100 
	
	imageLabel.Position = UDim2.new(-0.5 + randomOffsetX, 0, -0.5 + randomOffsetY, 0) 
	wait(0.05) 
end
local RunService = game:GetService("RunService")
local elaspedTime = 0
RunService.Stepped:Connect(function(deltaTime)
	elaspedTime = elaspedTime + deltaTime
	if elaspedTime > 0.05 then 
		local randomOffsetX = math.random(-50, 50) / 100 
		local randomOffsetY = math.random(-30, 30) / 100 
	
		imageLabel.Position = UDim2.new(-0.5 + randomOffsetX, 0, -0.5 + randomOffsetY, 0)
		elaspedTime = 0
	end
	
end)