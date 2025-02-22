local button = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local GameManager = require(ReplicatedStorage.GameManager)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
button.Visible = RunService:IsStudio()


local firstPerson = false

-- 버튼 클릭시
button.Activated:Connect(function()
	GameManager.jumpscare(Players.LocalPlayer)
	-- C2SEvent:FireServer(G.C2S.EQUIP_OR_ATTACK)
	--jumpscare()
	
	--switchCamera()
end)

local lastSubject = nil
local firstPerson = false

function switchCamera()
	local player = Players.LocalPlayer
	local camera = game.Workspace.CurrentCamera
	local humanoidRootPart = player.Character.HumanoidRootPart
	local characterSize = humanoidRootPart.Size
	firstPerson = not firstPerson -- 1인칭 여부 변경
    
    if firstPerson then
		-- 시점 변경용 파트
		local viewPart = Instance.new("Part")
		viewPart.Name = "ViewPart"
		viewPart.Anchored = true
		viewPart.CanCollide = false
		viewPart.CanTouch = false
		viewPart.Size = Vector3.new(characterSize.X, 30, characterSize.Z)
		viewPart.Position = Vector3.new(0, 150, -characterSize.Z)
		viewPart.Transparency = 0.9
		viewPart.Parent = humanoidRootPart		
		
		--local viewPart = player.Character.HumanoidRootPart.ViewPart
        local viewPartPos = viewPart.Position
        
        camera.CameraType = Enum.CameraType.Follow
        lastSubject = camera.CameraSubject
        camera.CameraSubject = viewPart
        
        -- jumpscare
        local jumpScare = ReplicatedStorage.JumpScare:Clone()
        jumpScare.Position = viewPart.Position + (viewPart.CFrame.LookVector * (viewPart.Size.Z * 2.5))
        jumpScare.Parent = workspace
        
        

		local connection = RunService.Heartbeat:Connect(function(deltaTime)
			local moveSpeed = 250
    		-- 뒤쪽 방향으로 이동 (LookVector의 반대 방향)
    		jumpScare.Position = jumpScare.Position - player.Character.HumanoidRootPart.CFrame.LookVector * moveSpeed * deltaTime
		end)


		wait(0.11)
		connection:Disconnect()

		wait(2)
		jumpScare:Destroy()		
		
    else
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = lastSubject
    end
end


function jumpscare()
	local player = Players.LocalPlayer
	local camera = game.Workspace.CurrentCamera
	local humanoidRootPart = player.Character.HumanoidRootPart
	local characterSize = humanoidRootPart.Size
	local characterPos = humanoidRootPart.Position
	
	-- 시점 변경용 파트
	local viewPart = Instance.new("Part")
	viewPart.Name = "ViewPart"
	viewPart.Anchored = true
	viewPart.CanCollide = false
	viewPart.CanTouch = false
	viewPart.Size = Vector3.new(characterSize.X, 30, characterSize.Z)
	viewPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 40, -(characterSize.Z))
	viewPart.Transparency = 0.9
	viewPart.Parent = humanoidRootPart
	

	-- 시점 변경
    local viewPartPos = viewPart.Position
    
    camera.CameraType = Enum.CameraType.Follow
    local lastSubject = camera.CameraSubject
    camera.CameraSubject = viewPart
    
    -- jumpscare 애니메이션
    local jumpScare = ReplicatedStorage.JumpScare:Clone()
    jumpScare.Position = viewPart.Position + (viewPart.CFrame.LookVector * (viewPart.Size.Z * 2.5))
    jumpScare.Parent = workspace
    

	local connection = RunService.Heartbeat:Connect(function(deltaTime)
		local moveSpeed = 220
		jumpScare.Position = jumpScare.Position - player.Character.HumanoidRootPart.CFrame.LookVector * moveSpeed * deltaTime
	end)
	
	-- jumpscare 사운드
	local jumpScareSound = player.Character.HumanoidRootPart:FindFirstChild("JumpScareSound")
	if jumpScareSound then jumpScareSound:Destroy() end
	jumpScareSound = ReplicatedStorage.Sound.jumpscare:Clone()
	jumpScareSound.Name = "JumpScareSound"
	jumpScareSound.Parent = player.Character.HumanoidRootPart
	jumpScareSound:Play()

	
	wait(0.11)
	connection:Disconnect()

	-- 상태원복
	wait(2)
	jumpScare:Destroy()
	viewPart:Destroy()
	camera.CameraType = Enum.CameraType.Custom
    camera.CameraSubject = lastSubject
end
