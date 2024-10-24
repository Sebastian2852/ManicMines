-- This module describes how UI should look by default, as well as functions for creating common components. Having it all in this one module
-- will make it easier to edit all the ui at once.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UI = {}

local Roact = require(ReplicatedStorage.Packages.Roact)
local EnumList = require(ReplicatedStorage.Packages.EnumList)
local OreListClass = require(ReplicatedStorage.Game.Modules.Classes.OreList)

UI.Theme = {
    BackgroundColor = Color3.new(0, 0, 0);
    BackgroundColorTransparency = 0.5;

    TextColor3 = Color3.new(1, 1, 1);
    TextFont = Font.fromEnum(Enum.Font.Highway);
    TextStrokeTransparency = 0;

    TextColorDisabled = Color3.new(0.278431, 0.278431, 0.278431);
}

--[=[
A set of preset anchor points
]=]
UI.AnchorPoint = {
    TopLeft         = Vector2.new(0, 0);
    TopRight        = Vector2.new(1, 0);

    BottomLeft      = Vector2.new(0, 1);
    BottomRight     = Vector2.new(1, 1);

    Center          = Vector2.new(0.5, 0.5);
    TopCenter       = Vector2.new(0.5, 0);
    BottomCenter    = Vector2.new(0.5, 1);
}

--[=[
A set of preset positions
]=]
UI.Position = {
    TopLeft         = UDim2.fromScale(0, 0);
    TopRight        = UDim2.fromScale(1, 0);

    Bottomleft      = UDim2.fromScale(0, 1);
    BottomRight     = UDim2.fromScale(1, 1);

    Center          = UDim2.fromScale(0.5, 0.5);
    TopCenter       = UDim2.fromScale(0.5, 0);
    BottomCenter    = UDim2.fromScale(0.5, 1);
}

--[=[
Color presets
]=]
UI.Color = {
    Blue       = Color3.fromRGB(0, 123, 255);
    Red        = Color3.fromRGB(220, 53, 69);
    Green      = Color3.fromRGB(40, 267, 69);
    Yellow     = Color3.fromRGB(255, 193, 64);
    Orange     = Color3.fromRGB(255, 159, 64);
    Purple     = Color3.fromRGB(102, 16, 242);
    Pink       = Color3.fromRGB(232, 62, 140);
    Teal       = Color3.fromRGB(32, 201, 151);
    Cyan       = Color3.fromRGB(23, 162, 184);
    Gray       = Color3.fromRGB(108, 117, 125);
    Black      = Color3.fromRGB(0, 0, 0);
    White      = Color3.fromRGB(255, 255, 255);
    Brown      = Color3.fromRGB(121, 85, 72);
    Indigo     = Color3.fromRGB(75, 0, 130);
    Lime       = Color3.fromRGB(50, 205, 50);
}

UI.OreFrameStyle = EnumList.new("OreFrameStyle", {
    "PcInventory";
    "Normal";
})

--[=[
Create a single ore frame from an ore list. This only creates a frame for the first thing in the ore list
]=]
function UI:CreateOreFrame(OreList, Style :EnumList.EnumItem, Size :UDim2, Position :UDim2) -- Maybe add an "include gold" param
    for OreName :string, OreData in pairs(OreList:LoopList()) do
        if OreData.Amount == 0 then continue end
        if OreName == "Gold" then
            warn("Gold is not supported in ore frames!!!")
            continue
        end

        if not UI.OreFrameStyle:BelongsTo(Style) then
            warn("Invalid ore frame style passed: "..tostring(Style))
            return {}
        end

        if Style.Value == 1 then
            return Roact.createElement("Frame", {
                Size = Size;
                Position = Position;
                AnchorPoint = Vector2.new(0.5, 0.5);

                BackgroundTransparency = 0.5; -- Maybe make this a param since it can depend on the UI how transparent it should be
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = OreData.RealOre:GetAttribute("InventoryBackgroundColor");
                }, {});

                Layout = Roact.createElement("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Wraps = false;
                    Padding = UDim.new(0.01, 0);

                    HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    VerticalAlignment = Enum.VerticalAlignment.Center;
                    ItemLineAlignment = Enum.ItemLineAlignment.Center;

                    VerticalFlex = Enum.UIFlexAlignment.None;
                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                }, {});

                OreImage = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(0.1, 1);
                    BackgroundTransparency = 1;
                    LayoutOrder = 1;

                    Image = OreData.Emblem;
                    ScaleType = Enum.ScaleType.Fit;
                }, {
                    AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1;
                        AspectType = Enum.AspectType.ScaleWithParentSize;
                        DominantAxis = Enum.DominantAxis.Height;
                    }, {})
                });

                Details = Roact.createElement("Frame", {
                    Size = UDim2.fromScale(1, 1);
                    BackgroundTransparency = 1;
                    LayoutOrder = 2;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        Wraps = false;
                        FillDirection = Enum.FillDirection.Vertical;

                        HorizontalFlex = Enum.UIFlexAlignment.None;
                        VerticalFlex = Enum.UIFlexAlignment.None;

                        HorizontalAlignment = Enum.HorizontalAlignment.Left;
                        ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                        VerticalAlignment = Enum.VerticalAlignment.Top;
                    }, {});

                    OreName = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1;
                        Size = UDim2.fromScale(1, 0.6);

                        Text = OreName or "error getting name";
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Bottom;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});

                    OreAmount = Roact.createElement("TextLabel", {
                        Size = UDim2.fromScale(1, 0.4);
                        BackgroundTransparency = 1;

                        Text = tostring(OreData.Amount) or "error getting amount";
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Left;
                        TextYAlignment = Enum.TextYAlignment.Top;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});
                })
            })
        else -- No other styles so its fine to assume anything else means the normal style
            return Roact.createElement("Frame", {
                Size = Size;
                Position = Position;
                AnchorPoint = Vector2.new(0.5, 0.5);

                BackgroundTransparency = 0.5; -- Maybe make this a param since it can depend on the UI how transparent it should be
                BorderSizePixel = 0;
            }, {
                Gradient = Roact.createElement("UIGradient", {
                    Color = OreData.RealOre:GetAttribute("InventoryBackgroundColor");
                }, {});

                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0.01, 0);
                    FillDirection = Enum.FillDirection.Horizontal;
                    SortOrder = Enum.SortOrder.LayoutOrder;

                    HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                    VerticalAlignment = Enum.VerticalAlignment.Center;

                    HorizontalFlex = Enum.UIFlexAlignment.Fill;
                    VerticalFlex = Enum.UIFlexAlignment.None;
                }, {});

                OreImage = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(0.1, 1);
                    BackgroundTransparency = 1;
                    LayoutOrder = 1;

                    Image = OreData.Emblem;
                    ScaleType = Enum.ScaleType.Fit;
                }, {
                    AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                        AspectRatio = 1;
                        AspectType = Enum.AspectType.ScaleWithParentSize;
                        DominantAxis = Enum.DominantAxis.Height;
                    }, {})
                });

                Details = Roact.createElement("Frame", {
                    BackgroundTransparency = 1;
                    Size = UDim2.fromScale(1, 1);
                    LayoutOrder = 2;
                }, {
                    Layout = Roact.createElement("UIListLayout", {
                        Padding = UDim.new(0, 0);
                        FillDirection = Enum.FillDirection.Horizontal;
                        SortOrder = Enum.SortOrder.LayoutOrder;

                        HorizontalAlignment = Enum.HorizontalAlignment.Center;
                        ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                        VerticalAlignment = Enum.VerticalAlignment.Center;

                        HorizontalFlex = Enum.UIFlexAlignment.Fill;
                        VerticalFlex = Enum.UIFlexAlignment.Fill;
                    }, {});

                    OreName = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1;
                        Size = UDim2.fromScale(0.6, 1);
                        LayoutOrder = 1;

                        Text = OreName or "error getting name";
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Left;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});

                    OreAmount = Roact.createElement("TextLabel", {
                        BackgroundTransparency = 1;
                        Size = UDim2.fromScale(0.22, 1);
                        LayoutOrder = 2;

                        Text = tostring(OreData.Amount) or "error getting amount";
                        FontFace = UI.Theme.TextFont;
                        TextStrokeTransparency = 0;
                        TextScaled = true;

                        TextXAlignment = Enum.TextXAlignment.Right;

                        TextColor3 = UI.Theme.TextColor3;
                    }, {});
                })
            })
        end
    end
end

--[=[
Returns a table of Ore frames as components in a table.
]=]
function UI:CreateOreFrames(OreList, Style :EnumList.EnumItem, Size :UDim2) :{Roact.Component}
    if not OreListClass.IsOreList(OreList) then
        warn("Invalid ore list passed:", OreList)
        return {}
    end

    local Frames = {}

    for OreName, OreData in pairs(OreList:LoopList()) do
        if OreData.Amount == nil then
            warn("Can not process orelist with nil ore amount!")
            continue
        end
        if OreData.Amount == 0 then continue end
        if OreName == "Gold" then
            warn("Gold is not supported in ore frames!!!")
            continue
        end

        local NewList = OreListClass.New()
        if OreName == "Gold" then
            NewList:AddGold(OreData.Amount)
            Frames[OreName] = self:CreateOreFrame(NewList, Style, Size, UDim2.fromScale(0, 0))
            NewList:Destroy()
            continue
        end

        NewList:AddOre(OreName, OreData.Amount)
        Frames[OreName] = self:CreateOreFrame(NewList, Style, Size, UDim2.fromScale(0, 0))
        NewList:Destroy()
        continue
    end

    return Frames
end

return UI