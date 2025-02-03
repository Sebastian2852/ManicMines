local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local NeoHotbar = require(ReplicatedStorage.Packages.NeoHotbar)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Signals = require(ReplicatedStorage.Game.GUI.Signals)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

local HUDController = Knit.CreateController({ Name = "HUDController" })

local SpringTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)

local DEFAULT_POSITION = UDim2.new(0.5, 0, 1, -8)
local HIDDEN_POSITION = UDim2.new(0.5, 0, 1.2, 8)

-- [[ PUBLIC ]] --

--[=[
Only intented for internal use
]=]
function HUDController:_AnimateHotbar(Goal: UDim2)
	local Tween = TweenService:Create(self.MainFrame, SpringTweenInfo, { Position = Goal })
	Tween:Play()
	return Tween
end

--[=[
Makes the hotbar invisible
]=]
function HUDController:DisableHotbar(Animated: boolean?)
	if not self.GUI then
		return
	end
	if Animated == nil then
		Animated = true
	end

	if Animated then
		self:_AnimateHotbar(HIDDEN_POSITION)
	else
		self.MainFrame.Position = HIDDEN_POSITION
	end
end

--[=[
Makes the hotbar visible
]=]
function HUDController:EnableHotbar(Animated: boolean?)
	if not self.GUI then
		return
	end
	if Animated == nil then
		Animated = true
	end

	if Animated then
		self:_AnimateHotbar(DEFAULT_POSITION)
	else
		self.MainFrame.Position = DEFAULT_POSITION
	end
end

function HUDController:AddTopBarLabel(Text: string)
	TopbarPlus.new():setLabel(Text):disableOverlay(true):lock()
end

-- [[ KNIT ]] --

function HUDController:KnitStart()
	local LogService = Knit.GetService("LogService")
	local DataService = Knit.GetService("DataService")

	self:AddTopBarLabel("v 1.0.0")

	local HUD = require(ReplicatedStorage.Game.GUI.HUD)

	DataService.DataLoaded:Connect(function()
		local App = Roact.createElement(HUD)
		Roact.mount(App, Knit.Player.PlayerGui, "HUD")
		LogService:Log("Mounted HUD component")

		NeoHotbar:Start()
		self.GUI = Knit.Player.PlayerGui:FindFirstChild("NeoHotbar") :: ScreenGui
		self.MainFrame = self.GUI:FindFirstChildWhichIsA("Frame")

		Signals.ToggleHotbar:Connect(function(New: boolean)
			if New then
				self:EnableHotbar(true)
			else
				self:DisableHotbar(true)
			end
		end)
	end)
end

return HUDController
