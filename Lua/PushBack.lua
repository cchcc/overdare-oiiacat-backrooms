local part = script.Parent
local RunService = game:GetService("RunService")

print("pushback: " .. part)

local moveSpeed = 4000

local connection = RunService.Heartbeat:Connect(function(deltaTime)
    -- 뒤쪽 방향으로 이동 (LookVector의 반대 방향)
    part.Position = part.Position - part.CFrame.LookVector * moveSpeed * deltaTime
end)


wait(0.12)
connection:Disconnect()
script:Destroy()
