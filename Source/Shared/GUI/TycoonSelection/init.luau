local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local TycoonSelection = Roact.Component:extend("TycoonSelection")

local CloseButton = require(script.Parent.Common.CloseButton)
local CostFrame = require(script.CostFrame)
local Theme = require(script.Parent.Theme)

function TycoonSelection:render()
	local UpgradeConfig = self.props.UpgradeConfig or ReplicatedStorage.Assets.Tycoon.Upgrades:GetChildren()[1]
	local LevelConfig = self.props.LevelConfig or UpgradeConfig:GetChildren()[1]
	local NextLevelConfig: Configuration = UpgradeConfig:FindFirstChild(tonumber(LevelConfig.Name) + 1)
	local Costs = NextLevelConfig and Core.OreList.CreateFromFolder(NextLevelConfig.Costs) or nil
	local Close = self.props.Close or function()
		warn("No close func?")
	end

	local UpgradeName = UpgradeConfig:GetAttribute("UpgradeName")
	local UpgradeDescription = UpgradeConfig:GetAttribute("Description")

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Main = Roact.createElement("Frame", {
				Size = UDim2.fromScale(0.5, 0.3),
				Position = UDim2.new(0.5, 0, 1, -10),
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = Theme.BackgroundColor,
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),

				Padding = Roact.createElement("UIPadding", {
					PaddingTop = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingBottom = UDim.new(0, 10),
				}, {}),

				Content = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					CloseButton = Roact.createElement(CloseButton, {
						Size = UDim2.fromScale(0.05, 1),

						OnClick = function()
							Close()
						end,
					}, {}),

					Left = Roact.createElement("Frame", {
						Size = UDim2.fromScale(0.7, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
						}, {}),

						TitleContainer = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 0.15),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 1,
						}, {
							Title = Roact.createElement("TextLabel", {
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,

								Text = UpgradeName,
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								FontFace = Theme.Font,
								TextColor3 = Theme.TextColor,
							}, {}),
						}),

						DescriptionContainer = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 0.85),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
						}, {
							Description = Roact.createElement("TextLabel", {
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,

								Text = UpgradeDescription,
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Top,
								FontFace = Theme.Font,
								TextColor3 = Theme.TextColor,
							}, {
								TextSize = Roact.createElement("UITextSizeConstraint", {
									MinTextSize = 20,
									MaxTextSize = 32,
								}, {}),
							}),
						}),
					}),

					Right = NextLevelConfig and Roact.createElement("Frame", {
						Size = UDim2.fromScale(0.3, 1),
						Position = UDim2.fromScale(1, 0.5),
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Vertical,
						}, {}),

						TitleContainer = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 0.125),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 1,
						}, {
							Title = Roact.createElement("TextLabel", {
								Size = UDim2.fromScale(1, 1),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,

								Text = "Costs",
								TextScaled = true,
								TextXAlignment = Enum.TextXAlignment.Left,
								FontFace = Theme.Font,
								TextColor3 = Theme.TextColor,
							}, {}),
						}),

						Costs = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 0.6),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
						}, {
							App = Roact.createElement(CostFrame, {
								OreList = Costs,
							}, {}),
						}),

						Action = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 0.2),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 3,
						}, {}),
					}),
				}),
			}),
		}),
	})
end

return TycoonSelection
