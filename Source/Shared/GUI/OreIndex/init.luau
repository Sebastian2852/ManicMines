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
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		[OreName] = Roact.createElement(OreButton, {
			Emblem = Emblem,
			OreName = OreName,
			IsLocked = Locked,
			OnClick = function()
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

	local SelectedBlock = self.state.SelectedBlock or ReplicatedStorage.Assets.Stone
	local AmountOfOres = ReplicatedStorage.Assets.Ores:GetChildren()

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.5),
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

			Header = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "Ore Index",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, {}),

			Content = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.9),
				Position = UDim2.fromScale(0, 0.1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalFlex = Enum.UIFlexAlignment.Fill,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, {}),

				OreSelection = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.4, 1),
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
						Size = UDim2.fromScale(1, 0.1),
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

				OreInfo = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 2,
				}, {
					App = Roact.createElement(OreInfo, {
						Block = SelectedBlock,
					}, {}),
				}),
			}),
		}),
	})
end

return OreIndex
