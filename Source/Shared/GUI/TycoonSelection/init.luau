local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local ClientDataController
local TycoonService

local TycoonSelection = Roact.Component:extend("TycoonSelection")

local CloseButton = require(script.Parent.Common.CloseButton)
local CostFrame = require(script.CostFrame)
local Theme = require(script.Parent.Theme)

function TycoonSelection:init()
	ClientDataController = Knit.GetController("ClientDataController")
	TycoonService = Knit.GetService("TycoonService")
end

function TycoonSelection:CreateBuyButton(Close: () -> (), Name: string)
	return Roact.createElement("TextButton", {
		Size = UDim2.fromScale(0.8, 0.4),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.BackgroundColorGreen,
		BorderSizePixel = 0,

		Text = "Upgrade",
		TextScaled = true,
		TextColor3 = Theme.TextColor,
		FontFace = Theme.Font,

		[Roact.Event.MouseButton1Click] = function()
			--[[
				This button is only created if the player has enough
				to upgrade so its fair to assume the upgrade will succeed
				so we can close without checking
			]]
			Close()

			TycoonService:Upgrade(Name)
		end,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),
	})
end

function TycoonSelection:CreateDisabledBuyButton()
	return Roact.createElement("TextLabel", {
		Size = UDim2.fromScale(0.8, 0.4),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.BackgroundColorGreen:Lerp(Color3.new(0, 0, 0), 0.5),
		BorderSizePixel = 0,

		Text = "Upgrade",
		TextScaled = true,
		TextColor3 = Theme.TextColorDisabled,
		FontFace = Theme.Font,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),
	})
end

function TycoonSelection:CreateAction(CanAfford: boolean, Close: () -> ()?, UpgradeName: string?)
	if CanAfford then
		return self:CreateBuyButton(Close, UpgradeName)
	else
		return self:CreateDisabledBuyButton()
	end
end

function TycoonSelection:render()
	local UpgradeConfig = self.props.UpgradeConfig or ReplicatedStorage.Assets.Tycoon.Upgrades:GetChildren()[1]
	local LevelConfig = self.props.LevelConfig or UpgradeConfig:GetChildren()[1]
	local NextLevelConfig: Configuration = UpgradeConfig:FindFirstChild(tonumber(LevelConfig.Name) + 1)
	local Costs = NextLevelConfig and Core.OreList.CreateFromFolder(NextLevelConfig.Costs) or nil
	local Close = self.props.Close or function()
		warn("No close func?")
	end

	local Name = UpgradeConfig:GetAttribute("UpgradeName")
	local Description = UpgradeConfig:GetAttribute("Description")
	local CanAfford = Costs and ClientDataController:HasEnoughOres(Costs) or false

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

								Text = Name,
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

								Text = Description,
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
							Size = UDim2.fromScale(1, 0.275),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 3,
						}, {
							App = self:CreateAction(CanAfford, Close, UpgradeConfig.Name),
						}),
					}),
				}),
			}),
		}),
	})
end

return TycoonSelection
