local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Roact = require(ReplicatedStorage.Packages.Roact)

local AddRoundedCorners = require(ReplicatedStorage.Game.GUI.Elements.Corners)

local InventoryOreFrame = Roact.Component:extend("InventoryOreFrame")

function InventoryOreFrame:render()
    local StorageService = Knit.GetService("StorageService")

    local Ore = self.props.Ore :: BasePart
    local Amount = self.props.Amount :: number

    local Gradient = Ore:GetAttribute("InventoryBackgroundColor")
    local Icon = Ore:GetAttribute("EmblemImageID")
    local Name = Ore:GetAttribute("DisplayName")

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.15);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        Gradient = Roact.createElement("UIGradient", {
            Color = Gradient;
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

            Image = Icon;
            ScaleType = Enum.ScaleType.Fit;
        }, {
            AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
                AspectType = Enum.AspectType.ScaleWithParentSize;
                DominantAxis = Enum.DominantAxis.Height;
            }, {})
        });

        Details = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 1);
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

                Text = Name or "error getting name";
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Bottom;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            OreAmount = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.4);
                BackgroundTransparency = 1;

                Text = Amount or "error getting amount";
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Left;
                TextYAlignment = Enum.TextYAlignment.Top;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});
        });

        Interaction = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.4, 1);
            BackgroundTransparency = 1;
            LayoutOrder = 3;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0.05, 0);
                SortOrder = Enum.SortOrder.LayoutOrder;
                Wraps = false;
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Left;
                VerticalAlignment = Enum.VerticalAlignment.Center;
            }, {});

            TextBox = Roact.createElement("TextBox", {
                Size = UDim2.fromScale(0.5, 0.5);
                BackgroundColor3 = Core.UI.Theme.BackgroundColorLight;
                BorderSizePixel = 0;

                Text = "";
                PlaceholderText = "...";
                FontFace = Core.UI.Theme.TextFont;
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Center;
                TextColor3 = Core.UI.Theme.TextColor3;

                [Roact.Event.FocusLost] = function(Object :TextBox)
                    local EnteredAmount = tonumber(Object.Text)
                    Object.Text = ""
                    if type(EnteredAmount) ~= "number" then return end

                    local RoundedAmount = math.floor(EnteredAmount)
                    local ClamppedAmount = math.clamp(RoundedAmount, 0, Amount)
                    StorageService:MoveToStorage(Ore.Name, ClamppedAmount)
                end
            }, {});

            AllButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.5);
                BackgroundColor3 = Core.UI.Theme.OpenButtonColor;
                BorderSizePixel = 0;

                Text = "All";
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;
                TextColor3 = Core.UI.Theme.TextColor3;

                [Roact.Event.MouseButton1Click] = function()
                    StorageService:MoveToStorage(Ore.Name, Amount)
                end;
            }, {
                Corners = AddRoundedCorners(0.2);
            });
        })
    })
end


local StorageOreFrame = Roact.Component:extend("StorageOreFrame")

function StorageOreFrame:render()
    local StorageService = Knit.GetService("StorageService")

    local Ore = self.props.Ore :: BasePart
    local Amount = self.props.Amount :: number

    local Gradient = Ore:GetAttribute("InventoryBackgroundColor")
    local Icon = Ore:GetAttribute("EmblemImageID")
    local Name = Ore:GetAttribute("DisplayName")

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 0.15);
        AnchorPoint = Vector2.new(0.5, 0.5);

        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        Gradient = Roact.createElement("UIGradient", {
            Color = Gradient;
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
            LayoutOrder = 3;

            Image = Icon;
            ScaleType = Enum.ScaleType.Fit;
        }, {
            AspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                AspectRatio = 1;
                AspectType = Enum.AspectType.ScaleWithParentSize;
                DominantAxis = Enum.DominantAxis.Height;
            }, {})
        });

        Details = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.5, 1);
            BackgroundTransparency = 1;
            LayoutOrder = 2;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder;
                Wraps = false;
                FillDirection = Enum.FillDirection.Vertical;

                HorizontalFlex = Enum.UIFlexAlignment.None;
                VerticalFlex = Enum.UIFlexAlignment.None;

                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
                VerticalAlignment = Enum.VerticalAlignment.Top;
            }, {});

            OreName = Roact.createElement("TextLabel", {
                BackgroundTransparency = 1;
                Size = UDim2.fromScale(1, 0.6);

                Text = Name or "error getting name";
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Right;
                TextYAlignment = Enum.TextYAlignment.Bottom;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});

            OreAmount = Roact.createElement("TextLabel", {
                Size = UDim2.fromScale(1, 0.4);
                BackgroundTransparency = 1;

                Text = Amount or "error getting amount";
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;

                TextXAlignment = Enum.TextXAlignment.Right;
                TextYAlignment = Enum.TextYAlignment.Top;

                TextColor3 = Core.UI.Theme.TextColor3;
            }, {});
        });

        Interaction = Roact.createElement("Frame", {
            Size = UDim2.fromScale(0.4, 1);
            BackgroundTransparency = 1;
            LayoutOrder = 1;
        }, {
            Layout = Roact.createElement("UIListLayout", {
                Padding = UDim.new(0.05, 0);
                SortOrder = Enum.SortOrder.LayoutOrder;
                Wraps = false;
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                VerticalAlignment = Enum.VerticalAlignment.Center;
            }, {});

            TextBox = Roact.createElement("TextBox", {
                Size = UDim2.fromScale(0.5, 0.5);
                BackgroundColor3 = Core.UI.Theme.BackgroundColorLight;
                BorderSizePixel = 0;
                LayoutOrder = 2;

                Text = "";
                PlaceholderText = "...";
                FontFace = Core.UI.Theme.TextFont;
                TextScaled = true;
                TextXAlignment = Enum.TextXAlignment.Center;
                TextColor3 = Core.UI.Theme.TextColor3;

                [Roact.Event.FocusLost] = function(Object :TextBox)
                    local EnteredAmount = tonumber(Object.Text)
                    Object.Text = ""
                    if type(EnteredAmount) ~= "number" then return end

                    local RoundedAmount = math.floor(EnteredAmount)
                    local ClamppedAmount = math.clamp(RoundedAmount, 0, Amount)
                    StorageService:MoveToInventory(Ore.Name, ClamppedAmount)
                end
            }, {});

            AllButton = Roact.createElement("TextButton", {
                Size = UDim2.fromScale(0.3, 0.5);
                BackgroundColor3 = Core.UI.Theme.OpenButtonColor;
                BorderSizePixel = 0;
                LayoutOrder = 1;

                Text = "All";
                FontFace = Core.UI.Theme.TextFont;
                TextStrokeTransparency = 0;
                TextScaled = true;
                TextColor3 = Core.UI.Theme.TextColor3;

                [Roact.Event.MouseButton1Click] = function()
                    StorageService:MoveToInventory(Ore.Name, Amount)
                end;
            }, {
                Corners = AddRoundedCorners(0.2);
            });
        })
    })
end

return function(Type :Enums.Enum, OreName :string, Amount :number) :Roact.Element
    local Ore = Core.Util:GetOreByName(OreName)
    if not Ore then
        warn("No ore with name: "..tostring(OreName).."; using stone instead")
    end

    if Type == Enums.StorageOreFrameType.Inventory then
        return Roact.createElement(InventoryOreFrame, {Amount = Amount, Ore = Ore ~= nil and Ore or Core.Assets.Stone})
    elseif Type == Enums.StorageOreFrameType.Storage then
        return Roact.createElement(StorageOreFrame, {Amount = Amount, Ore = Ore ~= nil and Ore or Core.Assets.Stone})
    end
end