local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local SlotCreator = Roact.Component:extend("SlotCreator")

local BooleanSetting = require(ReplicatedStorage.Game.GUI.MainMenu.SlotSelector.SlotCreator.BooleanSlotSetting)
local NameTextBox = require(script.NameTextBox)
local RandomButton = require(script.RandomButton)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

local MainMenuController

function SlotCreator:init()
	MainMenuController = Knit.GetController("MainMenuController")
end

function SlotCreator:didMount()
	self:setState({
		Tutorial = true,
		SlotName = "",
	})
end

function SlotCreator:render()
	local SlotID = self.props.SlotID
	local SlotName = self.state.SlotName
	local Tutorial = self.state.Tutorial

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		TopBar = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, {}),

			Padding = Roact.createElement("UIPadding", {
				PaddingLeft = UDim.new(0.01, 0),
			}),

			BackButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.1, 0.5),
				BackgroundColor3 = Theme.BackgroundColorRed,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = "Back",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,

				[Roact.Event.MouseEnter] = function()
					Theme.PlaySound(Theme.RawAudio.ButtonHover, true)
				end,

				[Roact.Event.MouseButton1Click] = function()
					Theme.PlaySound(Theme.RawAudio.ButtonClick)
					self.props.OnClose()
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
			}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.75, 0.7),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Text = "Create Slot",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),
		}),

		Name = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.3),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.2),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "Tycoon Name",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			NameInput = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.7, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0.7,
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
				}, {}),

				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),

				Container = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.8),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
				}, {
					Input = Roact.createElement(NameTextBox, {
						TextChanged = function(NewText)
							self:setState({
								SlotName = NewText,
							})
						end,

						Text = self.state.SlotName,
					}),
				}),

				RandomButton = Roact.createElement(RandomButton, {
					LayoutOrder = 2,
					OnClick = function()
						local RandomName = MainMenuController:PickRandomName()
						self:setState({
							SlotName = RandomName,
						})
					end,
				}, {}),
			}),
		}),

		SlotSettings = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = "Slot Settings",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			Settings = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.88),
				Position = UDim2.fromScale(0, 0.12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, {}),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}, {}),

				Tutorial = Roact.createElement(BooleanSetting, {
					InitialValue = true,
					DisplayName = "Tutorial",
					Description = "Enable the tutorial for this slot",
					LayoutOrder = 1,
					OnToggle = function(New: boolean)
						print("On toggle", New)
						self:setState({
							Tutorial = New,
						})
					end,
				}, {}),
			}),
		}),

		BottomBar = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 4,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, {}),

			CreateButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.3, 0.7),
				BackgroundColor3 = Theme.BackgroundColorGreen,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = "Create",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,

				[Roact.Event.MouseEnter] = function()
					Theme.PlaySound(Theme.RawAudio.ButtonHover, true)
				end,

				[Roact.Event.MouseButton1Click] = function()
					Theme.PlaySound(Theme.RawAudio.ButtonClick)
					local SlotSettings = MainMenuController:CreateSlotSettings(SlotName, Tutorial)
					MainMenuController:CreateSlot(SlotID, SlotSettings)
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
			}),
		}),
	})
end

return SlotCreator
