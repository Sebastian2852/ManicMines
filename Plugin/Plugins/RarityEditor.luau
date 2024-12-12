local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RarityEditor = {}

local Widget = nil

local function WeightToRarity(Weight :number, Total :number)
    return math.floor(Total / Weight)
end

local function RarityToWeight(Rarity :number, TotalWeight :number)
    return math.floor(TotalWeight / Rarity)
end

local function AddCorners(Object :Instance, Radius :number)
    local New = Instance.new("UICorner")
    New.CornerRadius = UDim.new(Radius, 0)
    New.Parent = Object
    return New
end

function RarityEditor:Gui()
    local Gui = Instance.new("Frame")
    Gui.Size = UDim2.fromScale(1, 1)
    Gui.BackgroundTransparency = 1

    local Ores :{BasePart} = ReplicatedStorage.Assets.Ores:GetChildren()
    local Rarities = {}
    local TotalWeight = 0

    for _, _ in pairs(Ores) do
        TotalWeight += 100000000000000000
    end

    local TopStuff = Instance.new("Frame")
    TopStuff.Size = UDim2.fromScale(1, 0.1)
    TopStuff.BackgroundTransparency = 1

    local CommitButton = Instance.new("TextButton")
    CommitButton.Size = UDim2.fromScale(0.3, 0.5)
    CommitButton.Position = UDim2.fromScale(1, 1)
    CommitButton.AnchorPoint = Vector2.new(1, 1)
    CommitButton.BackgroundColor3 = Color3.fromRGB(217, 86, 83)
    CommitButton.Text = "Commit"
    CommitButton.TextColor3 = Color3.new(1, 1, 1)
    CommitButton.TextScaled = true
    AddCorners(CommitButton, 0.2)

    CommitButton.MouseButton1Click:Connect(function()
        for _, Ore in pairs(Ores) do
            Ore:SetAttribute("Rarity", Rarities[Ore.Name].Weight)
        end
        ChangeHistoryService:SetWaypoint("Ore weight commit")
    end)

    CommitButton.Parent = TopStuff

    TopStuff.Parent = Gui

    local OreGuiContainer = Instance.new("ScrollingFrame")
    OreGuiContainer.Parent = Gui
    OreGuiContainer.Size = UDim2.fromScale(1, 0.9)
    OreGuiContainer.Position = UDim2.fromScale(0, 0.1)
    OreGuiContainer.ScrollBarThickness = 3
    OreGuiContainer.BackgroundTransparency = 1
    OreGuiContainer.BorderSizePixel = 0
    OreGuiContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    OreGuiContainer.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left
    OreGuiContainer.VerticalScrollBarInset = Enum.ScrollBarInset.Always

    local Layout = Instance.new("UIListLayout")
    Layout.Parent = OreGuiContainer

    for _, Ore in pairs(Ores) do
        local OreInfo = {}
        OreInfo.Weight = Ore:GetAttribute("Rarity")
        OreInfo.OldRarity = WeightToRarity(Ore:GetAttribute("Rarity"), TotalWeight)
        Rarities[Ore.Name] = OreInfo

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.fromScale(1, 0.1)
        Frame.Name = Ore.Name
        Frame.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
        Frame.BorderSizePixel = 0

        local DisplayNameLabel = Instance.new("TextLabel")
        DisplayNameLabel.Size = UDim2.fromScale(0.5, 0.5)
        DisplayNameLabel.Text = Ore:GetAttribute("DisplayName")
        DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        DisplayNameLabel.BackgroundTransparency = 1
        DisplayNameLabel.BorderSizePixel = 0
        DisplayNameLabel.TextScaled = true
        DisplayNameLabel.TextYAlignment = Enum.TextYAlignment.Bottom
        DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        DisplayNameLabel.Parent = Frame

        local RealNameLabel = Instance.new("TextLabel")
        RealNameLabel.Size = UDim2.fromScale(0.5, 0.4)
        RealNameLabel.Position = UDim2.fromScale(0, 0.5)
        RealNameLabel.BackgroundTransparency = 1
        RealNameLabel.BorderSizePixel = 0
        RealNameLabel.Text = Ore.Name
        RealNameLabel.TextColor3 = Color3.fromRGB(155, 155, 155)
        RealNameLabel.TextScaled = true
        RealNameLabel.TextYAlignment = Enum.TextYAlignment.Top
        RealNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        RealNameLabel.Parent = Frame

        local RightSide = Instance.new("Frame")
        RightSide.Size = UDim2.fromScale(0.5, 0.9)
        RightSide.Position = UDim2.fromScale(1, 0)
        RightSide.AnchorPoint = Vector2.new(1, 0)
        RightSide.BackgroundTransparency = 1
        RightSide.BorderSizePixel = 0

        local Info = Instance.new("TextLabel")
        Info.Size = UDim2.fromScale(0.5, 0.3)
        Info.Position = UDim2.fromScale(0, 1)
        Info.AnchorPoint = Vector2.new(0, 1)
        Info.BackgroundTransparency = 1
        Info.Text = "1 /  "
        Info.TextScaled = true
        Info.TextColor3 = Color3.fromRGB(155, 155, 155)
        Info.TextXAlignment = Enum.TextXAlignment.Right
        Info.TextYAlignment = Enum.TextYAlignment.Bottom
        Info.Parent = RightSide

        local Input = Instance.new("TextBox")
        Input.Size = UDim2.fromScale(0.5, 0.5)
        Input.Position = UDim2.fromScale(1, 0.5)
        Input.AnchorPoint = Vector2.new(1, 0)
        Input.BorderSizePixel = 0
        Input.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
        Input.TextXAlignment = Enum.TextXAlignment.Left
        Input.TextScaled = true
        Input.PlaceholderColor3 = Color3.fromRGB(155, 155, 155)
        Input.TextColor3 = Color3.new(1, 1, 1)
        Input.PlaceholderText = "..."
        Input.Text = OreInfo.OldRarity

        local WeightInfo = Instance.new("TextLabel")
        WeightInfo.Size = UDim2.fromScale(1, 0.5)
        WeightInfo.Position = UDim2.fromScale(0, -0.5)
        WeightInfo.BorderSizePixel = 0
        WeightInfo.BackgroundTransparency = 1
        WeightInfo.Text = "Weight: "..RarityToWeight(tonumber(Input.Text), TotalWeight)
        WeightInfo.TextColor3 = Color3.fromRGB(155, 155, 155)
        WeightInfo.TextScaled = true
        WeightInfo.Parent = Input

        Input.FocusLost:Connect(function()
            local Weight = RarityToWeight(tonumber(Input.Text), TotalWeight)

            WeightInfo.Text = "Weight: "..Weight
            OreInfo.OldRarity = tonumber(Input.Text)
            OreInfo.Weight = Weight
            Rarities[Ore.Name] = OreInfo
        end)

        Input.Parent = RightSide

        RightSide.Parent = Frame
        Frame.Parent = OreGuiContainer
    end

    Gui.Parent = Widget
end

function RarityEditor:ClearGui()
    Widget:ClearAllChildren()
end

function RarityEditor:CreatePluginButton(plugin, Toolbar :PluginToolbar) :PluginToolbarButton
    local MyButton = Toolbar:CreateButton("Rarity Editor", "Edit rarity of all ores at once!", "rbxassetid://74012825822948")
    local DockWidgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Left, false, false, 300, 800, 250, 750)
    local PluginWidget = plugin:CreateDockWidgetPluginGui("RarityEditor", DockWidgetInfo)
    PluginWidget.Title = "Manic Mines: Rarity Editor"
    Widget = PluginWidget

    MyButton.Click:Connect(function()
        self:ClearGui()
        Widget.Enabled = not Widget.Enabled
        if Widget.Enabled then
            self:Gui()
        end
    end)

    return MyButton
end

return RarityEditor