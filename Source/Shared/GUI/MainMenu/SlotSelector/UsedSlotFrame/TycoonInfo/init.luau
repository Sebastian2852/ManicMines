local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SlotInfo = Roact.PureComponent:extend("SlotInfo")

local AnimatedLabel = require(script.AnimatedLabel)

function SlotInfo:render()
    local Gold = self.props.Gold or 0
    local LastPlayed = self.props.LastPlayed or 0

    local TimeNow = os.time()
    local TimeDiff = TimeNow - LastPlayed
    local TimeText = Core.Util:TimeAgo(TimeDiff)

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
    }, {
        Layout = Roact.createElement("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Left;
            VerticalAlignment = Enum.VerticalAlignment.Center;
            SortOrder = Enum.SortOrder.LayoutOrder;
        }, {});

        Gold = Roact.createElement(AnimatedLabel, {
            LayoutOrder = 1;
            Text = "Gold: "..Gold;
        }, {});

        LastPlayed = Roact.createElement(AnimatedLabel, {
            LayoutOrder = 2;
            Text = "Last played: "..TimeText;
        }, {});
    })
end

return SlotInfo