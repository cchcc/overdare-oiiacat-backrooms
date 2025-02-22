-- ActionUI > StartingMemo > StartingMemo

-- 화면 크기 가져오기
local camera = workspace.CurrentCamera
local screenSize = camera.ViewportSize
local screenWidth = screenSize.X
local screenHeight = screenSize.Y

local SIZE_RATIO = 0.8

local size = screenHeight * SIZE_RATIO

local memo = script.Parent
memo.Size = UDim2.new(0, size, 0, size)

local okButton = memo.OkButton
okButton.Activated:Connect(function()
	memo.Visible = false
end)

