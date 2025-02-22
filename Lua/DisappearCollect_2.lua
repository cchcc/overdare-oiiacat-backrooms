local pathScript = "return workspace.GameZone.Mission." .. script.Name .. ".Part"

local part = load(pathScript)()
local missionPart = part.Parent
local RunService = game:GetService("RunService")

local riseSpeed = 70 -- 위로 올라가는 속도s
local rotateSpeed = 150 -- 초당 회전 속도 (도/초)
local fadeSpeed = 0.5 -- 투명해지는 속도 (초당 1 = 1초 만에 사라짐)
local duration = 1 -- 애니메이션 지속 시간

local elapsedTime = 0 -- 경과 시간


local connection

local function animatePart(deltaTime)
	if elapsedTime >= duration then
		missionPart:Destroy() -- 시간이 지나면 파트 제거
		script:Destroy()
		return
	end

	part.Position = part.Position + Vector3.new(0, riseSpeed * deltaTime, 0)
	part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(rotateSpeed * deltaTime), 0)
	part.Transparency = math.min(1, part.Transparency + fadeSpeed * deltaTime)
	
	--part.Part.Transparency = math.min(1, part.Transparency + fadeSpeed * deltaTime)

	elapsedTime = elapsedTime + deltaTime
end

connection = RunService.Heartbeat:Connect(function(deltaTime)
		if part.Parent then
			animatePart(deltaTime)
		else
			connection:Disconnect()
		end
	end)
