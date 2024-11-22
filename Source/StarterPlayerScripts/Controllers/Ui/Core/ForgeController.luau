local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local CreateForgeButton = require(ReplicatedStorage.Game.GUI.Components.Forge.PickaxeButton)
local CreatOreLikeFrame = require(ReplicatedStorage.Game.GUI.Components.General.OrelikeFrame)

local ForgeController = Knit.CreateController { Name = "ForgeController" }

local DataService
local ForgeService
local LogService
local PickaxeService
local CharacterController
local DataFolder :Core.DataFolder

-- [[ PUBLIC ]] --

--[=[
Returns a boolean based on if the passed pickaxe should be locked or unlocked
]=]
function ForgeController:IsPickaxeLocked(Pickaxe :Configuration) :boolean
    local MainUpgrade = Pickaxe:GetAttribute("MainUpgrade")
    local LevelValue = Pickaxe.Upgrades:FindFirstChild(MainUpgrade)
    local NeededLevel = LevelValue.Value

    local DataValue = DataFolder.Tycoon.Upgrades:FindFirstChild(MainUpgrade)
    local CurrentLevel = DataValue.Value

    if CurrentLevel >= NeededLevel then
        return false
    end

    return true
end

--[=[
Toggles all the prompts "enabled" property to "new" param
]=]
function ForgeController:TogglePrompts(Prompts :{ProximityPrompt}, New :boolean)
    for _, Prompt in pairs(Prompts) do
        Prompt.Enabled = New
    end
end


-- [[ GUI ]] --

local ForgeComponent = Roact.Component:extend("Forge")

local CloseUI = Instance.new("BindableEvent")

function ForgeComponent:init()
    self:setState({
        PickaxeSelected = false;
        SelectedConfig = nil;
        Equipped = self.props.Equipped;
    })
end

local function CreatePickaxeButtons(Pickaxes :{Configuration}, Component :Roact.Component)
    local Buttons = {}

    for _, Pickaxe :Configuration in ipairs(Pickaxes) do
        local Owned = DataFolder.Pickaxes.Owned:FindFirstChild(Pickaxe.Name).Value
        local Locked = ForgeController:IsPickaxeLocked(Pickaxe)

        local NewButton = CreateForgeButton(Pickaxe, Owned, Locked, function()
            Component:setState({
                PickaxeSelected = true;
                Owned = Owned;
                SelectedConfig = Pickaxe;
            })
        end)

        Buttons[Pickaxe.Name] = NewButton
        LogService:Log("Created button for pickaxe: "..Pickaxe.Name)
    end

    return Buttons
end

local function CreatePickaxeCosts(Pickaxe :Configuration)
    local CostFrames = {}

    local Upgrades = Pickaxe:FindFirstChild("Upgrades")
    local Costs = Pickaxe:FindFirstChild("Ores")

    if Upgrades then
        LogService:Log("Creating tycoon upgrade frames for pickaxe: "..Pickaxe.Name)
        for _, Upgrade in pairs(Upgrades:GetChildren()) do
            local UpgradeName = Upgrade.Name
            local UpgradeIcon = Upgrade:GetAttribute("Icon")
            local UpgradeColor = Upgrade:GetAttribute("UpgradeNameColor")
            local LevelNeeded = Upgrade.Value

            CostFrames[UpgradeName] = CreatOreLikeFrame(UpgradeIcon, UpgradeName, LevelNeeded, UpgradeColor, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0))
            LogService:Log("    - Created tycoon upgrade need: "..UpgradeName.." level "..tostring(LevelNeeded))
        end
    end

    if Costs then
        LogService:Log("Creating cost frames for pickaxe: "..Pickaxe.Name)
        for OreName, Ore in pairs(Costs:GetChildren()) do
            if OreName == "GoldCoins" then continue end
            local RealOre = Core.Util:GetOreByName(Ore.Name)

            local DisplayName = RealOre:GetAttribute("DisplayName")
            local Icon = RealOre:GetAttribute("EmblemImageID")
            local Color = RealOre:GetAttribute("InventoryBackgroundColor")
            local AmountNeeded = Ore.Value

            CostFrames[OreName] = CreatOreLikeFrame(Icon, DisplayName, AmountNeeded, Color, UDim2.fromScale(1, 0.1), UDim2.fromScale(0, 0))
            LogService:Log("    - Created ore cost: "..tostring(AmountNeeded).." "..DisplayName)
        end
    end

    return CostFrames
end

function ForgeComponent:RenderFullSelector()
    local PickaxeButtons = CreatePickaxeButtons(self.props.Pickaxes, self)
    PickaxeButtons["Layout"] = Roact.createElement("UIListLayout", {
        Padding = UDim.new(0.05);
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Wraps = true;
        HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly;
        VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly;
    }, {})

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            BorderSizePixel = 0;
        }, {
            CloseButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.138, 0.06);
                Position = UDim2.fromScale(0, -0.07);
                BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                BorderSizePixel = 0;

                Text = "Close";
                TextScaled = true;
                TextColor3 = Core.UI.Color.White;
                FontFace = Core.UI.Theme.TextFont;

                [Roact.Event.MouseButton1Click] = function()
                    CloseUI:Fire()
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0.2, 0)
                }, {})
            });

            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "Forge";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            Pickaxes = Roact.createElement("ScrollingFrame", {
                Size = UDim2.fromScale(1, 0.9);
                Position = UDim2.fromScale(0, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarImageColor3 = Color3.new(1, 1, 1);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 5;
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
                VerticalScrollBarInset = Enum.ScrollBarInset.Always;
            }, PickaxeButtons );
        })
    })
end

function ForgeComponent:RenderWithInfo()
    local PickaxeButtons = CreatePickaxeButtons(self.props.Pickaxes, self)
    PickaxeButtons["Layout"] = Roact.createElement("UIListLayout", {
        Padding = UDim.new(0.05);
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Wraps = true;
        HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly;
        VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly;
    }, {})

    local SelectedConfig :Configuration = self.state.SelectedConfig
    local Pickaxe :Tool = SelectedConfig:FindFirstChildWhichIsA("Tool")
    local Equipped = SelectedConfig == self.state.Equipped
    local Owned = self.state.Owned
    local ActionText
    local ActionColor

    if Equipped then
        ActionText = "Equipped"
        ActionColor = Core.UI.Theme.BackgroundColorLight;
    elseif not Equipped and Owned then
        ActionText = "Equip"
        ActionColor = Core.UI.Theme.PrimaryButtonColor
    else
        ActionText = "Buy"
        ActionColor = Core.UI.Theme.OpenButtonColor
    end

    local CostFrames = CreatePickaxeCosts(SelectedConfig)
    CostFrames["Layout"] = Roact.createElement("UIListLayout", {}, {})

    local Name :string = SelectedConfig:GetAttribute("Name")
    local Description :string = SelectedConfig:GetAttribute("Description")
    local Delay = Pickaxe:GetAttribute("Delay")
    local Power = Pickaxe:GetAttribute("Damage")
    local Range = Pickaxe:GetAttribute("Range")

    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        Main = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            BorderSizePixel = 0;
        }, {
            CloseButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.138, 0.06);
                Position = UDim2.fromScale(0, -0.07);
                BackgroundColor3 = Core.UI.Theme.CloseButtonColor;
                BorderSizePixel = 0;

                Text = "Close";
                TextScaled = true;
                TextColor3 = Core.UI.Color.White;
                FontFace = Core.UI.Theme.TextFont;

                [Roact.Event.MouseButton1Click] = function()
                    CloseUI:Fire()
                end;
            }, {
                Corners = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0.2, 0)
                }, {})
            });

            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                Text = "Forge";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;
                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            Pickaxes = Roact.createElement("ScrollingFrame", {
                Size = UDim2.fromScale(0.6, 0.9);
                Position = UDim2.fromScale(0, 0.1);
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollBarImageColor3 = Color3.new(1, 1, 1);
                ScrollingDirection = Enum.ScrollingDirection.Y;
                ScrollBarThickness = 5;
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left;
                VerticalScrollBarInset = Enum.ScrollBarInset.Always;
            }, PickaxeButtons );

            Info = Roact.createElement("Frame", {
                Size = UDim2.fromScale(0.4, 1);
                Position = UDim2.fromScale(0.6, 0);
                BackgroundColor3 = Core.UI.Theme.BackgroundColorDark;
                BorderSizePixel = 0;
            }, {
                Deselect = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(1, 0.05);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 1;

                    Text = "<u>Back</u>";
                    RichText = true;
                    TextScaled = true;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextColor3 = Core.UI.Theme.TextColor3;
                    FontFace = Core.UI.Theme.TextFont;

                    [Roact.Event.MouseButton1Click] = function()
                        self:setState({
                            PickaxeSelected = false;
                            SelectedConfig = nil;
                        })
                    end;
                }, {});

                Name = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.1);
                    Position = UDim2.fromScale(0, 0.06);
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;
                    LayoutOrder = 2;

                    Text = "<u>"..Name.."</u>";
                    RichText = true;
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;
                }, {});

                Description = Roact.createElement("TextLabel", {
                    Size = UDim2.fromScale(1, 0.1);
                    Position = UDim2.fromScale(0, 0.16);
                    LayoutOrder = 3;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    Text = Description;
                    RichText = true;
                    TextScaled = true;
                    TextYAlignment = Enum.TextYAlignment.Top;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColorDisabled;
                }, {
                    TextSize = Roact.createElement("UITextSizeConstraint", {
                        MaxTextSize = 25;
                        MinTextSize = 14;
                    }, {})
                });

                Stats = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 0.3);
                    Position = UDim2.fromScale(0, 0.25);
                    BackgroundTransparency = 1;
                    LayoutOrder = 4;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.Name;
                    }, {});
                    Delay = CreatOreLikeFrame(Core.UI.Images.Delay, "Delay", tostring(Delay), ColorSequence.new(Color3.fromRGB(0, 0, 0)), UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0));
                    Power = CreatOreLikeFrame(Core.UI.Images.Power, "Power", tostring(Power), ColorSequence.new(Color3.fromRGB(0, 0, 0)), UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0));
                    Range = CreatOreLikeFrame(Core.UI.Images.Range, "Range", tostring(Range), ColorSequence.new(Color3.fromRGB(0, 0, 0)), UDim2.fromScale(1, 0.3), UDim2.fromScale(0, 0));
                });

                Requirments = Roact.createElement("ScrollingFrame", {
                    Size = UDim2.fromScale(1, 0.25);
                    Position = UDim2.fromScale(0, 0.55);
                    LayoutOrder = 5;
                    BackgroundTransparency = 1;
                    BorderSizePixel = 0;

                    CanvasSize = UDim2.fromScale(1, 1);
                    ScrollBarThickness = 5;
                    ScrollBarImageColor3 = Core.UI.Color.White;
                    ScrollingDirection = Enum.ScrollingDirection.Y;
                }, CostFrames );

                Action = Roact.createElement("TextButton", {
                    Size = UDim2.fromScale(0.8, 0.1);
                    Position = UDim2.fromScale(0.5, 0.95);
                    AnchorPoint = Core.UI.AnchorPoint.BottomCenter;
                    BackgroundColor3 = ActionColor;
                    LayoutOrder = 5;

                    Text = ActionText;
                    TextScaled = true;
                    FontFace = Core.UI.Theme.TextFont;
                    TextColor3 = Core.UI.Theme.TextColor3;

                    [Roact.Event.MouseButton1Click] = self.state.Owned and function ()
                        PickaxeService:EquipPickaxe(SelectedConfig)
                        self:setState({
                            Equipped = SelectedConfig;
                        })
                    end or function()
                        local CurrentEquipped = self.state.Equipped
                        self:setState({
                            Equipped = SelectedConfig;
                        })

                        PickaxeService:BuyPickaxe(SelectedConfig):andThen(function(Success :boolean)
                            if not Success then
                                self:setState({
                                    Equipped = CurrentEquipped
                                })
                            end
                        end)
                    end;
                }, {
                    Corners = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(0.1, 0)
                    }, {});
                })
            })
        })
    })
end

function ForgeComponent:render()
    LogService:Log("Rendering Forge GUI")
    local PickaxeSelected = self.state.PickaxeSelected
    return PickaxeSelected and self:RenderWithInfo() or self:RenderFullSelector()
end



-- [[ KNIT ]] --

function ForgeController:KnitStart()
    DataService = Knit.GetService("DataService")
    ForgeService = Knit.GetService("ForgeService")
    LogService = Knit.GetService("LogService")
    PickaxeService = Knit.GetService("PickaxeService")
    CharacterController = Knit.GetController("CharacterController")

    local Prompts = {}

    ForgeService:GetPromptTag():andThen(function(Tag)
        Prompts = CollectionService:GetTagged(Tag)
    end)

    local App
    local GUI

    DataService.DataLoaded:Connect(function(PlayerDataFolder :Core.DataFolder)
        DataFolder = PlayerDataFolder
    end)

    ForgeService.OpenForge:Connect(function(EquippedPickaxe)
        App = Roact.createElement(ForgeComponent, {Pickaxes = Core.Assets.Pickaxe.Pickaxes:GetChildren(), Equipped = EquippedPickaxe})
        self:TogglePrompts(Prompts, false)
        CharacterController:DisableMovement()
        GUI = Roact.mount(App, Knit.Player.PlayerGui, "Forge")
        LogService:Log("Mounted Forge GUI")
    end)

    CloseUI.Event:Connect(function()
        Roact.unmount(GUI)
        LogService:Log("Unmounted Forge GUI")
        self:TogglePrompts(Prompts, true)
        CharacterController:EnableMovement()
    end)
end


return ForgeController