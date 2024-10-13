local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Iris = require(ReplicatedStorage.Packages.Iris)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local IrisController = Knit.CreateController { Name = "IrisController" }

IrisController.EnableDevMode = false
IrisController.DemoWindow = false
local LogService
local MineService
local AdminService
local DataService
local TycoonService

local LogBuffer = {}
local LogSearch = ""

local Admin_Permissions :Core.AdminPermissions
local Admin_CurrentPlayer = 0
local Admin_IsAdmin = false
local Admin_Open = false
local Admin_CurrentTycoon = {
    TycoonName = "NILL";
    Upgrades = {}
}

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

local function GetTycoonDetails(Player :Player)
    DataService:GetOtherPlayerStats(Player):andThen(function(Data :Core.DataFolder)
        Admin_CurrentTycoon.TycoonName = Data.Tycoon.TycoonName.Value
        Admin_CurrentTycoon.Upgrades = {}

        for _, Value in pairs(Data.Tycoon.Upgrades:GetChildren()) do
            Admin_CurrentTycoon.Upgrades[Value.Name] = Value.Value
        end
    end)
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
        [Iris.Args.Window.NoBackground] = true,
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

        Iris.CollapsingHeader({"General"})
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

        Iris.CollapsingHeader({"Scripting"})
            Iris.Text({"Services: "..ScriptingStats.Services})
            Iris.Text({"Controllers: "..ScriptingStats.Controllers})
            Iris.Text({"General Modules: "..ScriptingStats.GeneralModules})
        Iris.End()

        Iris.CollapsingHeader({"Mine stats"})
            Iris.Text({"Total blocks in mine: "..MineStats.TotalBlocks})
            Iris.Text({"    - Stone in mine: "..MineStats.TotalStone})
            Iris.Text({"    - Ores in mine: "..MineStats.TotalOres})
            Iris.Text({"Blocks to collapse mine: "..MineStats.BlocksToCollapse})
        Iris.End()

    Iris.End()
end

function IrisController:AdminPanel(DataFolder :Core.DataFolder)
    local NoBackground = Iris.State(false)
    local NoMove = Iris.State(false)

    local DevMode = Iris.State(self.EnableDevMode)
    local DemoWindow = Iris.State(self.DemoWindow)

    Iris.Window({
        [Iris.Args.Window.Title] = "Admin panel V0.0.1",

        -- Customisable stuff
        [Iris.Args.Window.NoBackground] = NoBackground.value,
        [Iris.Args.Window.NoMove] = NoMove.value,

        -- Forced stuff that cant be changed
        [Iris.Args.Window.NoTitleBar] = false,
        [Iris.Args.Window.NoCollapse] = true,
        [Iris.Args.Window.NoClose] = true,
        [Iris.Args.Window.NoScrollbar] = false,
        [Iris.Args.Window.NoResize] = false,
        [Iris.Args.Window.NoNav] = false,
        [Iris.Args.Window.NoMenu] = false,
    }, {size = Iris.State(Vector2.new(438, 550)), position = Iris.State(Vector2.new(10, 10))})

    Iris.MenuBar()
        Iris.Menu({"Tools"})
            Iris.MenuToggle({"Dev Mode"}, {isChecked = DevMode})
            self.EnableDevMode = DevMode.value


            Iris.Menu({"IRIS"})
                Iris.MenuToggle({"IRIS demo window"}, {isChecked = DemoWindow})
                self.DemoWindow = DemoWindow.value
            Iris.End()

            Iris.Menu({"Options"})
                Iris.MenuToggle({"No background"}, {isChecked = NoBackground})
                Iris.MenuToggle({"No move"}, {isChecked = NoMove})
            Iris.End()
        Iris.End()
    Iris.End()

    if Admin_CurrentPlayer ~= 0 then
        local UpgradeInputs = {}
        local NameInput = Admin_CurrentTycoon.TycoonName

        Iris.SameLine()
            local Player = game.Players:GetPlayerByUserId(Admin_CurrentPlayer)
            if Iris.Button({"<- Back"}).clicked() then
                Admin_CurrentPlayer = 0
            end
            Iris.Text({"Current player: "..Player.DisplayName.." (@"..Player.Name..") "..Admin_CurrentPlayer})
        Iris.End()

        if Admin_Permissions.EditTycoonName or Admin_Permissions.EditTycoonUpgrades then
            Iris.SeparatorText({"Tycoon"})
            if Admin_Permissions.EditTycoonName then
                local TycoonNameInput = Iris.InputText({"Tycoon name", Admin_CurrentTycoon.TycoonName}, {Admin_CurrentTycoon.TycoonName})
                NameInput = TycoonNameInput.text.value
            end

            if Admin_Permissions.EditTycoonUpgrades then
                Iris.Text({"Upgrades"})
                for _, Upgrade in pairs(DataFolder.Tycoon.Upgrades:GetChildren()) do
                    local Max = (#Core.Assets.Tycoon.Upgrades:FindFirstChild(Upgrade.Name):GetChildren()) - 1
                    local Input = Iris.SliderNum({Upgrade.Name, 1, 0, Max}, {Admin_CurrentTycoon.Upgrades[Upgrade.Name]})
                    UpgradeInputs[Upgrade.Name] = Input.state.number.value
                end
            end

            Iris.SameLine()

            if Iris.Button({"Update"}).clicked() then
                for Name, Value in pairs(UpgradeInputs) do
                    TycoonService:SetUpgradeValue(game.Players:GetPlayerByUserId(Admin_CurrentPlayer), Name, Value)
                end
                TycoonService:SetTycoonName(game.Players:GetPlayerByUserId(Admin_CurrentPlayer), NameInput)
            end

            if Iris.Button({"Reset"}).clicked() then
                Iris.Text({"Test"})
            end 
            Iris.End()
        end
    else
        Iris.SeparatorText({"Quick Actions"})

        Iris.SeparatorText({"Players"})
        Iris.Table({4})
            Iris.Text({"Username"})
            Iris.NextColumn()
            Iris.Text({"Display Name"})
            Iris.NextColumn()
            Iris.Text({"UserID"})
            Iris.NextColumn()
            Iris.Text({"Actions"})
            Iris.NextRow()
            Iris.NextColumn()

            for _, Player in ipairs(game.Players:GetPlayers()) do
                Iris.Text({Player.Name})
                Iris.NextColumn()

                Iris.Text({Player.DisplayName})
                Iris.NextColumn()

                Iris.Text({tostring(Player.UserId)})
                Iris.NextColumn()

                if Iris.Button({"Select"}).clicked() then
                    Admin_CurrentPlayer = Player.UserId
                    GetTycoonDetails(Player)
                end
                Iris.NextRow()
                Iris.NextColumn()
            end
        Iris.End()
    end


    Iris.End()
end

function IrisController:Update(DataFolder :Core.DataFolder)
    if self.DemoWindow then
        Iris.ShowDemoWindow()
    end

    if self.EnableDevMode then
        UpdateStats()
        self:Console()
        self:StatsWindow()
    end

    if Admin_IsAdmin and Admin_Open then
        self:AdminPanel(DataFolder)
    end
end

function IrisController:KnitInit()
    LogService = Knit.GetService("LogService")
    MineService = Knit.GetService("MineService")
    AdminService = Knit.GetService("AdminService")
    DataService = Knit.GetService("DataService")
    TycoonService = Knit.GetService("TycoonService")

    AdminService:GetPermissions():andThen(function(Permissions)
        Admin_Permissions = Permissions
    end)

    local UserInputService = game:GetService("UserInputService")

    LogService.ActionLog:Connect(function(_, ...)
        local Args = {...}
        NewLog(Args)
    end)

    AdminService:IsPlayerAdmin():andThen(function(Admin :boolean)
        Admin_IsAdmin = Admin
    end)

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then return end
        if Input.KeyCode ~= Enum.KeyCode.P then return end
        Admin_Open = not Admin_Open
    end)

    DataService:GetPlayerDataFolder():andThen(function(DataFolder)
        Iris.Init()
        Iris:Connect(function()
            self:Update(DataFolder)
        end)
    end)
end

return IrisController
