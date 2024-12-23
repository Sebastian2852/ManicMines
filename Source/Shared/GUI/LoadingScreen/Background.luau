local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Background = Roact.Component:extend("Background")

local Theme = require(script.Parent.Parent.Theme)

function Background:UpdateImagePosition()
    if not UserInputService.MouseEnabled then return end

    local MousePosition = UserInputService:GetMouseLocation()
    local ScreenSize = workspace.CurrentCamera.ViewportSize
    local MaxOffset = 200

    local XOffset = (MousePosition.X - ScreenSize.X / 2) / ScreenSize.X * MaxOffset
    local YOffset = (MousePosition.Y - ScreenSize.Y / 2) / ScreenSize.Y * MaxOffset

    self:setState({
        Offset = Vector2.new(-XOffset, -YOffset)
    })
end

function Background:init()
    local Mouse = Players.LocalPlayer:GetMouse()

    self.MouseConnection = Mouse.Move:Connect(function()
        self:UpdateImagePosition()
    end)
end

function Background:willUnmount()
    if self.MouseConnection then
        self.MouseConnection:Disconnect()
    end
end

function Background:render()
    local Offset = self.state.Offset or Vector2.zero
    local Transparency = self.props.Transparency or 0
    local Image = self.props.Image or Theme.Images.Missing

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        Position = UDim2.fromScale(0.5, 0.5);
        AnchorPoint = Vector2.new(0.5, 0.5);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Image = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(1.5, 1.5);
            Position = UDim2.new(0.5, Offset.X, 0.5, Offset.Y);
            AnchorPoint = Vector2.new(0.5, 0.5);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;

            Image = Image;
            ImageTransparency = Transparency;
            ScaleType = Enum.ScaleType.Crop;
        }, {});
    });
end

return Background