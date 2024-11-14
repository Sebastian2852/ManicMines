local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

local TycoonSelectionController = Knit.CreateController{ 
    Name = "TycoonSelectionController"
}

local TycoonService
local LogService
local DataService

local Assets = ReplicatedStorage.Assets
local TycoonAssets = Assets.Tycoon
local DataFolder :Core.DataFolder

local SelectionOutline :SelectionBox = TycoonAssets.UpgradeSelection
local CurrentlySelecting = false
local CurrentOutline = nil
local Selection = nil

local Player = Knit.Player

-- [[ PUBLIC ]]--

--[=[
Deselects the currently selected hitbox by destroying the outline it was given
]=]
function TycoonSelectionController:Deselect()
    if not CurrentlySelecting then return end
    LogService:Log("Deselecting upgrade hitbox")
    if CurrentOutline then
        CurrentOutline:Destroy()
    end
    if Selection ~= nil then
        Selection = nil
    end
    TycoonSelection.Visible = false
    CurrentlySelecting = false
end

--[=[
Selectes a given hitbox by giving it an outline, if anything is already selected it will
automatically deslect it
]=]
function TycoonSelectionController:SelectHitbox(Hitbox)
    LogService:Log("Selecting upgrade hitbox")
    if CurrentlySelecting then
        self:Deselect()
    end
    if Selection ~= nil then
        self:Deselect()
    end

    TycoonSelection.Visible = true
    local New = SelectionOutline:Clone()
    New.Parent = Hitbox
    New.Adornee = Hitbox
    New.Name = "Selection"

    CurrentOutline = New
    Selection = Hitbox
    CurrentlySelecting = true
    LogService:Log("Selected upgrade hitbox: "..Hitbox.Name)
end

--[=[
Takes in an upgrade config and returns the cost for the upgrade as a OreList or nil
if there is no config passed or no cost folder in the config
]=]
function TycoonSelectionController:CreateCostOreList(UpgradeConfig :Configuration)
    if UpgradeConfig == nil then return nil end
    if not UpgradeConfig:FindFirstChild("Cost") then return nil end
    return Core.Util:CreateOreListFromFolder(UpgradeConfig:FindFirstChild("Cost"))
end



-- [[ GUI ]] --

local TycoonSelectionComponent = Roact.Component:extend("TycoonSelection")

function TycoonSelectionComponent:init()

    self:setState({
        Show = false;
        UpgradeName = "";
        UpgradeDescription = "";
    })

    TycoonService.SelectUpgrade:Connect(function(UpgradeName :string)
        local UpgradeConfig = Core.Assets.Tycoon.Upgrades:FindFirstChild(UpgradeName)
        local NextConfig = UpgradeConfig:FindFirstChild(tostring(DataFolder.Tycoon.Upgrades:FindFirstChild(UpgradeName).Value + 1))
        self:setState({
            Show = true;
            UpgradeName = UpgradeName;
            UpgradeDescription = UpgradeConfig:GetAttribute("Description");
            NextConfig = NextConfig;
        })
    end)
end

function TycoonSelectionComponent:render()
    LogService:Log("Rendering tycoon selection GUI")
    local CostList = TycoonSelectionController:CreateCostOreList(self.state.NextConfig)
    local UpgradeCostComponents = Core.UI:CreateOreFrames(CostList, Enums.OreFrameStyle.Normal, UDim2.fromScale(0.95, 0.2))
    UpgradeCostComponents["Layout"] = Roact.createElement("UIListLayout", {}, {})

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Container = self.state.Show and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.409, 0.284);
            Position = UDim2.fromScale(0.27, 0.59);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, {
            CloseButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.138, 0.096);
                BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                BorderSizePixel = 0;

                Text = "Close";
                TextScaled = true;
                TextColor3 = Core.UI.Color.White;
                FontFace = Core.UI.Theme.TextFont;

                [Roact.Event.MouseButton1Click] = function()
                    self:setState({
                        Show = false;
                    })
                    TycoonSelectionController:Deselect()
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0.2, 0)
                }, {})
            });

            Main = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1, 0.881);
                Position = UDim2.fromScale(0, 0.12);
                BorderSizePixel = 0;

                BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {});

                UpgradeDetails = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.745, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;
                }, {
                    UpgradeName = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.263);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        Text = self.state.UpgradeName;
                        TextScaled = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextColor3 = Core.UI.Theme.TextColor3;
                        FontFace = Core.UI.Theme.TextFont;
                    }, {});

                    UpgradeDescription = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.737);
                        Position = UDim2.fromScale(0, 0.263);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        Text = self.state.UpgradeDescription;
                        TextScaled = true;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;
                        TextColor3 = Core.UI.Theme.TextColor3;
                        FontFace = Core.UI.Theme.TextFont;
                    }, {})
                });

                UpgradeCosts = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(0.255, 1);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;
                }, {
                    Title = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.1);
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        Text = "Upgrade costs";
                        TextScaled = true;
                        TextColor3 = Core.UI.Theme.TextColor3;
                        FontFace = Core.UI.Theme.TextFont;
                    }, {});

                    Costs = Roact.createElement("ScrollingFrame", {
                        Size = UDim2.fromScale(1, 0.8);
                        Position = UDim2.fromScale(0.5, 0.1);
                        AnchorPoint = Core.UI.AnchorPoint.TopCenter;
                        BackgroundTransparency = 1;
                        BorderSizePixel = 0;

                        CanvasSize = UDim2.fromScale(1, 1);
                        ScrollBarThickness = 5;
                        ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                        AutomaticCanvasSize = Enum.AutomaticSize.Y;
                        ScrollingDirection = Enum.ScrollingDirection.Y;
                        VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
                    }, UpgradeCostComponents );

                    UpgradeButton = Roact.createElement("TextButton", {
                        Size = UDim2.fromScale(0.9, 0.09);
                        Position = UDim2.fromScale(0.5, 0.99);
                        BorderSizePixel = 0;
                        AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                        BackgroundColor3 = Core.UI.Theme.PrimaryButtonColor;

                        Text = "Upgrade";
                        TextScaled = true;
                        TextColor3 = Core.UI.Theme.TextColor3;
                        FontFace = Core.UI.Theme.TextFont;

                        [Roact.Event.MouseButton1Click] = function()
                            TycoonService:Upgrade(Selection.Name):andThen(function(Success :boolean)
                                if Success then
                                    self:setState({
                                        Show = false;
                                    })
                                    TycoonSelectionController:Deselect()
                                end
                            end)
                        end;
                    }, {
                        Corners = Roact.createElement("UICorner", {
                            CornerRadius = UDim.new(0.2, 0)
                        }, {})
                    })
                })
            })
        })
    })
end



-- [[ KNIT ]]--

function TycoonSelectionController:KnitStart()
    TycoonService   = Knit.GetService("TycoonService")
    LogService      = Knit.GetService("LogService")
    DataService     = Knit.GetService("DataService")

    DataService.DataLoaded:Connect(function()
        local App = Roact.createElement(TycoonSelectionComponent)
        Roact.mount(App, Player.PlayerGui, "TycoonSelection")
        LogService:Log("Mounted tycoon selection GUI")
    end)

    DataService:GetPlayerDataFolder():andThen(function(Data)
        DataFolder = Data
    end)

    TycoonService.SelectUpgrade:Connect(function(UpgradeName :string)
        TycoonService:GetPlayerTycoon():andThen(function(Tycoon :Model)
            local Hitbox = Tycoon.Main.Upgrades:FindFirstChild(UpgradeName)
            self:SelectHitbox(Hitbox)
        end)
    end)
end

return TycoonSelectionController
