-- G

local G = {
	
	-- 설정값
	MAX_PARTY_SIZE = 2,			-- 최대 파티 가능 숫자  2
	READY_COUNT = 5,			-- 레디 카운트 숫자  10
	MISSION_COUNT = 4,			-- 탈출을 위한 미션 성공 수  4
	MAX_RESTART_COUNT = 5,		-- 탈출 성공후 엔드존에서 재시작 카운트  5
	SPAWN_TOOL_POSITION = Vector3.new(-270.0, 64.896477, -5010.0),  -- 미션 완료시 무기 스폰 위치
	LAST_DOOR_POSITION = Vector3.new(-310.657837, 252.537537, -5445.92041),   -- 마지막 문 위치
	LAST_DOOR_HIT_COUNT = 3,	-- 마지막 단계 문 몇번 쳐야 부서지는지 3
	
	WALK_SPEED = 800,  -- settings 에 설정해둔거. 동일하게 맞춰야함

	-- 여기부터는 상수값	
	
	-- client -> server
	C2S = {
		LOG = "LOG",		-- 디버깅용 서버 통해 보드에 텍스트 표시
		INIT = "INIT",  	-- 로컬 스크립트 캐릭 생성시 INIT 전송
		READY_ZONE_IN = "READY_ZONE_IN",
		READY_ZONE_OUT = "READY_ZONE_OUT",
		RESTART = "RESTART",
		DIED = "DIED",
		COMPLETE_MISSION = "COMPLETE_MISSION",  -- data: 해당 미션 index
		EQUIP_OR_ATTACK = "EQUIP_OR_ATTACK",  -- 장착 이후 공격
		EQUIP = "EQUIP",
		ATTACK = "ATTACK", 
		DOOR = "DOOR",
		ASSIST_TARGET = "ASSIST_TARGET",
	},
	
	-- server -> client
	S2C = {
		INIT = "INIT",  -- INIT 에코
		READY_COUNT = "READY_COUNT",  	-- data 숫자 0 을 전달하면 사라짐
		BOARD = "BOARD",  				-- data 빈 문자를 전달하면 board 사라짐
		START_GAME = "START_GAME",		-- data: missions
		COMPLETE_ALL_MISSION = "COMPLETE_ALL_MISSION",
		SPAWN_TOOL = "SPAWN_TOOL",
		RESTART = "RESTART",
		ASSIST_TARGET = "ASSIST_TARGET",
	},
	
	MissionType = {
		Collect = "Collect"
	},
	
	INDEX = "INDEX",
	ACTION_TYPE = "ACTION_TYPE",
	
	Action = {
		STARTING_MEMO = "STARTING_MEMO",
		MISSION_COLLECT = "MISSION_COLLECT",
		DOOR = "DOOR",
		HIDDEN_DESK = "HIDDEN_DESK",
	},
	
	TARGET = "TARGET",
	CLOSED = "CLOSED",
	HIT_COUNT = "HIT_COUNT",
	
	Tag = {
		HitRange = "HitRange"
	}
}



-- util

local Players = game:GetService("Players")

function G.getPlayerFromTouched(touched)
	local humanoid = touched.Parent:FindFirstChild("Humanoid")
	if humanoid then
		local player = Players:GetPlayerFromCharacter(touched.Parent)
		return player
	end
	return nil
end


function G.findCharacter(playerName)
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Name == playerName then
			return player.character
		end
	end
	
	return nil
end

-- 파트 내 랜덤 좌표 생성 함수. 완전 딱 맞지는 않아서 파트 주변에 좀 여유를 두고 배치하기 
function G.getRandomPositionInPart(part)
    local size = part.Size
    local position = part.Position

    -- 파트 크기를 기준으로 랜덤 좌표 계산
    local sx = math.ceil(position.X - size.X / 2)
    local ex = math.ceil(position.X + size.X / 2)
    local randomX = math.random(sx, ex)
    local randomY = position.Y + 1-- math.random(position.Y - size.Y / 2, position.Y + size.Y / 2)
    local sz = math.ceil(position.Z - size.Z / 2)
    local ez = math.ceil(position.Z + size.Z / 2)
    local randomZ = math.random(sz, ez)

    return Vector3.new(randomX, randomY, randomZ)
end

-- 액션 UI 띄우고 있는게 있는지
function G.visibleActionUi()
	local uiList = Players.LocalPlayer.PlayerGui.ScreenGui.ActionUI:GetChildren()
	for _, ui in ipairs(uiList) do
		if ui and ui.Visible then
			return true
		end
	end
	return false
end

function G.tableSize(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end

function G.getRandomSelection(array, count)
    local selection = {}
    local indices = {}

    while #selection < count do
        local index = math.random(1, #array)
        if not indices[index] then
            table.insert(selection, array[index])
            indices[index] = true
        end
    end

    return selection
end

function G.findChildByName(o, name)
	local children = o:GetChildren()
	for _, v in ipairs(children) do
		if tostring(v.Name) == name then
			return v 
		end
	end
	return nil
end

return G