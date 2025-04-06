local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ComponentClass = require(ReplicatedStorage.Packages.Component)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local TroveClass = require(ReplicatedStorage.Packages.trove)

local DataFolder = ReplicatedStorage.PlayerData:WaitForChild(Players.LocalPlayer.UserId) :: Core.DataFolder

local Component = ComponentClass.new({
	Tag = "Mine/Block",
	Ancestors = { workspace },
})

local function ClearDecals(Part: Part)
	for _, v in pairs(Part:GetChildren()) do
		if v:HasTag("OreCrackDecal") then
			v:Destroy()
		end
	end
end

local function AddDecals(Part: Part, BreakPercentage: number)
	if DataFolder.Settings.OreCracks.Value == false then
		return {}
	end

	if BreakPercentage <= 1 then
		return {}
	end

	local Decals = {}

	local IDs = {
		"rbxassetid://132006635679410",
		"rbxassetid://114596065266308",
		"rbxassetid://106722123622048",
		"rbxassetid://138265933217319",
		"rbxassetid://84292991081501",
		"rbxassetid://97545661109792",
		"rbxassetid://93522036331396",
		"rbxassetid://88663727817868",
		"rbxassetid://98080262727049",
	}

	local function Decal(Face: Enum.NormalId, Texture: string)
		local New = Instance.new("Decal")
		New.Face = Face
		New.Texture = Texture
		New.Parent = Part
		New.ZIndex = 100
		New.Transparency = 0.2
		New:AddTag("OreCrackDecal")
		table.insert(Decals, New)
	end

	local IDIndex = math.clamp(math.ceil((BreakPercentage / 100) * #IDs), 1, #IDs)
	local SelectedID = IDs[IDIndex]

	Decal(Enum.NormalId.Top, SelectedID)
	Decal(Enum.NormalId.Bottom, SelectedID)
	Decal(Enum.NormalId.Back, SelectedID)
	Decal(Enum.NormalId.Front, SelectedID)
	Decal(Enum.NormalId.Left, SelectedID)
	Decal(Enum.NormalId.Right, SelectedID)

	return Decals
end

function Component:Construct()
	self.Trove = TroveClass.new()
end

function Component:Start()
	local Block = self.Instance :: Part
	local Health = Block:GetAttribute("Health")
	local MaxHealth = Block:GetAttribute("MaxHealth")
	local Decals = AddDecals(Block, (100 - ((Health / MaxHealth) * 100)))

	for _, Decal in Decals do
		self.Trove:Add(Decal)
	end

	self.Trove:Add(Block:GetAttributeChangedSignal("Health"):Connect(function()
		local NewHealth = Block:GetAttribute("Health")
		local NewMaxHealth = Block:GetAttribute("MaxHealth")
		ClearDecals(Block)
		local NewDecals = AddDecals(Block, (100 - ((NewHealth / NewMaxHealth) * 100)))

		for _, Decal in NewDecals do
			self.Trove:Add(Decal)
		end
	end))
end

function Component:Stop()
	self.Trove:Clean()
end

return Component
