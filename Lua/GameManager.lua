-- GameManager

local GameManager = {
	partys = {},
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local AssistOffEvent = ReplicatedStorage:WaitForChild("AssistOffEvent")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PID = "pid"

-- Party 클래스 정의
Party = {
	State = {
		NONE = "NONE",
		READY = "READY",
		PLAYING = "PLAYING",
	}
}
Party.__index = Party

-- 생성자
function Party.new()
    local self = {}
    setmetatable(self, Party)
    self.id = "p:" .. os.clock()
    self.readyCount = G.READY_COUNT
    self.players = {}               
    self.state = Party.State.READY      
    -- self.color = Color3.new(math.random(0,255), math.random(0.255), math.random(255))
    self.missions = {}  -- 미션 상태
    for i = 1, G.MISSION_COUNT, 1 do
		self.missions[i] = {
			type = G.MissionType.Collect,
			completed = false,
		}
	end
	print("Party.new: " .. self.id)
    return self
end

function Party:addPlayer(player)
	 if self.players[player.Name] then
        print("addPlayer: " .. player.Name .. " already exists!")
    else
        self.players[player.Name] = player
        player:SetAttribute(PID, self.id)
    end
	
    return self:getPlayerSize()
end

function Party:removePlayer(player)
    if not self.players[player.Name] then
		print("removePlayer: " .. player.Name .. " already exists!")
	else
		player:SetAttribute(PID, nil)
	end
	self.players[player.Name] = nil
	
	return self:getPlayerSize()
end

function Party:getPlayerSize()
    return G.tableSize(self.players)
end

function Party:isFull()
	return self:getPlayerSize() == G.MAX_PARTY_SIZE
end

function Party:isEmpty()
	return self:getPlayerSize () <= 0
end

function Party:isCompleteAllMission()
	for _, m in ipairs(self.missions) do
		if m.completed == false then
			return false
		end
	end
	return true
end

function Party:nextMissionIndex()
	for idx, m in ipairs(self.missions) do
		if m.completed == false then
			return idx
		end
	end
	return -1
end

-- 보드에 표시할 텍스트
function Party:boardText()
	local playState = ""
	if self.state == Party.State.PLAYING then
		local completed = 0
		for idx, m in pairs(self.missions) do
			if m.completed == true then
				completed = completed + 1
			end
		end
		
		if completed == G.MISSION_COUNT then
			playState = " Escape!"
		else
			playState = " " .. completed .. "/" .. G.MISSION_COUNT .. " Completed"
		end
	elseif self.state == Party.State.READY then
		playState = " " .. self:getPlayerSize() .. "/" .. G.MAX_PARTY_SIZE .. " Ready!"
	else
		playState = ""
	end
	
	
	local userNames = ""
	for name, player in pairs(self.players) do
		userNames = userNames .. "\n  - " .. name
	end
	
	local text = playState .. userNames
	return text
end

-- GameManager
-- 파티 조회 메서드
function GameManager.getParty(partyId)
    return GameManager.partys[partyId] or nil
end

function GameManager.getPartyFromPlayer(player)
	local pid = player:GetAttribute(PID)
	return GameManager.getParty(pid)
end

function GameManager.initPlayer(player)
	local chracter = player.Character
	local humanoid = chracter.Humanoid
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
	S2CEvent:FireClient(player, G.S2C.INIT)
end

function GameManager.readyIn(player)
	print("GameManager.readyIn: " .. player.Name)
	local party = nil
	
	GameManager.clearPlayer(player)  -- 레디존 중복 진입 방어코드
	
	-- 가능한 파티 찾기 OR 만들기
	for pid, p in pairs(GameManager.partys) do
		if p.state == Party.State.READY and p:isFull() == false then
			party = p
			break
		end
	end

    -- 가능한 파티 없으면 새 파티 만듬
	local isNewParty = false
	if not party then
		party = Party.new()
		GameManager.addParty(party)
		isNewParty = true
	else
		party.readyCount = G.READY_COUNT  -- 새 파티원 조인시 레디 카운트 리셋
	end
	
	-- 파티에 플레이어 추가
	party:addPlayer(player)
	
	
	-- 파티내 새로운 플레이어 추가됨 전달
	local boardText = party:boardText()
	-- print(boardText)
	GameManager.sendS2CParty(party, G.S2C.BOARD, boardText)
	
	
	-- 파티에 레디 카운트 시작
	if isNewParty then
		readyCount(party)
	end
	
end


function GameManager.readyOut(player)
	local partyId = player:GetAttribute(PID)
	if not partyId then  -- 파티이 없으면 수행 안함
		print("GameManager.readyOut: not exist partyId")
		return
	end
	
	local party = GameManager.getParty(partyId)	
	if not party then
		print("GameManager.readyOut: not exist party")
		return
	end	
	
	if party.state == Party.State.PLAYING then
		return
	end
	
	-- 파티에서 플레이어 제거
	party:removePlayer(player)
	
	
	if party:isEmpty() then  -- 빈 파티이면 제거
		GameManager.removeParty(party.id)
	else
		local boardText = party:boardText()
		GameManager.sendS2CParty(party, G.S2C.BOARD, boardText)
	end
	
	S2CEvent:FireClient(player, G.S2C.BOARD, "")  -- 보드 사라지도록
	S2CEvent:FireClient(player, G.S2C.READY_COUNT)  -- 레디 카운트 사라지도록
end

function GameManager.sendS2CParty(party, s2c, data)
	for i, p in pairs(party.players) do
        print("sendS2CParty " .. party.id .. ", " .. s2c .. ", " .. p.Name)
    	S2CEvent:FireClient(p, s2c, data)
	end
end

function GameManager.sendS2CPartyId(partyId, s2c, data)
	local party = GameManager.getParty(partyid)
	if party then
		GameManager.sendS2CParty(party, s2c, data)
	end
end

-- 파티 추가
function GameManager.addParty(party)
	print("GameManager.addParty: " .. party.id)
	
    if GameManager.partys[party.id] then
        print("addParty: Party with ID " .. party.id .. " already exists!")
    else
        GameManager.partys[party.id] = party
    end
end

-- 파티 제거
function GameManager.removeParty(id)
	print("GameManager.removeParty: " .. id)
	
    if GameManager.partys[id] then
        GameManager.partys[id].state = Party.State.NONE
    else
		print("removeParty: Party with ID " .. id .. " not found.")
    end
    
	GameManager.partys[id] = nil
end

-- 세션내 플레이어 정보를 비운다. 게임 리셋, 세션 퇴장등의 상황
-- 플레이어가 소속된 파티파티가 있다면 퇴출
function GameManager.clearPlayer(player)
	local character = player.Character
	
	local tool = character:FindFirstChildOfClass("Tool")
	if tool then
		tool:Destroy()
	end
	
	local pid = player:GetAttribute(PID)
	if not pid then
		return
	end
	
	local party = GameManager.getParty(pid)
	if not party then
		return
	end
	
	party:removePlayer(player)
	
	
	if party:isEmpty() then  -- 빈 파티이면 제거
		GameManager.removeParty(party.id)
	else
		local boardText = party:boardText()
		GameManager.sendS2CParty(party, G.S2C.BOARD, boardText)
	end
	
end

-- 엔드존에서 대기후 게임 재시작
function GameManager.restart(player)
	print("GameManager.restart: ".. player.Name)
	GameManager.clearPlayer(player)
	
	local character = G.findCharacter(player.Name)
	local humanoid = character.Humanoid
	local humanoidRootPart = character.HumanoidRootPart
	
	local restartPos = G.getRandomPositionInPart(workspace.Spawn)
	humanoidRootPart.CFrame = CFrame.new(restartPos) + Vector3.new(0, 10, 0)
	humanoid.Health = humanoid.MaxHealth
	
	S2CEvent:FireClient(player, G.S2C.BOARD)
	S2CEvent:FireClient(player, G.S2C.RESTART)
end

function GameManager.died(player)
	print("GameManager.died: ".. player.Name)
	GameManager.clearPlayer(player)
end

function GameManager.completeMission(player, index)
	local party = GameManager.getPartyFromPlayer(player)
	party.missions[index].completed = true
	
	
	-- 보드 갱신
	local boardText = party:boardText()
	GameManager.sendS2CParty(party, G.S2C.BOARD, boardText)
	
	-- 전체 미션 끝낫는지 확인
	if party:isCompleteAllMission() then
		GameManager.sendS2CParty(party, G.S2C.SPAWN_TOOL)
		GameManager.sendS2CParty(party, G.S2C.COMPLETE_ALL_MISSION)
	end
end

function GameManager.equip(player, data)
	print("GameManager.equip: " .. player.Name)
	
	local character = player.Character
	local humanoid = character.Humanoid
	
	local tool = ReplicatedStorage.Tool.Stick:Clone()
	tool.Handle.Part.Color = data.Color
	humanoid:EquipTool(tool)
end

function GameManager.attack(player)
	print("GameManager.attack: " .. player.Name)
	local character = player.Character
	local humanoidRootPart = character.HumanoidRootPart
	
	local attackSound = humanoidRootPart:FindFirstChild("AttackSound")
	if attackSound then
		attackSound:Destroy()
	end
	
	local attackSounds = ReplicatedStorage.Sound.oia:GetChildren()
	local attackSound = attackSounds[math.random(1, #attackSounds)]:Clone()
	attackSound.Name = "AttackSound"
	--attackSound.RollOffMaxDistance = 1000
	--attackSound.RollOffMinDistance = 200
	--attackSound.Ended:Connect(function()  -- 버그 있는 코드
		-- print("sound.Ended")
		--attackSound:Destroy()
	--end)
	attackSound.Parent = humanoidRootPart
	attackSound:Play()
end

function GameManager.jumpscare(player)
	local camera = game.Workspace.CurrentCamera
	local humanoidRootPart = player.Character.HumanoidRootPart
	local character = player.Character
	local humanoid = character.Humanoid
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
    jumpScare.CFrame = CFrame.new(jumpScare.Position, jumpScare.Position + humanoidRootPart.CFrame.LookVector)
    jumpScare.Parent = workspace
    

	local connection = RunService.Heartbeat:Connect(function(deltaTime)
		local moveSpeed = 220
		jumpScare.Position = jumpScare.Position - player.Character.HumanoidRootPart.CFrame.LookVector * moveSpeed * deltaTime
	end)
	
	
	local lastWalkSpeed = humanoid.WalkSpeed
	humanoid.WalkSpeed = 0

		
	
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
    humanoid.WalkSpeed = lastWalkSpeed
end

function GameManager.door(player, data)
	print("GameManager.door: " .. player.Name)
	
	local openAngle = 90
	local moveSpeed = 90

	local pivot = load(data.PivotScript)()
	
	local closed = pivot:GetAttribute(G.CLOSED)
	local aymin = pivot:GetAttribute("aymin")
	if aymin == nil then pivot:SetAttribute("aymin", pivot.CFrame.Orientation.Y) end
	local aymax = pivot:GetAttribute("aymax")
	if aymax == nil then pivot:SetAttribute("aymax", pivot.CFrame.Orientation.Y + openAngle) end
		
	--print(pivot)
	
	if closed then
		pivot:SetAttribute(G.CLOSED, false)
	else
		pivot:SetAttribute(G.CLOSED, true)
	end
	
end

-- 해당 플레이어의 다음 타겟 파트를 보내줌
function GameManager.assistTarget(player)
	local party = GameManager.getPartyFromPlayer(player)
	
	-- 대기 상태
	if not party or party.state == Party.State.READY then
		S2CEvent:FireClient(player, G.S2C.ASSIST_TARGET, "return workspace.ReadyZone.ReadyZone.Touch")
		return
	end
		
	-- 미션 진행중
	local nextMissionIndex = party:nextMissionIndex()
	if nextMissionIndex ~= -1 then
		S2CEvent:FireClient(player, G.S2C.ASSIST_TARGET, "return workspace.GameZone.Mission.Mission_Collect" .. nextMissionIndex)
		return
	end

	-- 미션 완료
	S2CEvent:FireClient(player, G.S2C.ASSIST_TARGET, "return workspace.GameZone.EndZone.Touch")
	
end

-- 플레이어 접속 끊긴경우
Players.PlayerRemoving:Connect(function(player)  -- 모바일에서 되는거 확인함
	print("PlayerRemoving: " .. player.Name)
	GameManager.clearPlayer(player)
--	S2CEvent:FireAllClients(G.S2C.BOARD, "Remove: " .. player.Name)
end)


-- 레디 카운트
function readyCount(party)
	print("readyCount: " .. party.id)
	while party.state == Party.State.READY do
		GameManager.sendS2CParty(party, G.S2C.READY_COUNT, party.readyCount)
		party.readyCount = party.readyCount - 1
		if party.readyCount < 0 then
			GameManager.sendS2CParty(party, G.S2C.READY_COUNT)
			startGame(party)
			break
		end
		
		wait(1)
	end
	
end



-- 게임 시작
function startGame(party)
	print("startGame: " .. party.id)
	party.state = Party.State.PLAYING
	
	
	-- 파티내 플레이어들을 스타트 존으로 이동 시킴
	local startZone = workspace.GameZone.StartZone  -- 스타트존 파트 경로 맞는지 주의
	for name, p in pairs(party.players) do
		local character = G.findCharacter(name)
		if character then
			local randomPosition = G.getRandomPositionInPart(startZone)
			character.HumanoidRootPart.CFrame = CFrame.new(randomPosition) 
		end
	end
	
	-- 보드 갱신
	local boardText = party:boardText()
	GameManager.sendS2CParty(party, G.S2C.BOARD, boardText)
	
		
	-- 게임 시작
	local gameData = {
		missions = party.missions
	}
	GameManager.sendS2CParty(party, G.S2C.START_GAME, gameData)
end

return GameManager
