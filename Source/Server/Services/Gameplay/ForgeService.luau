local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ForgeService = Knit.CreateService({
	Name = "ForgeService",
	Client = {
		OpenForge = Knit.CreateSignal(),
	},
})

local PickaxeService

-- [[ PUBLIC ]] --

ForgeService.OpenForgePromptTag = "Forge/Prompt/Open"
ForgeService.GeneratedPromptTag = "Forge/Prompt/Generated"

--[=[
Opens the forge GUI for the given player
]=]
function ForgeService:OpenForgeForPlayer(Player: Player)
	self.Client.OpenForge:Fire(Player, PickaxeService:GetEquippedPickaxeConfig(Player))
end

--[=[
Creates a proximity prompt inside the given part that opens the forge
]=]
function ForgeService:AddPrompt(Part: BasePart)
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Name = "Open forge"
	ProximityPrompt.ActionText = "Open"
	ProximityPrompt.ObjectText = "Forge"
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt:AddTag(self.GeneratedPromptTag)

	ProximityPrompt.Triggered:Connect(function(Player)
		self:OpenForgeForPlayer(Player)
	end)

	ProximityPrompt.Parent = Part
end

-- [[ CLIENT ]] --

--[=[
Retuns the tag used by the generated proximity prompts
]=]
function ForgeService.Client:GetPromptTag()
	return self.Server.GeneratedPromptTag
end

-- [[ KNIT ]] --

function ForgeService:KnitStart()
	PickaxeService = Knit.GetService("PickaxeService")

	local OpenForgeParts: { BasePart } = CollectionService:GetTagged(self.OpenForgePromptTag)

	for _, Part in pairs(OpenForgeParts) do
		self:AddPrompt(Part)
	end
end

return ForgeService
