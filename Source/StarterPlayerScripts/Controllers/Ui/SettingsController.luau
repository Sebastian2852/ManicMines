local ReplicatedStorage = game.ReplicatedStorage

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SettingsController = Knit.CreateController { Name = "PlayerSettingsController" }

local LogService
local SettingsService
local DataService
local UIService

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



-- [[ UI ]] --

local SettingsComponent = Roact.Component:extend("SettingsComponent")

local Objects = 0

function SettingsComponent:SettingsHeader(HeadingText :string)
    Objects += 1;
    return Roact.createElement("TextLabel", {
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
    return Roact.createElement("TextLabel", {
        Size = UDim2.fromScale(0.9, 0.1);
        Position = UDim2.fromScale(0.5, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Objects;

        Text = SubtitleText;
        TextScaled = true;
        RichText = true;

        FontFace = Core.UI.Theme.TextFont;
        TextColor3 = Core.UI.Theme.TextColorDisabled;
        TextYAlignment = Enum.TextYAlignment.Top;
    }, {})
end

function SettingsComponent:Checkbox(SettingName :string)
    local Value = Settings[SettingName]
    if Value == nil then
        LogService:Warn("Invalid setting name!")
        return
    end

    local ImageId = Core.UI.Images.CheckBoxUnchecked;
    if Value == true then
        ImageId = Core.UI.Images.CheckBoxChecked;
    end
    return Roact.createElement("ImageButton", {
        Size = UDim2.fromScale(0.7, 0.7);
        Position = UDim2.fromScale(0.9, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        SizeConstraint = Enum.SizeConstraint.RelativeYY;

        BackgroundTransparency = 1;
        BorderSizePixel = 0;

        Image = ImageId;

        [Roact.Event.MouseButton1Click] = function()
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
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.9, 0.15);
        Position = UDim2.fromScale(0.5, 0);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        LayoutOrder = Objects;
    }, {
        NameLabel = Roact.createElement("TextLabel", {
            Size = UDim2.fromScale(0.9, 0.6);

            BackgroundTransparency = 1;

            Text = DisplayName;
            TextScaled = true;
            TextXAlignment = Enum.TextXAlignment.Left;

            FontFace = Core.UI.Theme.TextFont;
            TextColor3 = Core.UI.Theme.TextColor3;
        }, {}),

        DescriptionLabel = Roact.createElement("TextLabel", {
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
        Hidden = false;
        IsSettingsVisible = false;
        Settings = Settings;
    })

    UIService.HUDButtons:Connect(function(New :boolean)
        self:setState({
            Hidden = not New;
        })
    end)
end

function SettingsComponent:render()
    LogService:Log("Rendering settings GUI")
    return Roact.createElement("ScreenGui", {
        ResetOnSpawn = false;
    }, {
        ToggleButton = not self.state.Hidden and Roact.createElement("ImageButton", {
            Size = UDim2.fromScale(0.04, 0.08);
            Position = UDim2.fromScale(0.01, 0.98);
            AnchorPoint = Core.UI.AnchorPoint.BottomLeft;

            Image = Core.UI.Images.SettingsButton;
            BorderSizePixel = 0;

            BackgroundTransparency = 1;

            [Roact.Event.Activated] = function()
                self:setState({
                    IsSettingsVisible = not self.state.IsSettingsVisible
                })
            end
        }, {
            AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
            }, {})
        }),

        SettingsPanel = self.state.IsSettingsVisible and Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 0.5);
            Position = Core.UI.Position.Center;
            AnchorPoint = Core.UI.AnchorPoint.Center;

            BackgroundColor3 = Core.UI.Theme.BackgroundColorPrimary;
            BorderSizePixel = 0;
        }, {
            Title = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.15);

                BackgroundTransparency = 1;
                Text = "Settings";
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Left;

                TextColor3 = Core.UI.Theme.TextColor3;
                FontFace = Core.UI.Theme.TextFont;
            }, {});

            SettingsFrame = Roact.createElement("ScrollingFrame", {
                Size = UDim2.fromScale(1, 0.85);
                Position = UDim2.fromScale(0.5, 0.575);
                AnchorPoint = Core.UI.AnchorPoint.Center;
                BackgroundTransparency = 1;
                BorderSizePixel = 0;

                ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255);
                ScrollBarThickness = 5;
                VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right;
                VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar;
                AutomaticCanvasSize = Enum.AutomaticSize.Y;
                ScrollingDirection = Enum.ScrollingDirection.Y;
                CanvasSize = UDim2.fromScale(1, 1);
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.01, 0);
                    HorizontalAlignment = Enum.HorizontalAlignment.Center;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                }, {}),

                GraphicsHeader = self:SettingsHeader("Graphics");
                GraphicsDescription = self:SettingsSubtitle("Adjust visual quality; Higher settings enhance detail but may impact performance on lower-end devices.");

                ShadowsToggle = self:BooleanToggle("GlobalShadows", "Shadows", "Toggle all shadows");
                RainbowToggle = self:BooleanToggle("RainbowEffect", "Rainbow effects", "Toggle all rainbow (RGB) effects and set them to white");

                ExperimentalHeader = self:SettingsHeader("Experimental");
                ExperimentalWarning = self:SettingsSubtitle("⚠️ THESE SETTINGS ARE EXPERIMENTAL AND <font color='#fc9905'>CAN CAUSE ERRORS OR DATA LOSS</font>; USE AT YOUR OWN RISK ⚠️");

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
    UIService = Knit.GetService("UIService")

    DataService.DataLoaded:Connect(function(DataFolder :Core.DataFolder)
        for _, SettingValue :ValueBase in pairs(DataFolder.Settings:GetChildren()) do
            Settings[SettingValue.Name] = SettingValue.Value

            SettingValue:GetPropertyChangedSignal("Value"):Connect(function()
                Settings[SettingValue.Name] = SettingValue.Value
                Update()
            end)
        end

        Update()

        local App = Roact.createElement(SettingsComponent)
        Roact.mount(App, Knit.Player.PlayerGui, "Settings")
        LogService:Log("Mounted settings component")
    end)
end

return SettingsController