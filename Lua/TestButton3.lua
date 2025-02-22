local button = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
button.Visible = RunService:IsStudio()



-- 버튼 클릭시
button.Activated:Connect(function()
	
	local player = Players.LocalPlayer
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local animator = humanoid.Animator
	
	-- humanoid:TakeDamage(100)
	--humanoid.WalkSpeed = 0
	--if true then return end	
		
	--equipOrAttack(Players.LocalPlayer)
	C2SEvent:FireServer(G.C2S.EQUIP_OR_ATTACK)
	--jumpscare2()
end)


local animationTrack = nil
local touchConnection = nil
local touchPart = nil

local function touchedAttack(touched)
	print("touchedAttack: " .. touched)
end

local function touchEndedAttack(touched)
	print("touchEndedAttack: " .. touched)
end

function equipOrAttack(player)	
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local animator = humanoid.Animator

	-- equip
	local tool = character:FindFirstChildOfClass("Tool")
	if tool == nil then
		local tool = ReplicatedStorage.Tool.Stick:Clone()
		tool.Handle.Part.Color = Color3.new(math.random(0,255), math.random(0,255), math.random(0,255))
		humanoid:EquipTool(tool)
		print("equip tool: " .. player.Name)
		
		tool.Handle.Part.Touched:Connect(function(p) print("Touched: " .. p) end)
		tool.Handle.Part.TouchEnded:Connect(function(p) print("TouchEnded: " .. p) end)
		
		return
	end
	
	
	
	-- attack
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
			wait(0.1)
			if touchPart then
				touchPart:Destroy()
				touchPart = nil
			end
		end)
		animationTrack.Looped = false
	end
	
	lastWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	animationTrack:Play()
	
	local characterSize = humanoidRootPart.Size
	
	--touchPart = tool.Handle.Part:Clone()
	touchPart = Instance.new("Part")
	touchPart.Name = "TouchPart"
	touchPart.Transparency = RunService:IsStudio() == true and 0.8 or 1.0
	touchPart.Anchored = true
	touchPart.CanCollide = false
	touchPart.CanTouch = true
	touchPart.Size = Vector3.new((characterSize.X+30), (characterSize.Y-50), 130)
	touchPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -(50+characterSize.X))
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
	touchPart.Parent = humanoidRootPart
	--touchPart.Parent = tool.Handle
	--print("attack: " .. player.Name)
	
end

