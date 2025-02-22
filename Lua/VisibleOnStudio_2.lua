local part = script.Parent
local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	part.Transparency = 1
end
