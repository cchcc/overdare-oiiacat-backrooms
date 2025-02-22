-- ActionButton > LocalScript

-- 화면 크기 가져오기
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local screenWidth = screenSize.X
local screenHeight = screenSize.Y

-- 화면 크기 대비 크기 지정
local SIZE_RATIO = 0.17

local buttonSize = screenHeight * SIZE_RATIO
local iconSize = buttonSize * 0.7
local iconOffset = (buttonSize - iconSize) / 2


-- print("screen(" .. screenWidth .. " x " .. screenHeight .. "), button:" .. buttonSize .. ", icon:" .. iconSize)

local button = script.Parent
local icon = button.Icon

-- 대충 화면 가운데 밑에쯤 배치
local xOffset = -(buttonSize + 20)
local yOffset = (screenHeight - buttonSize) / 2

button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
button.Position = UDim2.new(1.0, xOffset, 0, yOffset)
icon.Size = UDim2.new(0, iconSize, 0, iconSize)
icon.Position = UDim2.new(0, iconOffset, 0, iconOffset)


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local MissionManager = require(ReplicatedStorage.MissionManager)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local animationTrack = nil
local touchConnection = nil
local touchPart = nil

-- 액션 버튼 클릭시
button.Activated:Connect(function()
	-- print("clicked ActionButton")
	
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character.Humanoid

	print("jump :" .. (humanoid.Jump and "t" or "f"))
	if humanoid.Jump then return end	
	
	local animator = humanoid.Animator
	local humanoidRootPart = character.HumanoidRootPart
	local tool = character:FindFirstChildOfClass("Tool")
	

	local lastWalkSpeed = humanoid.WalkSpeed
	if animationTrack == nil then
		local animation = Instance.new("Animation")
		-- a.AnimationId = "BasicAttackAnimation"
		animation.AnimationId = "BasicMeleeAttackAnimation"
		
		animationTrack = animator:LoadAnimation(animation)
		animationTrack.Ended:Connect(function()
			print("anim Ended")
			humanoid.WalkSpeed = lastWalkSpeed
			if touchPart then
				touchPart:Destroy()
				touchPart = nil
			end
		end)
	
		animationTrack.Stopped:Connect(function()
			print("anim Stopped")
			humanoid.WalkSpeed = lastWalkSpeed
			if touchPart then
				touchPart:Destroy()
				touchPart = nil
			end
		end)
		
	end
	
		
	lastWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	animationTrack:Play()

	-- 피격용 더미 파트
	local characterSize = humanoidRootPart.Size
	local lastTouchPart = humanoidRootPart:FindFirstChild("TouchPart")
	if lastTouchPart then
		lastTouchPart:Destroy()
	end
	
	touchPart = Instance.new("Part")
	touchPart.Name = "TouchPart"
	touchPart.Transparency = RunService:IsStudio() == true and 0.8 or 1.0
	touchPart.Anchored = true
	touchPart.CanCollide = false
	touchPart.CanTouch = true
	touchPart.Size = Vector3.new((characterSize.X+30), (characterSize.Y-50), 130)
	touchPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -(50+characterSize.Z))
	touchPart.Touched:Connect(function(touched)
		print("attack touched: " .. touched)
		local hitCount = touched:GetAttribute(G.HIT_COUNT)
		if hitCount then
			local newHitCount = hitCount - 1 			
			if newHitCount == 0 then
				touched:Destroy()  -- 이거 로벌 에서 생성해서 삭제시켜야 함
			else
				touched:SetAttribute(G.HIT_COUNT, newHitCount)
			end
		end
	end)
	CollectionService:AddTag(touchPart, G.Tag.HitRange)
	touchPart.Parent = humanoidRootPart
	
	-- 공격 사운드, 로컬
--	if tool then
--		local sounds = tool.Sound:GetChildren()
--		local attackSound = sounds[math.random(1, #sounds)]
		-- print(attackSound)
--		attackSound:Play()
--	end
	
	-- 공격 사운드, 서버
	C2SEvent:FireServer(G.C2S.ATTACK)
end)
