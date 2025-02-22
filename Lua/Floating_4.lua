local RunService = game:GetService("RunService")
local part = script.Parent -- 흔들릴 오브젝트
part.Anchored = true -- 고정된 상태에서 움직임
part.CanCollide = true -- 유저와 충돌 유지

-- 흔들림 설정값
local angle = 0 -- 초기 각도
local speed = 2 -- 흔들림 속도 (값을 조정 가능)
local amplitude = 10 -- 기울기 범위 (값을 조정 가능)

-- RenderStepped를 사용해 자연스럽게 움직임
RunService.Heartbeat:Connect(function(deltaTime)
    -- 각도를 프레임마다 변경 (부드럽게 증가)
    angle = angle + deltaTime * speed

    -- Sine과 Cosine을 이용해 X, Z축으로 자연스럽게 흔들림
    local tiltX = math.sin(angle) * math.rad(amplitude) -- X축 흔들림
    local tiltZ = math.cos(angle) * math.rad(amplitude) -- Z축 흔들림

    -- CFrame 업데이트: 위치를 유지하면서 기울기 추가
    part.CFrame = CFrame.new(part.Position) * CFrame.Angles(tiltX, 0, tiltZ)
end)

