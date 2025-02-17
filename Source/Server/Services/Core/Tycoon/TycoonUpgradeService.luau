local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

local TycoonUpgradeService = Knit.CreateService({
	Name = "TycoonUpgradeService",
	Client = {
		OpenStorage = Knit.CreateSignal(),
	},
})

local TycoonService
local DataService
local LogService

type UpgradeSetupInformation = {
	ActionText: string,
	ObjectText: string,
}

type UpgradeSetupModule = {
	HasPrompt: boolean,
	ParentToHitbox: boolean,
	CreatePrompt: (TycoonName: string, Level: number, MaxLevel: number) -> UpgradeSetupInformation,
	Triggered: (Player: Player, IsOwner: boolean) -> (),
}

-- [[ PUBLIC ]] --

--[=[
Setup a hitbox in a way so that all of the hitboxes look the same
]=]
function TycoonUpgradeService:SetupHitbox(Hitbox: BasePart)
	return Promise.new(function(Resolve)
		Hitbox.CanCollide = false
		Hitbox.Anchored = true
		Hitbox.Transparency = 0.5
		Hitbox.CastShadow = false
		Hitbox:AddTag("Tycoon/Upgrades/Hitbox")
		Resolve()
	end)
end

--[=[
Add a GUI to a hitbox with the given level config
]=]
function TycoonUpgradeService:AddUIToHitbox(Hitbox: BasePart, LevelConfig: Configuration)
	return Promise.new(function(Resolve)
		local FoundGui = Hitbox:FindFirstChildWhichIsA("BillboardGui")
		if FoundGui then
			FoundGui:Destroy()
		end

		local Gui = Instance.new("BillboardGui")
		Gui.Size = UDim2.fromScale(10, 3)
		Gui.StudsOffset = Vector3.new(0, 9.5, 0)
		Gui.LightInfluence = 0
		Gui.MaxDistance = 100
		Gui.Brightness = 1

		local Main = Instance.new("Frame")
		Main.Name = "Main"
		Main.Size = UDim2.fromScale(1, 1)
		Main.BackgroundTransparency = 1
		Main.Parent = Gui

		local UpgradeName = Instance.new("TextLabel")
		UpgradeName.Name = "UpgradeName"
		UpgradeName.Size = UDim2.fromScale(1, 0.6)
		UpgradeName.Position = Core.UI.Position.TopLeft
		UpgradeName.AnchorPoint = Core.UI.AnchorPoint.TopLeft
		UpgradeName.BackgroundTransparency = 1
		UpgradeName.Text = LevelConfig.Parent:GetAttribute("UpgradeName")
		UpgradeName.TextColor3 = Core.UI.Color.White
		UpgradeName.FontFace = Core.UI.Theme.TextFont
		UpgradeName.TextScaled = true
		UpgradeName.TextStrokeTransparency = 0
		UpgradeName.Parent = Main

		local UpgradeNameColor = Instance.new("UIGradient")
		UpgradeNameColor.Name = "Color"
		UpgradeNameColor.Color = LevelConfig.Parent:GetAttribute("UpgradeNameColor") or Core.UI.Theme.TextColor3
		UpgradeNameColor.Parent = UpgradeName

		local UpgradeLevel = Instance.new("TextLabel")
		UpgradeLevel.Name = "UpgradeLevel"
		UpgradeLevel.Size = UDim2.fromScale(1, 0.4)
		UpgradeLevel.Position = Core.UI.Position.Bottomleft
		UpgradeLevel.AnchorPoint = Core.UI.AnchorPoint.BottomLeft
		UpgradeLevel.BackgroundTransparency = 1
		UpgradeLevel.Text = "Level " .. LevelConfig.Name
		UpgradeLevel.TextColor3 = Core.UI.Color.White
		UpgradeLevel.FontFace = Core.UI.Theme.TextFont
		UpgradeLevel.TextScaled = true
		UpgradeLevel.TextStrokeTransparency = 0
		UpgradeLevel.Parent = Main

		local UpgradeLevelColor = Instance.new("UIGradient")
		UpgradeLevelColor.Name = "Color"
		UpgradeLevelColor.Color = LevelConfig:GetAttribute("LevelColor") or Core.UI.Theme.TextColor3
		UpgradeLevelColor.Parent = UpgradeLevel

		Gui.Parent = Hitbox
		Resolve()
	end)
end

--[=[
Adds a click detector for selecting to the hitbox
]=]
function TycoonUpgradeService:AddClickDetectorToHitbox(HitBox: BasePart)
	return Promise.new(function(Resolve)
		local ClickDetector = HitBox:FindFirstChildWhichIsA("ClickDetector")
		if ClickDetector then
			ClickDetector:Destroy()
		end

		local NewClickDetector = Instance.new("ClickDetector")
		NewClickDetector.Name = "_SelectionClickDetector"
		NewClickDetector.Parent = HitBox
		NewClickDetector.MaxActivationDistance = Core.GameConfig.Tycoon.UpgradeSelectionDistance

		NewClickDetector.MouseClick:Connect(function(Player)
			TycoonService.Client.SelectUpgrade:Fire(Player, HitBox.Name) -- Event should probably be moved to this service
		end)

		Resolve()
	end)
end

--[=[
Adds the model to a hitbox based on the passed level config
]=]
function TycoonUpgradeService:AddModelToHitbox(Hitbox: BasePart, LevelConfig: Configuration)
	return Promise.new(function(Resolve, Reject)
		local Model = LevelConfig:FindFirstChildWhichIsA("Model")
		if not Model then
			Reject("Cannot get model")
		end

		local CurrentModel = Hitbox:FindFirstChildWhichIsA("Model")
		if CurrentModel then
			CurrentModel:Destroy()
		end

		local NewModel = Model:Clone()
		NewModel:PivotTo(Hitbox.CFrame)
		NewModel.Parent = Hitbox
		Resolve()
	end)
end

--[=[
Gives functionality to an upgrade
]=]
function TycoonUpgradeService:AddFunctionality(
	Hitbox: BasePart,
	SetupModule: UpgradeSetupModule,
	Tycoon: Model,
	LevelConfig: Configuration
)
	return Promise.new(function(Resolve, Reject)
		if not SetupModule.HasPrompt then
			Resolve()
		end

		local TycoonOwner = TycoonService:GetTycoonOwner(Tycoon)
		if not TycoonOwner then
			Reject("No owner for tycoon")
		end
		local OwnerData: Core.DataFolder = DataService:GetPlayerDataFolder(TycoonOwner)

		local Info: UpgradeSetupInformation = SetupModule.CreatePrompt(
			OwnerData.TycoonName.Value,
			tonumber(LevelConfig.Name),
			self:GetUpgradeMaxLevel(LevelConfig.Parent)
		)

		local NewPrompt = Instance.new("ProximityPrompt")
		NewPrompt.Name = "Interact"
		NewPrompt.ActionText = Info.ActionText
		NewPrompt.ObjectText = Info.ObjectText
		NewPrompt.Parent = Hitbox

		NewPrompt.Triggered:Connect(function(Player)
			local IsOwner = Player == TycoonOwner
			SetupModule.Triggered(Player, IsOwner)
		end)

		LogService:Log("Created proximity prompt")

		Resolve()
	end)
end

--[=[
Takes in a level config and returns how many possible upgrades there are.
]=]
function TycoonUpgradeService:GetUpgradeMaxLevel(UpgradeConfig: Configuration)
	local Children = UpgradeConfig:GetChildren()
	return #Children - 1
end

--[=[
This function add the model to the tycoon, sets up the hitbox (if needed) and adds the GUI to the hitbox
]=]
function TycoonUpgradeService:AddUpgradeToTycoonAsync(Player: Player, UpgradeName: string, Tycoon: Model)
	LogService:Log("Adding upgrade", UpgradeName, "to", tostring(Player.UserId) .. "'s", "tycoon")
	return Promise.new(function(Resolve, Reject)
		assert(Player:IsDescendantOf(Players), "Player is not a valid player")
		assert(Tycoon:IsDescendantOf(workspace.Game.Tycoons), "Tycoon must be a tycoon in workspace")

		local PlayerData: Core.DataFolder = DataService:GetPlayerDataFolder(Player)

		local DataValue = PlayerData.Tycoon.Upgrades:FindFirstChild(UpgradeName)
		local TycoonHitbox = Tycoon.Main.Upgrades:FindFirstChild(UpgradeName)
		local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
		local SetupModule = ServerScriptService.Game.TycoonUpgradeSetups:FindFirstChild(UpgradeName)
		local LevelConfig = UpgradeConfig:FindFirstChild(tostring(DataValue.Value))

		if not UpgradeConfig then
			LogService:Error("Unkown upgrade:", UpgradeName)
		end

		if not DataValue then
			LogService:Error("Cannot find data value for upgrade:", UpgradeName)
		end

		if not TycoonHitbox then
			LogService:Error("Cannot find tycoon hitbox for upgrade:", UpgradeName)
		end

		if not SetupModule then
			LogService:Error("Cannot find upgrade setup module for upgrade:", UpgradeName)
		end
		SetupModule = require(SetupModule)

		local Tasks = {}

		table.insert(Tasks, self:SetupHitbox(TycoonHitbox))
		table.insert(Tasks, self:AddUIToHitbox(TycoonHitbox, LevelConfig))
		table.insert(Tasks, self:AddModelToHitbox(TycoonHitbox, LevelConfig))
		table.insert(Tasks, self:AddClickDetectorToHitbox(TycoonHitbox))
		table.insert(Tasks, self:AddFunctionality(TycoonHitbox, SetupModule, Tycoon, LevelConfig))

		local Success = Promise.all(Tasks):await()
		if Success then
			Resolve()
		else
			Reject("a task(s) failed")
		end
	end)
end

--[=[
Returns true/false if the given upgrade name is an upgrade that actually exists
]=]
function TycoonUpgradeService:ValidUpgradeName(UpgradeName: string): boolean
	local Upgrade = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
	return Upgrade and true or false
end

--[=[
Returns the config for the upgrade with the given name
]=]
function TycoonUpgradeService:GetUpgradeByName(UpgradeName: string): Configuration | nil
	if not self:ValidUpgradeName(UpgradeName) then
		return nil
	end
	return Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
end

--[=[
Get the data value for the given upgrade name for the given player
]=]
function TycoonUpgradeService:GetUpgradeDataValue(Player: Player, UpgradeName: string): IntValue | nil
	if not self:ValidUpgradeName(UpgradeName) then
		return nil
	end
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)
	return DataFolder.Tycoon.Upgrades:FindFirstChild(UpgradeName)
end

--[=[
Returns true/false if the given player can upgrade the upgrade with the given name
]=]
function TycoonUpgradeService:CanBeUpgraded(Player: Player, UpgradeName: string)
	local DataFolder: Core.DataFolder = DataService:GetPlayerDataFolder(Player)

	local DataValue = DataFolder.Tycoon.Upgrades:FindFirstChild(UpgradeName)
	if not DataValue then
		LogService:Warn("Invalid upgrade name passed; Can't find data for upgrade:", UpgradeName)
		return
	end

	local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
	if not UpgradeConfig then
		LogService:Warn("Invalid upgrade name:", UpgradeName)
		return
	end

	if UpgradeConfig:FindFirstChild(tostring(DataValue.Value + 1)) then
		return true
	end
	return false
end

--[=[
Returns true/false if the given player can afford an upgrade for the given upgrade for the given level
]=]
function TycoonUpgradeService:CanAffordUpgrade(Player: Player, UpgradeName: string, Level: number): boolean
	if not self:ValidUpgradeName(UpgradeName) then
		return false
	end
	local UpgradeConfig = self:GetUpgradeByName(UpgradeName)
	local LevelConfig = UpgradeConfig:FindFirstChild(tostring(Level))
	if not LevelConfig then
		return false
	end

	local OreCosts = LevelConfig:FindFirstChild("Cost")

	if OreCosts then
		local OreCostList = Core.OreList.CreateFromFolder(OreCosts)
		local AffordCosts = DataService:CanAfford(Player, OreCostList, Enums.CostInclude.Inventory)
		if not AffordCosts then
			return false
		end
	end

	return true
end

--[=[
Makes the given player pay for the given upgrades level
]=]
function TycoonUpgradeService:PayForUpgrade(Player: Player, UpgradeName: string, Level: number): boolean
	if not self:ValidUpgradeName(UpgradeName) then
		return
	end
	local UpgradeConfig = self:GetUpgradeByName(UpgradeName)
	local LevelConfig = UpgradeConfig:FindFirstChild(tostring(Level))
	if not LevelConfig then
		return
	end

	local OreCosts = LevelConfig:FindFirstChild("Costs")

	if OreCosts then
		local OreCostList = Core.OreList.CreateFromFolder(OreCosts)
		DataService:HandleCosts(Player, OreCostList, Enums.CostInclude.Inventory)
	end
end

--[=[
Upgrade the given upgrade for the given player. This also updates the tycoon model and data.
Returns true/false based on if the upgrade was actually upgraded
]=]
function TycoonUpgradeService:Upgrade(Player: Player, Tycoon: Model, UpgradeName: string): boolean
	LogService:Log("Attempting to upgrade " .. Player.Name .. "'s tycoon upgrade: " .. UpgradeName)
	if not self:CanBeUpgraded(Player, UpgradeName) then
		LogService:Warn("Failed: cannot be upgraded")
		return false
	end

	local DataValue = self:GetUpgradeDataValue(Player, UpgradeName)
	if not DataValue then
		LogService:Warn("Failed: Invalid upgrade name: " .. UpgradeName)
		return false
	end

	if not self:CanAffordUpgrade(Player, UpgradeName, DataValue.Value + 1) then
		LogService:Warn("Failed: can't afford")
		return false
	end

	self:PayForUpgrade(Player, UpgradeName, DataValue.Value + 1)
	DataValue.Value += 1

	self:AddUpgradeToTycoonAsync(Player, UpgradeName, Tycoon)
	return true
end

-- [[ KNIT ]] --

function TycoonUpgradeService:KnitStart()
	DataService = Knit.GetService("DataService")
	LogService = Knit.GetService("LogService")
	TycoonService = Knit.GetService("TycoonService")
end

return TycoonUpgradeService
