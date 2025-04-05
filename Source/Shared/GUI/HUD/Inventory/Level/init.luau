local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Flipper = require(ReplicatedStorage.Packages.Flipper)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local LevelDisplay = Roact.Component:extend("LevelDisplay")

local Theme = require(script.Parent.Parent.Parent.Theme)
local XpDiff = require(script.XpDiff)

local function Lerp(Start: number, End: number, Time: number)
	return Start * (1 - Time) + End * Time
end

function LevelDisplay:init()
	local DataService = Knit.GetService("DataService")

	self.Motor = Flipper.SingleMotor.new(0)
	local Binding, SetBinding = Roact.createBinding(self.Motor:getValue())
	self.Binding = Binding
	self.Motor:onStep(SetBinding)

	self.TextMotor = Flipper.SingleMotor.new(0)
	local TextBinding, TextSetBinding = Roact.createBinding(self.Motor:getValue())
	self.TextBinding = TextBinding
	self.TextMotor:onStep(TextSetBinding)

	self:setState({
		XpChange = 0,
		ShowChange = false,
	})

	DataService:GetPlayerDataFolder():andThen(function(DataFolder: Core.DataFolder)
		local Xp = DataFolder.XP
		local Level = DataFolder.Level
		local UseShortUnits = DataFolder.Settings.InventoryShortUnits

		self.XpConnection = Xp:GetPropertyChangedSignal("Value"):Connect(function()
			self:UpdateXp(Xp.Value)
		end)

		self.LevelConnection = Level:GetPropertyChangedSignal("Value"):Connect(function()
			self:UpdateLevel(Level.Value)
		end)

		self.ShortUnitsConnection = UseShortUnits:GetPropertyChangedSignal("Value"):Connect(function()
			self:setState({
				ShortUnits = UseShortUnits.Value,
			})
		end)

		self:setState({
			ShortUnits = UseShortUnits.Value,
		})

		self:UpdateLevel(Level.Value)
		self:UpdateXp(Xp.Value)
		self.Motor:setGoal(Flipper.Instant.new(Xp.Value / (self.state.XpNeeded or 100)))
	end)

	self.ColorConnection = ReplicatedStorage.Player.LastBlockColor:GetPropertyChangedSignal("Value"):Connect(function()
		local NewColor = ReplicatedStorage.Player.LastBlockColor.Value :: Color3

		if NewColor == Color3.new(1, 1, 1) then
			return
		end

		self:setState({
			LastBlockColor = NewColor,
		})
	end)
end

function LevelDisplay:willUnmount()
	if self.XpConnection then
		self.XpConnection:Disconnect()
	end

	if self.LevelConnection then
		self.LevelConnection:Disconnect()
	end

	if self.ColorConnection then
		self.ColorConnection:Disconnect()
	end

	if self.ShortUnitsConnection then
		self.ShortUnitsConnection:Disconnect()
	end
end

function LevelDisplay:UpdateXp(Xp: number)
	local NeededXp = self.state.XpNeeded or 100
	local LastXp = self.state.LastXp or 0
	local XpChange = Xp - LastXp
	local ShowChange = XpChange > 1

	self:setState({
		LastXp = Xp,
		XpChange = XpChange,
		ShowChange = ShowChange,
	})

	if ShowChange then
		task.wait(0.61)

		self.TextMotor:setGoal(Flipper.Spring.new(1, {
			frequency = 4,
			dampingRatio = 1,
		}))
	end

	self:setState({
		ShowChange = false,
		Xp = Xp,
	})

	if ShowChange then
		task.wait(0.15)

		self.TextMotor:setGoal(Flipper.Spring.new(0, {
			frequency = 4,
			dampingRatio = 1,
		}))

		self.Motor:setGoal(Flipper.Spring.new(Xp / NeededXp, {
			frequency = 4,
			dampingRatio = 1,
		}))
	else
		self.Motor:setGoal(Flipper.Spring.new(Xp / NeededXp, {
			frequency = 4,
			dampingRatio = 1,
		}))
	end
end

function LevelDisplay:UpdateLevel(Level: number)
	local CurrentLevel = Level
	local CurrentLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel))
	local NextLevelConfig = Core.Assets.Levels:FindFirstChild(tostring(CurrentLevel + 1))

	local LevelName = CurrentLevelConfig:GetAttribute("LevelName") :: string
	local LevelColor = CurrentLevelConfig:GetAttribute("LevelColor") :: Color3
	local BarGradient = CurrentLevelConfig:GetAttribute("LevelXpBarColor") :: ColorSequence
	local XpNeeded = NextLevelConfig and NextLevelConfig:GetAttribute("XpNeeded") or 0

	self:setState({
		LevelName = LevelName,
		LevelColor = LevelColor,
		BarGradient = BarGradient,
		XpNeeded = XpNeeded,
	})
end

function LevelDisplay:render()
	local Xp = self.state.Xp or -1
	local XpNeeded = self.state.XpNeeded or -1
	local XpChange = self.state.XpChange or 0
	local ShowXpChange = self.state.ShowChange or false
	local LevelName = self.state.LevelName or "UNKOWN"
	local LevelColor = self.state.LevelColor or Color3.new(1, 0, 0)
	local BarGradient = self.state.BarGradient or ColorSequence.new(Color3.new(1, 0, 0))
	local LastOreColor = self.state.LastBlockColor or Theme.TextColor

	local UseShortUnits = self.state.ShortUnits or false

	if UseShortUnits then
		Xp = Core.Util:ConvertNumberToString(Xp)
		XpChange = Core.Util:ConvertNumberToString(XpChange)
		if XpNeeded ~= 0 then
			XpNeeded = Core.Util:ConvertNumberToString(XpNeeded)
		end
	end

	local BarSize = self.Binding:map(function(Value)
		if XpNeeded == 0 then
			return UDim2.fromScale(1, 1)
		else
			return UDim2.fromScale(0, 1):Lerp(UDim2.fromScale(1, 1), Value)
		end
	end)

	local TextPosition = self.TextBinding:map(function(Value)
		return UDim2.fromScale(0.5, 0.5):Lerp(UDim2.fromScale(0.5, 1), Value)
	end)

	local TextColor = self.TextBinding:map(function(Value)
		return Theme.TextColor:Lerp(LastOreColor, Value)
	end)

	local OverlayTransparency = self.TextBinding:map(function(Value)
		return Lerp(1, 0, Value)
	end)

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		TextArea = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.8),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			TopText = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = LevelName,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextColor3 = LevelColor,
				FontFace = Theme.Font,
			}),

			BottomText = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				CurrentXpContainer = Roact.createElement("Frame", {
					Size = XpNeeded == 0 and UDim2.fromScale(1, 1) or UDim2.fromScale(0.45, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					CurrentXp = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(1, 1),
						Position = TextPosition,
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 1,

						Text = Xp,
						TextStrokeTransparency = 0,
						TextScaled = true,
						TextXAlignment = XpNeeded == 0 and Enum.TextXAlignment.Right or Enum.TextXAlignment.Left,
						TextColor3 = TextColor,
						FontFace = Theme.Font,
					}, {
						ShowXpChange and Roact.createElement(XpDiff, {
							Amount = XpChange,
							Color = LastOreColor,
							Position = UDim2.fromScale(XpNeeded == 0 and 1 or 0.5, 0.5),
							AnchorPoint = Vector2.new(XpNeeded == 0 and 1 or 0.5, 0.5),
						}),
					}),
				}),

				Slash = XpNeeded ~= 0 and Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(0.1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 2,

					Text = "/",
					TextStrokeTransparency = 0,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextColor3 = Theme.TextColor,
					FontFace = Theme.Font,
				}),

				XpNeeded = XpNeeded ~= 0 and Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(0.45, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 3,

					Text = XpNeeded,
					TextStrokeTransparency = 0,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextColor3 = Theme.TextColor,
					FontFace = Theme.Font,
				}),
			}),
		}),

		BarArea = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			BarBackground = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.6),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,
			}, {
				Outline = Roact.createElement("UIStroke", {
					Thickness = 3,
					Color = Color3.new(0, 0, 0),
				}),

				Overlay = Roact.createElement("Frame", {
					Size = BarSize,
					BackgroundTransparency = OverlayTransparency,
					BackgroundColor3 = LastOreColor,
					BorderSizePixel = 0,
					ZIndex = 2,
				}),

				Bar = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BorderSizePixel = 0,
					ZIndex = 1,
				}, {
					Gradient = Roact.createElement("UIGradient", {
						Color = BarGradient,
					}),
				}),

				Cover = Roact.createElement("Frame", {
					Size = BarSize:map(function(Value)
						return UDim2.fromScale(1 - Value.X.Scale, 1)
					end),
					Position = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(1, 1),
					BackgroundColor3 = Theme.BackgroundColor,
					BorderSizePixel = 0,
					ZIndex = 3,
				}),
			}),
		}),
	})
end

return LevelDisplay
