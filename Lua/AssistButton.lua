local button = script.Parent

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local GameManager = require(ReplicatedStorage.GameManager)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")
local AssistOffEvent = ReplicatedStorage:WaitForChild("AssistOffEvent")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local text = button.Text

local isOn = false

-- 버튼 클릭시
button.Activated:Connect(function()
	if isOn then
		text.TextColor3  = Color3.new(200,200,200)
		destroyAssistArrow()
	else
		text.TextColor3  = Color3.new(200,110,0)
		createAssistArrow()
	end

	isOn = not isOn
end)

AssistOffEvent.Event:Connect(function()
	text.TextColor3  = Color3.new(200,200,200)
	destroyAssistArrow()
	isOn = false
end)


function createAssistArrow()
	local player = Players.LocalPlayer
	local humanoidRootPart = player.Character.HumanoidRootPart
	local character = player.Character
	local humanoid = character.Humanoid
	local characterSize = humanoidRootPart.Size
	local characterPos = humanoidRootPart.Position
	
	local assistArrow = ReplicatedStorage.AssistArrow:Clone()
	assistArrow.PrimaryPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, characterSize.y / 2 + 6, 0)
	assistArrow.Parent = humanoidRootPart
	
	-- 방향은 서버에서 수신후 지정
	C2SEvent:FireServer(G.C2S.ASSIST_TARGET)
		
end


function destroyAssistArrow()
	local player = Players.LocalPlayer
	local humanoidRootPart = player.Character.HumanoidRootPart
	local assistArrow = humanoidRootPart:FindFirstChild("AssistArrow")
	if assistArrow then
		assistArrow:Destroy()
	end
	
	local assistArrowScript = player.PlayerScripts:FindFirstChild("AssistArrow")
	if assistArrowScript then
		assistArrowScript:Destroy()
	end
end


S2CEvent.OnClientEvent:Connect(function(msg, data)
	if msg == G.S2C.ASSIST_TARGET and isOn then
	    local player = Players.LocalPlayer
	    print("C2S: " .. msg .. " ," .. player.Name .. ", " .. (data or ""))
	    local assistArraowScript = ReplicatedStorage.Script.AssistArrow:Clone()
		assistArraowScript:SetAttribute("TargetPosition", data)
	    assistArraowScript.Parent = player.PlayerScripts
	end	
end)
