-- Roblox
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Packages
local Knit = require(ReplicatedStorage.Packages.Knit)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)
require(ReplicatedStorage.Packages.Iris).Init()

-- [[ KNIT ]] --

local KnitStartTimer = Profiler.Timer.new()

Knit.AddControllersDeep(script.Parent.Controllers)
Knit.Start()
	:andThen(function()
		local StartTime = KnitStartTimer:GetTime()
		KnitStartTimer:Destroy()
		print(`Client loaded: {StartTime}ms elapsed`)
	end)
	:catch(warn)

-- [[ COMPONENTS ]] --

for _, Object in pairs(script.Parent.Components:GetDescendants()) do
	if not Object:IsA("ModuleScript") then
		continue
	end
	require(Object)
end

-- [[ CMDR ]] --

local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
Cmdr:SetPlaceName("ManicMines")
Cmdr:SetActivationUnlocksMouse(true)

-- [[ DEBUG ]] --

if _G.DEBUG then
	local Roact = require(ReplicatedStorage.Packages.Roact)

	local HoverInfo = require(ReplicatedStorage.Game.GUI.Common.HoverInfo)

	local App = Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		DisplayOrder = 100000,
	}, {
		Text = Roact.createElement("TextLabel", {
			Size = UDim2.fromScale(0.3, 0.1),
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,

			Text = "DEBUG VERSION",
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTransparency = 0.5,
			TextScaled = true,
			TextColor3 = Color3.new(1, 1, 1),
			FontFace = Font.fromEnum(Enum.Font.FredokaOne),
		}, {
			App = Roact.createElement(HoverInfo, {
				Text = "Scripts are in 'debug mode' meaning that they could be less efficient and produce logs. Profiling is enabled.",
			}, {}),
		}),
	})

	Roact.mount(App, Knit.Player.PlayerGui, "DebugMode")
end
