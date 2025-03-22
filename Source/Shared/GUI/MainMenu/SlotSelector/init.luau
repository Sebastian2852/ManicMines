local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local SlotSelector = Roact.Component:extend("SlotSelector")

local CloseButton = require(ReplicatedStorage.Game.GUI.Common.CloseButton)
local Creator = require(script.SlotCreator)
local LoadingSlots = require(script.LoadingSlots)
local Theme = require(script.Parent.Parent.Theme)
local UnUsedSlotFrame = require(script.UnUsedSlotFrame)
local UsedSlotFrame = require(script.UsedSlotFrame)

local DataService

function SlotSelector:init()
	DataService = Knit.GetService("DataService")

	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)

	self:setState({
		ShowCreator = false,
		CreatorSlotID = 0,
		SlotFrames = { Roact.createElement(LoadingSlots) },
	})
end

function SlotSelector:CreateSlotFrames(SlotInfo)
	local SlotFrames = {}
	SlotFrames["Layout"] = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
	})

	for ID: number, Slot: Core.SlotInfo in pairs(SlotInfo) do
		if Slot.Used then
			SlotFrames[ID] = Roact.createElement(UsedSlotFrame, {
				SlotInfo = Slot,
				OnSlotDelete = function()
					self:setState({
						SlotFrames = { Roact.createElement(LoadingSlots) },
					})
					DataService:DeleteSlot(ID):andThen(function()
						DataService:GetSlotsInfo():andThen(function(SlotsInfo)
							self:CreateSlotFrames(SlotsInfo)
						end)
					end)
				end,
			})
		else
			SlotFrames[ID] = Roact.createElement(UnUsedSlotFrame, {
				SlotInfo = Slot,
				OnCreate = function()
					self:setState({
						ShowCreator = true,
						CreatorSlotID = ID,
					})
				end,
			})
		end
	end

	self:setState({
		SlotFrames = SlotFrames,
	})
end

function SlotSelector:didMount()
	DataService:GetSlotsInfo():andThen(function(SlotsInfo)
		self:CreateSlotFrames(SlotsInfo)
	end)

	self.Motor:setGoal(Flipper.Spring.new(1, {
		frequency = 5,
		dampingRatio = 1,
	}))
end

function SlotSelector:render()
	local SlotFrames = self.state.SlotFrames
	local ShowCreator = self.state.ShowCreator
	local CreatorSlotID = self.state.CreatorSlotID

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = self.Binding:map(function(Value)
			return UDim2.fromScale(0, -1.5):Lerp(UDim2.fromScale(0, 0), Value)
		end),
		BackgroundColor3 = Theme.BackgroundColor,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, {
		CloseButton = not ShowCreator and Roact.createElement(CloseButton, {
			OnClick = function()
				self.Motor:setGoal(Flipper.Spring.new(0, {
					frequency = 5,
					dampingRatio = 1,
				}))

				task.wait(0.2)

				self.props.OnClick()
			end,
		}),

		Container = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Slots = not ShowCreator and Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.15),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, SlotFrames),

			Creator = ShowCreator and Roact.createElement(Creator, {
				SlotID = CreatorSlotID,
				OnClose = function()
					self:setState({
						ShowCreator = false,
					})
				end,
			}, {}),
		}),
	})
end

return SlotSelector
