local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SettingsController = Knit.CreateController { Name = "PlayerSettingsController" }

local Player = Knit.Player

local LogService
local SettingsService
local DataService

local Settings :Core.Settings = {}

--[[ PRIVATE ]]--

--[=[
Pushes the current settings to the server
]=]
local function PushToServer()
    LogService:Log("Pushing settings to server")
    SettingsService:PushSettings(Settings)
end


--[=[
Updates the settings by actually doing the settings (e.g. Disabling shadows)
Only does things that can be done by the client. The rest will be handled by the server
]=]
local function Update()
    LogService:Log("Updating settings")
    game.Lighting.GlobalShadows = Settings.GlobalShadows
end

--[[
!!!This is only here to test the settings!!!
]]
UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end
    if Input.KeyCode == Enum.KeyCode.Z then 
        Settings.GlobalShadows = not Settings.GlobalShadows
        Settings.RainbowEffect = not Settings.RainbowEffect
        PushToServer()
    end
end)


-- [[ UI ]] --

local SettingsComponent = Core.Roact.Component:extend("SettingsComponent")

local Objects = 0

function SettingsComponent:SettingsHeader(HeadingText :string)
    Objects += 1;
    return Core.Roact.createElement("TextLabel", {
        Size = UDim2.fromScale(0.9, 0.135);
        Position = UDim2.fromScale(0.5, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Objects;

        Text = HeadingText;
        TextScaled = true;

        FontFace = Core.UI.Theme.TextFont;
        TextColor3 = Core.UI.Theme.TextColor3;
    }, {})
end

function SettingsComponent:SettingsSubtitle(SubtitleText :string)
    Objects += 1;
    return Core.Roact.createElement("TextLabel", {
        Size = UDim2.fromScale(0.9, 0.1);
        Position = UDim2.fromScale(0.5, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Objects;

        Text = SubtitleText;
        TextScaled = true;

        FontFace = Core.UI.Theme.TextFont;
        TextColor3 = Core.UI.Theme.TextColorDisabled;
    }, {})
end

function SettingsComponent:Checkbox(SettingName :string)
    local Value = Settings[SettingName]
    if Value == nil then
        LogService:Warn("Invalid setting name!")
        return
    end

    local ImageId = "rbxassetid://4458801905"
    if Value == true then
        ImageId = "rbxassetid://4458804262"
    end
    return Core.Roact.createElement("ImageButton", {
        Size = UDim2.fromScale(0.7, 0.7);
        Position = UDim2.fromScale(0.9, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        SizeConstraint = Enum.SizeConstraint.RelativeYY;

        BackgroundTransparency = 1;
        BorderSizePixel = 0;

        Image = ImageId;

        [Core.Roact.Event.MouseButton1Click] = function()
            Settings[SettingName] = not Settings[SettingName]
            local NewSettings = self.state.Settings
            NewSettings[SettingName] = Settings[SettingName]
            self:setState({Settings = NewSettings})
            PushToServer()
        end
    }, {})
end

function SettingsComponent:BooleanToggle(SettingName :string, DisplayName :string, Description :string)
    Objects += 1;
    return Core.Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.9, 0.15);
        Position = UDim2.fromScale(0.5, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Objects;
    }, {
        NameLabel = Core.Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.9, 0.6);

            BackgroundTransparency = 1;

            Text = DisplayName;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;

            FontFace = Core.UI.Theme.TextFont;
            TextColor3 = Core.UI.Theme.TextColor3;
        }, {}),

        DescriptionLabel = Core.Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.9, 0.4);
            Position = UDim2.fromScale(0, 0.6);

            BackgroundTransparency = 1;

            Text = Description;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;

            FontFace = Core.UI.Theme.TextFont;
            TextColor3 = Core.UI.Theme.TextColorDisabled;
        }, {}),

        Toggle = self:Checkbox(SettingName)
    })
end

function SettingsComponent:init()
    self:setState({
        IsSettingsVisible = false;
        Settings = Settings;
    })
end

function SettingsComponent:render()
    LogService:Log("Rendering settings GUI")
    return Core.Roact.createElement("ScreenGui", {}, {
        ToggleButton = Core.Roact.createElement("ImageButton", {
            Size = UDim2.fromScale(0.04, 0.08);
            Position = UDim2.fromScale(0.01, 0.98);
            AnchorPoint = Core.UI.AnchorPoint.BottomLeft;

            Image = "rbxassetid://88251609691626";
            BorderSizePixel = 0;

            BackgroundColor3 = Core.UI.Theme.BackgroundColor;
            BackgroundTransparency = Core.UI.Theme.BackgroundColorTransparency;

            [Core.Roact.Event.Activated] = function()
                self:setState({
                    IsSettingsVisible = not self.state.IsSettingsVisible
                })
            end
        }),

        SettingsPanel = self.state.IsSettingsVisible and Core.Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = UDim2.fromScale(0.5, 0.5);
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColor;
            BackgroundTransparency = Core.UI.Theme.BackgroundColorTransparency;
            BorderSizePixel = 0;
        }, {
            Title = Core.Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.15);

                BackgroundTransparency = 1;
                Text = "Settings";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;

                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            SettingsFrame = Core.Roact.createElement("ScrollingFrame", {
                Size = UDim2.fromScale(1, 0.85);
                Position = UDim2.fromScale(0.5, 0.575);
                AnchorPoint = Core.UI.AnchorPoint.Center;

                ScrollBarThickness = 5;
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollingDirection = Enum.ScrollingDirection.Y;

                BackgroundTransparency = 1;
                BorderSizePixel = 0;
            }, {
                Layout = Core.Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.01, 0);
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {}),

                GraphicsHeader = self:SettingsHeader("Graphics");
                GraphicsDescription = self:SettingsSubtitle("Adjust visual quality; Higher settings enhance detail but may impact performance on lower-end devices.");

                ShadowsToggle = self:BooleanToggle("GlobalShadows", "Shadows", "Toggle all shadows");
                RainbowToggle = self:BooleanToggle("RainbowEffect", "Rainbow effects", "Toggle all rainbow (RGB) effects and set them to white");

                ExperimentalHeader = self:SettingsHeader("Experimental");
                ExperimentalWarning = self:SettingsSubtitle("⚠️ THESE SETTINGS ARE EXPERIMENTAL AND CAN CAUSE ERRORS OR DATA LOSS; USE AT YOUR OWN RISK ⚠️");

                -- No settings here yet but there will be one for the custom map streamer thingy
                -- because I already know its going to cause a lot of issues
            })
        })
    })
end



--[[ KNIT ]]--

function SettingsController:KnitStart()
    LogService = Knit.GetService("LogService")
    SettingsService = Knit.GetService("SettingsService")
    DataService = Knit.GetService("DataService")

    DataService:GetPlayerDataFolder():andThen(function(PlayerData :Core.DataFolder)
        for _, SettingValue :ValueBase in pairs(PlayerData.Settings:GetChildren()) do
            Settings[SettingValue.Name] = SettingValue.Value

            SettingValue:GetPropertyChangedSignal("Value"):Connect(function()
                Settings[SettingValue.Name] = SettingValue.Value
                Update()
            end)
        end

        Update()
    end)

    local App = Core.Roact.createElement(SettingsComponent)
    Core.Roact.mount(App, Knit.Player.PlayerGui, "Settings")
    LogService:Log("Mounted settings component")
end

return SettingsController