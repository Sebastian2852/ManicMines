local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local OreIndexController

local OreIndex = Roact.Component:extend("OreIndex")

local OreButton = require(ReplicatedStorage.Game.GUI.OreIndex.OreButton)
local OreInfo = require(ReplicatedStorage.Game.GUI.OreIndex.OreInfo)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function OreIndex:init()
	OreIndexController = Knit.GetController("OreIndexController")

	self.ScrollerRef = Roact.createRef()
end

function OreIndex:CreateOreButton(RealOreName: string, Locked: boolean, OreName: string, Emblem: string)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.05),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		[OreName] = Roact.createElement(OreButton, {
			Emblem = Emblem,
			OreName = OreName,
			IsLocked = Locked,
			OnClick = function()
				if Locked then
					return
				end
				self:setState({ SelectedBlock = ReplicatedStorage.Assets.Ores:FindFirstChild(RealOreName) })
			end,
		}, {}),
	})
end

function OreIndex:CreateOreButtons()
	local Buttons = {}
	local Search = self.state.SearchQuery or ""

	for _, Ore in pairs(ReplicatedStorage.Assets.Ores:GetChildren()) do
		local DisplayName = Ore:GetAttribute("DisplayName")
		if Search == "" or string.find(string.lower(DisplayName), string.lower(Search)) then
			local Locked = OreIndexController:ShouldOreBeLocked(Ore.Name)
			if Search ~= "" and Locked then
				continue
			end
			Buttons[Locked and HttpService:GenerateGUID(true) or DisplayName] =
				self:CreateOreButton(Ore.Name, Locked, DisplayName, Ore:GetAttribute("EmblemImageID"))
		end
	end

	return Buttons
end

function OreIndex:render()
	local Buttons = self:CreateOreButtons()
	Buttons["Layout"] = Roact.createElement("UIListLayout", {
		SortOrder = Enum.SortOrder.Name,
		FillDirection = Enum.FillDirection.Vertical,
	}, {})

	local SelectedBlock = self.state.SelectedBlock
	local AmountOfOres = ReplicatedStorage.Assets.Ores:GetChildren()

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	}, {
		Top = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.3),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, {
			Gradient = Roact.createElement("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new(Color3.new(0, 0, 0)),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0, 0),
					NumberSequenceKeypoint.new(1, 1, 0),
				}),
			}, {}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(0.3, 0.3),
				Position = UDim2.fromScale(0.5, 0.1),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "<u>Ore Index</u>",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				RichText = true,
				FontFace = Theme.Font,
			}, {}),

			CloseButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.1, 0.1),
				Position = UDim2.new(0.5, 0, 0.4, 10),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundColor3 = Theme.BackgroundColorRed,
				BorderSizePixel = 0,

				Text = "<- Back",
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				FontFace = Theme.Font,

				[Roact.Event.MouseButton1Click] = function()
					OreIndexController:Close()
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),
			}),
		}),

		Left = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			OreSelector = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.2, 0.7),
				Position = UDim2.new(0, 10, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
			}, {
				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
				}, {}),

				Content = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					OreSelection = Roact.createElement("Frame", {
						Size = UDim2.fromScale(1, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						LayoutOrder = 1,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							Padding = UDim.new(0, 10),
							FillDirection = Enum.FillDirection.Vertical,
							VerticalFlex = Enum.UIFlexAlignment.Fill,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}, {}),

						SearchBox = Roact.createElement("TextBox", {
							Size = UDim2.fromScale(1, 0.05),
							BackgroundTransparency = 0.75,
							BackgroundColor3 = Theme.BackgroundColor,
							LayoutOrder = 1,

							Text = "",
							PlaceholderText = `Search {#AmountOfOres} ores`,
							TextScaled = true,
							TextColor3 = Theme.TextColor,
							PlaceholderColor3 = Theme.TextDisabledColor,
							FontFace = Theme.Font,

							[Roact.Change.Text] = function(TextBox: TextBox)
								self:setState({ SearchQuery = TextBox.Text })

								local Scroller: ScrollingFrame = self.ScrollerRef:getValue()
								if Scroller == nil then
									warn("Scroller ref not set; This is not a bug!")
									return
								end

								Scroller.CanvasPosition = Vector2.new(0, 0)
							end,
						}, {
							Corners = Roact.createElement("UICorner", {
								CornerRadius = UDim.new(0, 10),
							}, {}),
						}),

						Scroller = Roact.createElement("ScrollingFrame", {
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,

							ScrollBarThickness = 5,
							VerticalScrollBarInset = Enum.ScrollBarInset.Always,
							VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
							ScrollingDirection = Enum.ScrollingDirection.Y,
							ScrollBarImageColor3 = Theme.TextColor,
							AutomaticCanvasSize = Enum.AutomaticSize.Y,

							[Roact.Ref] = self.ScrollerRef,
						}, Buttons),
					}),
				}),
			}),
		}),

		Right = SelectedBlock and Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			OreInfo = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.2, 0.3),
				Position = UDim2.new(1, -10, 0.5, 0),
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
			}, {
				App = Roact.createElement(OreInfo, {
					Block = SelectedBlock,
				}, {}),
			}),
		}),
	})
end

return OreIndex
