local part = script.Parent

-- 회전 시키기
while true do
	wait(0.2)
	part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(30), 0)  
end