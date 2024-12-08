local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local TycoonGeneratorService = Knit.CreateService {
    Name = "TycoonGeneratorService",
    Client = {},
}

local LogService
local DataService
local TycoonService
local TycoonUpgradeService

function TycoonGeneratorService:GetGeneratorDataValue(Player :Player, GeneratorName :string) :IntValue|nil
    local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Player)
    return DataFolder.Tycoon.Generators:FindFirstChild(GeneratorName)
end

function TycoonGeneratorService:AddGuiToGenerator(Generator :BasePart, Configuration :Configuration, DataFolder :Core.DataFolder)
    local DataValue = self:GetGeneratorDataValue(Players:GetPlayerByUserId(DataFolder.Name), Generator.Name)

    local Gui = Instance.new("BillboardGui")
    Gui.Parent = Generator
    Gui.Adornee = Generator
    Gui.LightInfluence = 0
    Gui.Size = UDim2.fromScale(7, 7)
    Gui.MaxDistance = 100
    Gui.StudsOffset = Vector3.new(0, 5, 0)
    Gui.ResetOnSpawn = false

    local TopText = Instance.new("TextLabel")
    TopText.BackgroundTransparency = 1
    TopText.BorderSizePixel = 0
    TopText.Size = UDim2.fromScale(1, 0.6)
    TopText.FontFace = Core.UI.Theme.TextFont
    TopText.TextColor3 = Core.UI.Color.White
    TopText.TextScaled = true
    TopText.TextYAlignment = Enum.TextYAlignment.Bottom
    TopText.TextStrokeTransparency = 0
    TopText.Text = Configuration:GetAttribute("DisplayName")
    TopText.Parent = Gui

    local TopTextGradient = Instance.new("UIGradient")
    TopTextGradient.Color = Configuration:GetAttribute("NameColor")
    TopTextGradient.Parent = TopText

    local BottomText = Instance.new("TextLabel")
    BottomText.BackgroundTransparency = 1
    BottomText.BorderSizePixel = 0
    BottomText.Size = UDim2.fromScale(1, 0.4)
    BottomText.Position = UDim2.fromScale(0, 0.6)
    BottomText.FontFace = Core.UI.Theme.TextFont
    BottomText.TextColor3 = Core.UI.Color.White
    BottomText.TextScaled = true
    BottomText.TextYAlignment = Enum.TextYAlignment.Top
    BottomText.TextStrokeTransparency = 0
    BottomText.Text = DataValue.Value
    BottomText.Parent = Gui

    local BottomTextGradient = Instance.new("UIGradient")
    BottomTextGradient.Color = Configuration:GetAttribute("AmountColor")
    BottomTextGradient.Parent = BottomText

    DataValue:GetPropertyChangedSignal("Value"):Connect(function()
        BottomText.Text = DataValue.Value
    end)
end

function TycoonGeneratorService:AddFunctionality(Generator :BasePart, Configuration :Configuration, DataFolder :Core.DataFolder)
    local GeneratorDataValue = self:GetGeneratorDataValue(Players:GetPlayerByUserId(DataFolder.Name), Generator.Name)
    local CurrencyDataValue = DataFolder:FindFirstChild(Configuration:GetAttribute("Currency"))

    Generator.Touched:Connect(function(Part :BasePart)
        local Player = Players:GetPlayerFromCharacter(Part.Parent)

        if not Player then return end
        if TycoonService:GetPlayerTycoon(Player) ~= Generator.Parent.Parent.Parent then return end

        CurrencyDataValue.Value += GeneratorDataValue.Value
        GeneratorDataValue.Value = 0
    end)
end

function TycoonGeneratorService:AddGeneratorsToTycoonAsync(Tycoon :Model, Owner :Player)
    return Promise.new(function(Resolve)
        local DataFolder :Core.DataFolder = DataService:GetPlayerDataFolder(Owner)
        local GeneratorsFolder = Tycoon.Main:FindFirstChild("Generators") :: Folder
        if not GeneratorsFolder then
            Resolve()
        end

        for _, GeneratorPart :BasePart in pairs(GeneratorsFolder:GetChildren()) do
            LogService:Log("Setting up generator: "..GeneratorPart:GetFullName())

            GeneratorPart.Anchored = true
            GeneratorPart.CanCollide = false

            local GeneratorConfig :Configuration = Core.Assets.Tycoon.Generators:FindFirstChild(GeneratorPart.Name)
            if not GeneratorConfig then
                LogService:Warn("No config found for generator: "..GeneratorPart:GetFullName())
                continue
            end

            local UpgradeName = GeneratorConfig:GetAttribute("Upgrade") :: string
            local Currency = GeneratorConfig:GetAttribute("Currency") :: string

            if not TycoonUpgradeService:ValidUpgradeName(UpgradeName) then
                LogService:Warn("Invalid upgrade name: "..UpgradeName.." for config: "..GeneratorConfig:GetFullName())
                continue
            end

            if not DataFolder:FindFirstChild(Currency) then
                LogService:Warn("Invalid currency name: "..Currency.." for config: "..GeneratorConfig:GetFullName().." (Note: Currency must be placed in root of data folder!)")
                continue
            end

            self:AddGuiToGenerator(GeneratorPart, GeneratorConfig, DataFolder)
            self:AddFunctionality(GeneratorPart, GeneratorConfig, DataFolder)

            task.spawn(function()
                LogService:Log("["..Owner.Name.."]", "Starting generator loop")
                while true do
                    if not TycoonService:GetTycoonOwner(Tycoon) then break end

                    local UpgradeValue = TycoonUpgradeService:GetUpgradeDataValue(Owner, UpgradeName)
                    local TickrateConfig = GeneratorConfig:FindFirstChild(UpgradeValue.Value and tostring(UpgradeValue.Value) or "0")

                    local TickRate = TickrateConfig:GetAttribute("TickRate") :: number
                    local Amount = TickrateConfig:GetAttribute("Amount") :: number

                    local DataValue = self:GetGeneratorDataValue(Owner, GeneratorConfig.Name)
                    if not DataValue then break end

                    DataValue.Value += Amount
                    LogService:Log("["..Owner.Name.."]", "Added "..tostring(Amount).." value to generator: "..DataValue.Name)

                    task.wait(TickRate)
                end
                LogService:Log("["..Owner.Name.."]", "Finished generator loop")
            end)
        end
    end)
end



-- [[ KNIT ]] --

function TycoonGeneratorService:KnitStart()
    LogService = Knit.GetService("LogService")
    TycoonService = Knit.GetService("TycoonService")
    DataService = Knit.GetService("DataService")
    TycoonUpgradeService = Knit.GetService("TycoonUpgradeService")
end

return TycoonGeneratorService