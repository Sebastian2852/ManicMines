local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)
local Roact = require(ReplicatedStorage.Packages.Roact)

local CharacterController

local MysteryMerchantComponent = Component.new({
	Tag = "MysteryMerchant/OpenGUI",
	Ancestors = { workspace },
})

function MysteryMerchantComponent:CloseGUI()
	Logger:Log("Closing mystery merchant GUI")
	if self.Tree then
		Roact.unmount(self.Tree)
		self.Prompt.Enabled = true
		CharacterController:EnableMovement()
		Logger:Log("Unmounted GUI tree")
	else
		Logger:Warn("Mystery merchant GUI not open")
	end
end

function MysteryMerchantComponent:OpenGUI()
	Logger:Log("Opening mystery merchant GUI")
	self:CloseGUI()
	local GUI = require(ReplicatedStorage.Game.GUI.MysteryMerchant)
	self.Tree = Roact.mount(
		Roact.createElement(GUI, {
			Close = function()
				self:CloseGUI()
			end,
		}),
		Players.LocalPlayer.PlayerGui,
		"MysteryMerchant"
	)
	self.Prompt.Enabled = false
	Logger:Log("Mounted GUI tree")
	CharacterController:DisableMovement()
end

function MysteryMerchantComponent:Start()
	CharacterController = Knit.GetController("CharacterController")

	local NewPrompt = Instance.new("ProximityPrompt")
	NewPrompt.ActionText = "Trade"
	NewPrompt.ObjectText = "Mystery Merchant"
	NewPrompt.RequiresLineOfSight = false
	NewPrompt.MaxActivationDistance = 20
	NewPrompt.Parent = self.Instance.Main.PromptPart
	Logger:Log("Created prompt")

	NewPrompt.Triggered:Connect(function()
		self:OpenGUI()
	end)

	self.Prompt = NewPrompt
end

function MysteryMerchantComponent:Stop()
	if self.Prompt then
		self.Prompt:Destroy()
		Logger:Log("Destroyed prompt")
	end

	self:CloseGUI()
end

return MysteryMerchantComponent
