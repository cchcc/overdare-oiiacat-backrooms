local part = script.Parent
local runService = game:GetService("RunService")

local moveSpeed = 700 -- 이동 속도
local moveRange = 650 -- 최대 이동 거리
local direction = 1 -- 방향 (1 = 오른쪽, -1 = 왼쪽)

local startPosition = part.Position

runService.Heartbeat:Connect(function(deltaTime)
    part.Position = part.Position + Vector3.new(moveSpeed * direction * deltaTime, 0, 0)

    if math.abs(part.Position.X - startPosition.X) >= moveRange then
        direction = -direction -- 방향 반전
    end
end)
