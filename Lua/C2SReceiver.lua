-- C2SReceiver

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local GameManager = require(ReplicatedStorage.GameManager)

C2SEvent.OnServerEvent:Connect(function (player, msg, data)
	-- print("C2S: " .. msg .. " ," .. player.Name .. ", " .. (data or ""))
	
	if msg == G.C2S.READY_ZONE_IN then
		GameManager.readyIn(player)
	elseif msg == G.C2S.READY_ZONE_OUT then
		GameManager.readyOut(player)
	elseif msg == G.C2S.LOG then
		S2CEvent:FireClient(player, G.S2C.BOARD, data)
	elseif msg == G.C2S.INIT then
		GameManager.initPlayer(player)
	elseif msg == G.C2S.RESTART then
		GameManager.restart(player)
	elseif msg == G.C2S.DIED then
		GameManager.died(player)
	elseif msg == G.C2S.COMPLETE_MISSION then
		GameManager.completeMission(player, data)
	elseif msg == G.C2S.EQUIP then
		GameManager.equip(player, data)
	elseif msg == G.C2S.ATTACK then
		GameManager.attack(player)
	elseif msg == G.C2S.EQUIP_OR_ATTACK then
		equipOrAttack(player)
	elseif msg == G.C2S.DOOR then
		GameManager.door(player, data)
	elseif msg == G.C2S.ASSIST_TARGET then
		GameManager.assistTarget(player)
	else
	end	
	
end)


local animationTrack = nil

function equipOrAttack(player)
	print("equipOrAttack :" .. player)
	local character = player.Character
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	local animator = humanoid.Animator


	-- equip
	if character:FindFirstChildOfClass("Tool") == nil then
		local tool = ReplicatedStorage.Tool.Stick:Clone()
		tool.Handle.Part.Color = Color3.new(math.random(0,255), math.random(0,255), math.random(0,255))
		--humanoid:EquipTool(tool)
		--print("equip tool: " .. player.Name)
		
		tool.Parent = player.Backpack
		wait(0.01)
				
		humanoid:EquipTool(tool)
		wait(0.01)
				
		tool.Parent = player.Backpack
		wait(0.01)
				
		humanoid:EquipTool(tool)
		wait(0.01)
		return
	end
	
	
	-- attack
	local attackAnimationTrack = player.Character:FindFirstChild("AttackAnimationTrack")	
	if attackAnimationTrack then attackAnimationTrack:Destroy() end
	
	local lastWalkSpeed = humanoid.WalkSpeed
	--if animationTrack == nil then
		local animation = Instance.new("Animation")
		-- a.AnimationId = "BasicAttackAnimation"
		animation.AnimationId = "BasicMeleeAttackAnimation"
		
		attackAnimationTrack = animator:LoadAnimation(animation)
--		animationTrack.Ended:Connect(function()
--			print("anim Ended")
--			humanoid.WalkSpeed = lastWalkSpeed
--		end)
	
--		animationTrack.Stopped:Connect(function()
--			print("anim Stopped")
--			humanoid.WalkSpeed = lastWalkSpeed
--		end)
		attackAnimationTrack.Looped = false
		attackAnimationTrack.Parent = player.Character
	--end
	
	lastWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0
	attackAnimationTrack:Play()
	
	
	local attackSound = humanoidRootPart:FindFirstChild("AttackSound")
	if attackSound then
		attackSound:Destroy()
	end
	
	local attackSounds = ReplicatedStorage.Sound.oia:GetChildren()
	local attackSound = attackSounds[math.random(1, #attackSounds)]:Clone()
	attackSound.Name = "AttackSound"
	attackSound.RollOffMaxDistance = 1000
	attackSound.RollOffMinDistance = 200
	attackSound.Parent = humanoidRootPart
	attackSound:Play()
	
	wait(0.9)
	humanoid.WalkSpeed = lastWalkSpeed
	print("attack: " .. player.Name)
end

