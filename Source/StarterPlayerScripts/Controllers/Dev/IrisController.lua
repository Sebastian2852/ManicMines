local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Iris = require(ReplicatedStorage.Packages.Iris)

local IrisController = Knit.CreateController { Name = "IrisController" }

IrisController.EnableDevMode = false
local LogService
local MineService

local LogBuffer = {}
local LogSearch = ""

local GeneralStats = {Ores = {}, Layers = {}, Pickaxes = {}}
local ScriptingStats = {Services = 0, Controllers = 0, GeneralModules = 0}
local MineStats = {TotalBlocks = 0, TotalStone = 0, TotalOres = 0, BlocksToCollapse = 0}

local function UpdateMineStats()
    MineService:GetBlocksToCollapse():andThen(function(Amount)
        MineStats.BlocksToCollapse = Amount
    end)
    MineStats.TotalBlocks = 0
    MineStats.TotalStone = 0
    MineStats.TotalOres = 0

    for _, Child in pairs(workspace.Game.Mine:GetChildren()) do
        if Child:HasTag("_Stone") then
            MineStats.TotalStone += 1
        elseif Child:HasTag("_Ore") then
            MineStats.TotalOres += 1
        end

        MineStats.TotalBlocks += 1
    end

    MineStats.BlocksUntilCollapse = MineStats.BlocksToCollapse - MineStats.TotalBlocks
end

local function UpdateScriptingStats()
    local Services = 0
    local Controllers = 0
    local GeneralModules = 0

    for _, v in pairs(Knit.Player.PlayerScripts.Game:GetDescendants()) do
        if v:IsA("ModuleScript") then
            Controllers += 1
        end
    end

    for _, v in pairs(ReplicatedStorage.Game.Modules:GetDescendants()) do
        if v:IsA("ModuleScript") then
            GeneralModules += 1
        end
    end

    ScriptingStats.Services = Services
    ScriptingStats.Controllers = Controllers
    ScriptingStats.GeneralModules = GeneralModules
end

local function UpdateGeneralStats()
    local Ores = 0
    local Pickaxes = 0
    local Layers = 0

    Ores = ReplicatedStorage.Assets.Ores:GetChildren()
    Pickaxes = ReplicatedStorage.Assets.Pickaxe.Pickaxes:GetChildren()
    Layers = ReplicatedStorage.Assets.Layers:GetChildren()

    GeneralStats.Layers = Layers
    GeneralStats.Pickaxes = Pickaxes
    GeneralStats.Ores = Ores
end

local function UpdateStats()
    UpdateMineStats()
    UpdateScriptingStats()
    UpdateGeneralStats()
end

local function NewLog(Messages)
    local Message = ""

    for _, Msg in pairs(Messages) do
        Message = Message.." "..tostring(Msg)
    end

    table.insert(LogBuffer, Message)
end

function IrisController:Console()
    Iris.Window({
        [Iris.Args.Window.Title] = "Console",
        [Iris.Args.Window.NoClose] = true,
    })
        Iris.SameLine()
            if Iris.Button({"Clear console"}).clicked() then
                LogBuffer = {}
            end
            LogSearch = Iris.InputText({"", "Search filter"})
        Iris.End()

        for _, Log in ipairs(LogBuffer) do
            if string.find(string.lower(Log), string.lower(LogSearch.text.value)) then
                Iris.Text({Log})
            end
        end
    Iris.End()
end

function IrisController:StatsWindow()
    Iris.Window({
        [Iris.Args.Window.Title] = "Stats",
        [Iris.Args.Window.NoClose] = true,
    })

        Iris.Tree({"General"})
        if #GeneralStats.Ores >= 1 then
            Iris.Tree({"Ores - "..#GeneralStats.Ores})
            for i, Ore in ipairs(GeneralStats.Ores) do
                Iris.Text({"["..i.."] "..Ore.Name})
            end
            Iris.End()
        end

        if #GeneralStats.Layers >= 1 then
            Iris.Tree({"Layers - "..#GeneralStats.Layers})
            for i, Layer in ipairs(GeneralStats.Layers) do
                local DepthRange :NumberRange = Layer:GetAttribute("Depth")
                Iris.Text({"["..i.."] "..Layer.Name.." ("..DepthRange.Min.." - "..DepthRange.Max..")"})
            end
            Iris.End()
        end


            if #GeneralStats.Layers >= 1 then
                Iris.Tree({"Pickaxes - "..#GeneralStats.Pickaxes})
                for i, Pickaxe in ipairs(GeneralStats.Pickaxes) do
                    Iris.Text({"["..i.."] "..Pickaxe:GetAttribute("Name")})
                end
                Iris.End()
            end
        Iris.End()

        Iris.Tree({"Scripting"})
            Iris.Text({"Services: "..ScriptingStats.Services})
            Iris.Text({"Controllers: "..ScriptingStats.Controllers})
            Iris.Text({"General Modules: "..ScriptingStats.GeneralModules})
        Iris.End()

        Iris.Tree({"Mine stats"})
            local ColorToSet = Color3.fromRGB(255, 255, 255)

            if MineStats.BlocksUntilCollapse <= 10 then
                ColorToSet = Color3.fromRGB(255, 255, 0)
            end

            if MineStats.BlocksUntilCollapse <= 0 then
                ColorToSet = Color3.fromRGB(255, 0, 0)
            end

            Iris.Text({"Total blocks in mine: "..MineStats.TotalBlocks})
            Iris.Text({"    - Stone in mine: "..MineStats.TotalStone})
            Iris.Text({"    - Ores in mine: "..MineStats.TotalOres})
            Iris.Text({"Blocks to collapse mine: "..MineStats.BlocksToCollapse})
        Iris.End()

    Iris.End()
end

function IrisController:Update()
    if self.EnableDevMode then
        UpdateStats()
        self:Console()
        self:StatsWindow()
    end
end

function IrisController:KnitInit()
    LogService = Knit.GetService("LogService")
    MineService = Knit.GetService("MineService")
    local UserInputService = game:GetService("UserInputService")

    LogService.ActionLog:Connect(function(Color :Color3, ...)
        local Args = {...}
        NewLog(Args)
    end)

    Iris.Init()
    Iris:Connect(function()
        self:Update()
    end)

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then return end
        if Input.KeyCode ~= Enum.KeyCode.P then return end

        self.EnableDevMode = not self.EnableDevMode
    end)
end

return IrisController
