local imageLabel = script.Parent
while true do
	-- 화면 바깥으로도 움직이게 X, Y 범위 확대
	local randomOffsetX = math.random(-50, 50) / 100 -- X축 범위
	local randomOffsetY = math.random(-30, 30) / 100 -- Y축 범위
	-- ImageLabel 위치 조정
	imageLabel.Position = UDim2.new(-0.5 + randomOffsetX, 0, -0.5 + randomOffsetY, 0) -- 중심 기준으로 랜덤 이동
	wait(0.05) -- 속도 조정
end
local RunService = game:GetService("RunService")
local elaspedTime = 0
RunService.Stepped:Connect(function(deltaTime)
	elaspedTime = elaspedTime + deltaTime
	if elaspedTime > 0.05 then 
		local randomOffsetX = math.random(-50, 50) / 100 -- X축 범위
		local randomOffsetY = math.random(-30, 30) / 100 -- Y축 범위
	
		-- ImageLabel 위치 조정
		imageLabel.Position = UDim2.new(-0.5 + randomOffsetX, 0, -0.5 + randomOffsetY, 0) 
		elaspedTime = 0
	end	
	
end)