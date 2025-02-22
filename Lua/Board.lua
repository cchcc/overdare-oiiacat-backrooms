-- Board > LocalScript

-- 화면 크기 가져오기
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local screenWidth = screenSize.X
local screenHeight = screenSize.Y

-- board 화면 크기 대비 크기 지정
local W_RATIO = 0.18
local H_RATIO = 0.13
local Y_OFFSET_RATIO = 0.02


local boardWidth = screenWidth * W_RATIO
local boardHeight = screenHeight * H_RATIO
local xOffset = -boardWidth
local yOffset = screenHeight * Y_OFFSET_RATIO

--print("screen(" .. screenWidth .. " x " .. screenHeight .. "), board(" .. boardWidth .. " x " .. boardHeight .. ")")

local board = script.Parent
board.Size = UDim2.new(0, boardWidth, 0, boardHeight)
board.Position = UDim2.new(1.0, xOffset, 0, yOffset)


--board.Text = "  10/10 Collected\n - user1\n - user2user2" --\nasdfja;sdf\nasdfjaisdjf\nasdfasfd"
--board.Text = "Ready?"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local G = require(ReplicatedStorage.G)
local C2SEvent = ReplicatedStorage:WaitForChild("C2SEvent")
local S2CEvent = ReplicatedStorage:WaitForChild("S2CEvent")


S2CEvent.OnClientEvent:Connect(function(msg, data)
	-- print("S2C: " .. msg .. ", " .. (data or ""))
	
	if msg == G.S2C.BOARD then
		--print("G.S2C.BOARD: " .. data)
		board.Text = data
		board.Visible = data and string.len(data) > 0
	end
	
end)
