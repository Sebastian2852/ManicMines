local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Zeno = require(ReplicatedStorage.Packages.Zeno)

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
		CanCreate = false,
	})
end

function SlotCreator:Verify()
	local Name = self.state.SlotName
	local Valid = Zeno.String():LongerThan(1):ShorterThan(15):Check(Name)
	self:setState({
		CanCreate = Valid,
	})
end

function SlotCreator:render()
	local SlotID = self.props.SlotID
	local SlotName = self.state.SlotName
	local Tutorial = self.state.Tutorial
	local CanCreate = self.state.CanCreate

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
						PreFilter = function()
							self:setState({
								CanCreate = false,
							})
						end,

						AfterFilter = function(NewText)
							self:setState({
								SlotName = NewText,
							}, function()
								self:Verify()
							end)
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
				BackgroundColor3 = Theme.BackgroundColorGreen:Lerp(Color3.new(0, 0, 0), CanCreate and 0 or 0.5),
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = "Create",
				TextScaled = true,
				TextColor3 = CanCreate and Theme.TextColor or Theme.TextDisabledColor,
				FontFace = Theme.Font,
				AutoButtonColor = CanCreate,

				[Roact.Event.MouseEnter] = CanCreate and function()
					Theme.PlaySound(Theme.RawAudio.ButtonHover, true)
				end or function() end,

				[Roact.Event.MouseButton1Click] = CanCreate and function()
					Theme.PlaySound(Theme.RawAudio.ButtonClick)
					local SlotSettings = MainMenuController:CreateSlotSettings(SlotName, Tutorial)
					MainMenuController:CreateSlot(SlotID, SlotSettings)
				end or function() end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 4),
				}),
			}),
		}),
	})
end

return SlotCreator
