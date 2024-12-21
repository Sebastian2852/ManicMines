local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local SlotSelector = Roact.Component:extend("SlotSelector")

local Theme = require(script.Parent.Parent.Theme)
local CloseButton = require(ReplicatedStorage.Game.GUI.Common.CloseButton)
local UsedSlotFrame = require(script.UsedSlotFrame)
local UnUsedSlotFrame = require(script.UnUsedSlotFrame)
local LoadingSlots = require(script.LoadingSlots)

local DataService

function SlotSelector:init()
    DataService = Knit.GetService("DataService")

    self.Motor = Flipper.SingleMotor.new(0)
    local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
    self.Binding = Binding
    self.Motor:onStep(SetBinding)
end

function SlotSelector:UpdateSlots()
    self:setState({
        SlotInfo = nil;
    })

    task.wait(0.5)

    DataService:GetSlotsInfo():andThen(function(SlotsInfo)
        self:setState({
            SlotInfo = SlotsInfo
        })
    end)
end

function SlotSelector:didMount()
    DataService:GetSlotsInfo():andThen(function(SlotsInfo)
        self:setState({
            SlotInfo = SlotsInfo
        })
    end)

    self.Motor:setGoal(Flipper.Spring.new(1, {
        frequency = 5,
        dampingRatio = 1
    }))
end

function SlotSelector:render()
    local SlotInfo = self.state.SlotInfo

    local SlotFrames = {}

    if SlotInfo then
        SlotFrames["Layout"] = Roact.createElement("UIListLayout", {
            SortOrder = Enum.SortOrder.Name;
        })

        for ID :number, Slot :Core.SlotInfo in pairs(SlotInfo) do
            if Slot.Used then
                SlotFrames[ID] = Roact.createElement(UsedSlotFrame, {
                    SlotInfo = Slot;
                    OnSlotDelete = function()
                        self:UpdateSlots()
                    end;
                })
            else
                SlotFrames[ID] = Roact.createElement(UnUsedSlotFrame, {
                    SlotInfo = Slot;
                })
            end
        end
    end

    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(1, 1);
        Position = self.Binding:map(function(Value)
            return UDim2.fromScale(0, -1.5):lerp(UDim2.fromScale(0, 0), Value)
        end);
        BackgroundColor3 = Theme.BackgroundColor;
        BackgroundTransparency = 0.5;
        BorderSizePixel = 0;
    }, {
        CloseButton = Roact.createElement(CloseButton, {
            OnClick = function()
                self.Motor:setGoal(Flipper.Spring.new(0, {
                    frequency = 5,
                    dampingRatio = 1
                }))

                task.wait(0.2)

                self.props.OnClick()
            end
        });

        Slots = Roact.createElement("Frame", {
            Size = UDim2.fromScale(1, 0.9);
            Position = UDim2.fromScale(0, 0.15);
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
        }, SlotInfo and SlotFrames or { Roact.createElement(LoadingSlots); });
    })
end

return SlotSelector