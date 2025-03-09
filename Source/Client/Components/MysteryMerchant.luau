local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local CharacterController

local MysteryMerchantComponent = Component.new({
	Tag = "MysteryMerchant/OpenGUI",
	Ancestors = { workspace },
})

function MysteryMerchantComponent:CloseGUI()
	if self.Tree then
		Roact.unmount(self.Tree)
		self.Prompt.Enabled = true
		CharacterController:EnableMovement()
	end
end

function MysteryMerchantComponent:OpenGUI()
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

	NewPrompt.Triggered:Connect(function()
		self:OpenGUI()
	end)

	self.Prompt = NewPrompt
end

function MysteryMerchantComponent:Stop()
	if self.Prompt then
		self.Prompt:Destroy()
	end

	self:CloseGUI()
end

return MysteryMerchantComponent
