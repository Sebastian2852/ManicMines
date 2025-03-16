local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local MainMenuController = Knit.CreateController({ Name = "MainMenuController" })

local Camera = workspace.CurrentCamera

local DataService
local LogService
local TextFilteringService

local Blur
local MainMenuTree

-- [[ PUBLIC ]] --

function MainMenuController:PickRandomName(): string
	local Name = Core.GameConfig.Tycoon.RandomName.Prefix

	local Adjectives = Core.GameConfig.Tycoon.RandomName.Adjectives
	local Nouns = Core.GameConfig.Tycoon.RandomName.Nouns

	local RandomAdjective = Adjectives[math.random(1, #Adjectives)]
	local RandomNoun = Nouns[math.random(1, #Nouns)]

	Name = Name .. " " .. RandomAdjective .. " " .. RandomNoun
	return Name
end

function MainMenuController:FilterName(Name: string): string
	local Result = nil

	TextFilteringService:FilterTextFromUserToEveryone(Name):andThen(function(FilterResult)
		Result = FilterResult
	end)

	repeat
		task.wait(0.01)
	until Result ~= nil

	return Result
end

function MainMenuController:DeleteSlot(SlotNumber: number)
	DataService:DeleteSlot(SlotNumber):await()
end

function MainMenuController:LoadSlot(SlotNumber: number)
	DataService:LoadData(SlotNumber)
	self:Close()
end

function MainMenuController:CreateSlotSettings(Name: string): Core.SaveSlotSettings
	local Settings: Core.SaveSlotSettings = {}

	Settings.Name = Name or self:PickRandomName()
	Settings.Tutorial = false

	return Settings
end

function MainMenuController:CreateSlot(SlotNumber: number, SlotSettings: Core.SaveSlotSettings)
	DataService:NewSlot(SlotNumber, SlotSettings)
	self:Close()
end

function MainMenuController:Close()
	if Blur then
		Blur:Destroy()
	end

	if MainMenuTree then
		Roact.unmount(MainMenuTree)
		MainMenuTree = nil
	end

	Camera.CameraType = Enum.CameraType.Custom

	LogService:Log("Closed main menu")
end

-- [[ KNIT ]] --

function MainMenuController:KnitStart()
	DataService = Knit.GetService("DataService")
	TextFilteringService = Knit.GetService("TextFilteringService")
	LogService = Knit.GetService("LogService")

	local LightingController = Knit.GetController("LightingController")

	local MainMenu = require(ReplicatedStorage.Game.GUI.MainMenu)

	local App = Roact.createElement(MainMenu)
	MainMenuTree = Roact.mount(App, Knit.Player.PlayerGui, "MainMenu")
	LogService:Log("Mounted main menu")

	Blur = Instance.new("BlurEffect")
	Blur.Name = "MainMenuBlur"
	Blur.Size = 15
	Blur.Enabled = true

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	Blur = LightingController:AddPersistentObject(Blur)
	MainMenu = nil

	repeat
		Camera = workspace.CurrentCamera
		task.wait()
	until Camera ~= nil

	Camera.CameraType = Enum.CameraType.Scriptable
	local CameraNodes = workspace.Game:WaitForChild("MainMenuCameraPositions")

	while Camera.CameraType == Enum.CameraType.Scriptable do
		for i = 0, #CameraNodes:GetChildren() - 1, 1 do
			local Node = CameraNodes:FindFirstChild(tostring(i))

			local Tween = TweenService:Create(
				Camera,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0),
				{ CFrame = Node.CFrame }
			)
			Tween:Play()
			Tween.Completed:Wait()
			task.wait(1)
		end
	end
end

return MainMenuController
