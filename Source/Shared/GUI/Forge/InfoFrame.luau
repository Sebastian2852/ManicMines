-- # selene: allow(mixed_table)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Display = require(script.Parent.Display)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local PickaxeService

local InfoFrame = Roact.Component:extend("InfoFrame")

local CostFrame = require(ReplicatedStorage.Game.GUI.Common.CostFrame)
local IconLabel = require(ReplicatedStorage.Game.GUI.Common.IconLabel)
local Theme = require(script.Parent.Parent.Theme)

local Equipping = false
local Buying = false

function InfoFrame:CreateIconLabel(Text: string, IconImage: string, LayoutOrder: number)
	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 0.3),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		App = Roact.createElement(IconLabel, {
			LayoutOrder = LayoutOrder,
			Image = IconImage,
			Text = Text,
		}, {}),
	})
end

function InfoFrame:CreateCostsFragment(Costs: Core.OreList)
	local Elements = {}

	for _, v: Core.OreListItem in pairs(Costs:LoopList()) do
		Elements[v.Name] = self:CreateIconLabel(v.DisplayName .. ": " .. v.Amount, v.Emblem, v.Amount)
	end

	return Roact.createFragment(Elements)
end

function InfoFrame:CreateEquipButton(ConfigName: string)
	return Roact.createElement("TextButton", {
		Size = UDim2.fromScale(0.8, 0.4),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.BackgroundColorBlue,
		BorderSizePixel = 0,

		Text = "Equip",
		TextScaled = true,
		TextColor3 = Theme.TextColor,
		FontFace = Theme.Font,

		[Roact.Event.MouseButton1Click] = function()
			if Equipping then
				warn("Already eqiupping")
				return
			end
			Equipping = true
			local Config = ReplicatedStorage.Assets.Pickaxe.Pickaxes:FindFirstChild(ConfigName)
			PickaxeService:EquipPickaxe(Config):andThen(function()
				Display.ShowPickaxe(Config)
				Equipping = false
			end)
		end,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),
	})
end

function InfoFrame:CreateEquippedButton()
	return Roact.createElement("TextLabel", {
		Size = UDim2.fromScale(0.8, 0.4),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.BackgroundColorBlue:Lerp(Color3.new(0, 0, 0), 0.5),
		BorderSizePixel = 0,

		Text = "Equipped",
		TextScaled = true,
		TextColor3 = Theme.TextColorDisabled,
		FontFace = Theme.Font,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),
	})
end

function InfoFrame:CreateBuyButton(ConfigName: string)
	return Roact.createElement("TextButton", {
		Size = UDim2.fromScale(0.8, 0.4),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.BackgroundColorGreen,
		BorderSizePixel = 0,

		Text = "Buy",
		TextScaled = true,
		TextColor3 = Theme.TextColor,
		FontFace = Theme.Font,

		[Roact.Event.MouseButton1Click] = function()
			if Buying then
				return
			end
			Buying = true
			local Config = ReplicatedStorage.Assets.Pickaxe.Pickaxes:FindFirstChild(ConfigName)

			PickaxeService:BuyPickaxe(Config):andThen(function()
				Display.ShowPickaxe(Config)
				Display.UpdateButtons:Fire()
				Buying = false
			end)
		end,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),
	})
end

function InfoFrame:CreateDisabledBuyButton()
	return Roact.createElement("TextLabel", {
		Size = UDim2.fromScale(0.8, 0.4),
		Position = UDim2.new(0.5, 0, 1, -10),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Theme.BackgroundColorGreen:Lerp(Color3.new(0, 0, 0), 0.5),
		BorderSizePixel = 0,

		Text = "Buy",
		TextScaled = true,
		TextColor3 = Theme.TextColorDisabled,
		FontFace = Theme.Font,
	}, {
		Corners = Roact.createElement("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}, {}),
	})
end

function InfoFrame:init()
	PickaxeService = Knit.GetService("PickaxeService")
end

function InfoFrame:render()
	local Power = self.props.Power or "[UNKNOWN]"
	local Range = self.props.Range or "[UNKNOWN]"
	local Delay = self.props.Delay or "[UNKNOWN]"
	local PickaxeName = self.props.Name or "[UNKNOWN]"
	local ConfigName = self.props.ConfigName or "0"
	local IsLocked = self.props.IsLocked or false
	local NeededUpgradeMessage = self.props.UpgradeMessage or "[UNKNOWN]"

	local ShowButton = self.props.ShowButton or false
	local Unlocked = self.props.Unlocked or false
	local Equipped = self.props.Equipped or false
	local CostsOreList = self.props.Costs or Core.OreList.New()

	local Button

	if ShowButton then
		if Equipped then
			Button = self:CreateEquippedButton()
		elseif Unlocked and not Equipped then
			Button = self:CreateEquipButton(ConfigName)
		else
			Button = self:CreateBuyButton(ConfigName)
		end
	else
		Button = self:CreateDisabledBuyButton()
	end

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		Background = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ZIndex = 1,
		}, {
			Corners = Roact.createElement("UICorner", {
				CornerRadius = UDim.new(0, 7),
			}, {}),
		}),

		Content = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}, {}),

			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = PickaxeName,
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),

			UpgradeMessage = IsLocked and Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.05),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Text = NeededUpgradeMessage,
				TextScaled = true,
				TextColor3 = Theme.BackgroundColorRed,
				FontFace = Theme.Font,
				TextXAlignment = Enum.TextXAlignment.Center,
			}, {}),

			Stats = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 3,
			}, {
				Title = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "Stats",
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Theme.TextColor,
					FontFace = Theme.Font,
				}, {}),

				Stats = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.8),
					Position = UDim2.fromScale(0, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}, {}),

					Power = self:CreateIconLabel(Power, Theme.Images.Power, 1),
					Range = self:CreateIconLabel(Range, Theme.Images.Range, 1),
					Delay = self:CreateIconLabel(Delay, Theme.Images.Delay, 1),
				}),
			}),

			Costs = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 4,
			}, {
				Title = Roact.createElement("TextLabel", {
					Size = UDim2.fromScale(1, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,

					Text = "Costs",
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextColor3 = Theme.TextColor,
					FontFace = Theme.Font,
				}, {}),

				App = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.8),
					Position = UDim2.fromScale(0, 0.2),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Costs = not Unlocked and Roact.createElement(CostFrame, {
						OreList = CostsOreList,
					}, {}) or self:CreateCostsFragment(CostsOreList),
				}),
			}),

			Action = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 0.25),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 5,
			}, {
				App = Button,
			}),
		}),
	})
end

return InfoFrame
