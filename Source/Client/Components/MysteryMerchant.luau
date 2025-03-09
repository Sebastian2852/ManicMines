local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)

local MysteryMerchantComponent = Component.new({
	Tag = "MysteryMerchant/OpenGUI",
	Ancestors = { workspace },
})

function MysteryMerchantComponent:Start()
	local NewPrompt = Instance.new("ProximityPrompt")
	NewPrompt.ActionText = "Trade"
	NewPrompt.ObjectText = "Mystery Merchant"
	NewPrompt.RequiresLineOfSight = false
	NewPrompt.MaxActivationDistance = 20
	NewPrompt.Parent = self.Instance.Main.PromptPart
	self.Prompt = NewPrompt
end

function MysteryMerchantComponent:Stop()
	if self.Prompt then
		self.Prompt:Destroy()
	end
end

return MysteryMerchantComponent
