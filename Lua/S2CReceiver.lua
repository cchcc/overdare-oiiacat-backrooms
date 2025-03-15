print(_VERSION)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local MissionManager = require(ReplicatedStorage.MissionManager)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local AssistOffEvent = ReplicatedStorage:WaitForChild("AssistOffEvent")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local gameZoneFolder = workspace:WaitForChild("GameZone")
local StarterGui = game:GetService("StarterGui")

S2CEvent.OnClientEvent:Connect(function(msg, data)
	if msg == G.S2C.INIT then
		init()
	elseif msg == G.S2C.START_GAME then
		onStartGame(data)
		AssistOffEvent:Fire()
	elseif msg == G.S2C.SPAWN_TOOL then
		spawnDroppedTool()
	elseif msg == G.S2C.COMPLETE_ALL_MISSION then
		flickDoor()
	elseif msg == G.S2C.RESTART then
		AssistOffEvent:Fire()
	else
	end	
end)


local function onDied(player)
	C2SEvent:FireServer(G.C2S.DIED)
	
	local character = player.Character
	local equippedTool = character:FindFirstChildOfClass("Tool")
	if equippedTool then  -- 혹시 기존 장착 tool 있으면 제거
		equippedTool:Destroy()
		player.PlayerGui.ScreenGui.AttackButton.Visible = false
	end
end


function init()
	--if true then return end	
	
	-- 모바일에서 CharacterAdded 안되는 버그 대체
	local player = Players.LocalPlayer
	repeat wait() until player.Character
	print("INIT: " .. player.Name)
	
	local character = player.Character
	local humanoid = character:WaitForChild("Humanoid")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	
	humanoid.Died:Connect(onDied)
		
	-- ui 설정
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
		
end

function onStartGame(data)
	local player = Players.LocalPlayer
	local playerGui = player.PlayerGui
	
	local doorWall = ReplicatedStorage.DoorWall:Clone()
	doorWall.Position = G.LAST_DOOR_POSITION
	doorWall:SetAttribute(G.HIT_COUNT, G.LAST_DOOR_HIT_COUNT)
	doorWall.Parent = gameZoneFolder
	
	-- 피격시 연출 스크립트 추가
	local changeColorWhenHit = ReplicatedStorage.Script.ChangeColorWhenHit:Clone()
	changeColorWhenHit:SetAttribute(G.SCRIPT, "return workspace.GameZone.DoorWall")
	changeColorWhenHit.Parent = player.PlayerScripts
	
	MissionManager.init(data.missions)
	
	playerGui.ScreenGui.Clear.Visible = false
	
end

function spawnDroppedTool()
	local dropped = ReplicatedStorage.Tool.DroppedTool:Clone()
	dropped.Position = G.SPAWN_TOOL_POSITION
	
	local randomColor = Color3.new(math.random(0,255), math.random(0,255), math.random(0,255))
	dropped.Handle.Part.Color = randomColor
	
	
	dropped.Touched:Connect(function(touched)
		local player = G.getPlayerFromTouched(touched)
		if player and player.Name == Players.LocalPlayer.Name then
			C2SEvent:FireServer(G.C2S.EQUIP, { Color = randomColor	})  -- 서버에서 장착하는건 버그가 있음
			player.PlayerGui.ScreenGui.AttackButton.Visible = true
			
			dropped.Parent = nil
			dropped:Destroy()
			
			if true then return end
			
			local character = player.Character
			local humanoid = character.Humanoid	
			
			local equippedTool = character:FindFirstChildOfClass("Tool")
			if equippedTool then  -- 혹시 기존 장착 tool 있으면 제거
				equippedTool:Destroy()
			end
			
			local newTool = ReplicatedStorage.Tool.Stick:Clone()
			newTool.Handle.Part.Color = randomColor
			--newTool.Handle.Part.Touched:Connect(function(touched)
			--	print("newTool Touched:" .. touched)
			--end)
			humanoid:EquipTool(newTool)
			
			player.PlayerGui.ScreenGui.AttackButton.Visible = true
			
			dropped.Parent = nil
			dropped:Destroy()
		end
	end)
	
	dropped.Parent = gameZoneFolder

	-- 회전
	while dropped and dropped.Parent do
		dropped.CFrame = dropped.CFrame * CFrame.Angles(0, math.rad(20), 0)  
		wait(0.2)
	end	
end

function flickDoor()
	local door = workspace.GameZone.DoorWall
	
	local originColor = door.Color
	while door and door.Parent do
		wait(1)
		door.Color = Color3.new(255,255,255)
		wait(0.15)
		door.Color = originColor
		wait(0.15)
		door.Color = Color3.new(255,255,255)
		wait(0.15)
		door.Color = originColor
		wait(3)
	end
end


wait(0.01)
C2SEvent:FireServer(G.C2S.INIT)