-- ActionButton > LocalScript

-- 화면 크기 가져오기
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local screenWidth = screenSize.X
local screenHeight = screenSize.Y

-- 화면 크기 대비 크기 지정
local SIZE_RATIO = 0.2

local buttonSize = screenHeight * SIZE_RATIO
local iconSize = buttonSize * 0.7
local iconOffset = (buttonSize - iconSize) / 2


-- print("screen(" .. screenWidth .. " x " .. screenHeight .. "), button:" .. buttonSize .. ", icon:" .. iconSize)

local button = script.Parent
local icon = button.Icon

-- 대충 화면 가운데 밑에쯤 배치
local xOffset = (screenWidth - buttonSize) / 2
local yOffset = (screenHeight - buttonSize) * 0.9

button.Size = UDim2.new(0, buttonSize, 0, buttonSize)
button.Position = UDim2.new(0, xOffset, 0, yOffset)
icon.Size = UDim2.new(0, iconSize, 0, iconSize)
icon.Position = UDim2.new(0, iconOffset, 0, iconOffset)


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local MissionManager = require(ReplicatedStorage.MissionManager)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local Players = game:GetService("Players")


-- 액션 버튼 클릭시
button.Activated:Connect(function()
	-- print("clicked ActionButton")
	local actionType = button:GetAttribute(G.ACTION_TYPE)
	local player = Players.LocalPlayer
	-- C2SEvent:FireServer(G.C2S.LOG, "clicked ActionButton:" .. (actionType or ""))

	local actionUI = player.PlayerGui.ScreenGui.ActionUI
	
	-- 해당하는 ActionUI 보이기
	if actionType == G.Action.STARTING_MEMO then
		actionUI.StartingMemo.Visible = true
	elseif actionType == G.Action.MISSION_COLLECT then
		local index = button:GetAttribute(G.INDEX)
		MissionManager.clickedActionButton(index, G.MissionType.Collect)
	elseif actionType == G.Action.DOOR then
		C2SEvent:FireServer(G.C2S.DOOR)
	elseif actionType == G.Action.HIDDEN_DESK then
		playHiddenDeskSound()
	end
	
	button.Visible = false
end)

function playHiddenDeskSound()
	local sound = workspace.GameZone.HiddenDeskTouch.Sound
	if sound.Playing then
		sound:Stop()
	end
	sound:Play()
end
