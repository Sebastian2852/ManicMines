local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)

local PickaxeSelection = Roact.Component:extend("PickaxeSelection")

local Bar = require(script.Bar)
local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function PickaxeSelection:init()
	ReplicatedStorage.Player.PickaxeSelection:GetPropertyChangedSignal("Value"):Connect(function()
		local Block = ReplicatedStorage.Player.PickaxeSelection.Value
		if Block == nil then
			self:setState({
				Selecting = false,
			})
			return
		end

		local function UpdateInfo()
			local Health = Block:GetAttribute("Health")
			local MaxHealth = Block:GetAttribute("MaxHealth")

			local Pickaxe: Instance = Players.LocalPlayer.Character:FindFirstChild("Pickaxe")

			if not Pickaxe then
				self:setState({
					Selecting = false,
				})
				return
			end

			local AdjustedDamage = (Pickaxe:GetAttribute("Damage") / 2) / Block:GetAttribute("Depth") or -1

			if (Block:GetAttribute("Depth") or -1) < ReplicatedStorage.Player.OptimalDepth.Value then
				AdjustedDamage = Pickaxe:GetAttribute("Damage")
			end

			local HitsNeeded = math.ceil(Health / AdjustedDamage)
			local TimePerHit = Pickaxe:GetAttribute("Delay")
			local TotalTime = HitsNeeded * TimePerHit

			self:setState({
				MiningPercentage = math.ceil((1 - (Health / MaxHealth)) * 100),
				TimeToMine = Core.Util:RoundToxDP(TotalTime, 2),
			})
		end

		local DisplayName = Block:GetAttribute("DisplayName")
		local Emblem = Block:GetAttribute("EmblemImageID")

		Block:GetAttributeChangedSignal("Health"):Connect(UpdateInfo)
		UpdateInfo()

		self:setState({
			Selecting = true,
			DisplayName = DisplayName,
			EmblemID = Emblem,
			Block = Block,
		})
	end)

	self:setState({
		Selecting = false,
	})
end

function PickaxeSelection:render()
	local Block = self.state.Block :: BasePart
	local DisplayName = self.state.DisplayName or "[UNKNOWN]"
	local EmblemID = self.state.EmblemID or Theme.Images.Missing
	local Selecting = self.state.Selecting or false

	local MiningPercentage = self.state.MiningPercentage or -1
	local TimeToMine = self.state.TimeToMine or -1

	return Selecting
			and Roact.createElement("ScreenGui", {
				ResetOnSpawn = false,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			}, {
				Container = Roact.createElement("Frame", {
					Size = UDim2.fromScale(0.244, 0.128),
					Position = UDim2.fromScale(0.5, 0.717),
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Vertical,
					}, {}),

					TextArea = Roact.createElement("Frame", {
						Size = UDim2.fromScale(1, 0.5),
						LayoutOrder = 1,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							FillDirection = Enum.FillDirection.Horizontal,
						}, {}),

						Image = Roact.createElement("ImageLabel", {
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 1,
							LayoutOrder = 1,

							Image = EmblemID,
							ScaleType = Enum.ScaleType.Fit,
						}, {
							Aspect = Roact.createElement("UIAspectRatioConstraint", {
								AspectRatio = 1,
								AspectType = Enum.AspectType.FitWithinMaxSize,
								DominantAxis = Enum.DominantAxis.Height,
							}, {}),
						}),

						Text = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 1),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
							LayoutOrder = 2,
						}, {
							Layout = Roact.createElement("UIListLayout", {
								SortOrder = Enum.SortOrder.LayoutOrder,
								FillDirection = Enum.FillDirection.Vertical,
							}, {}),

							Pading = Roact.createElement("UIPadding", {
								PaddingLeft = UDim.new(0, 10),
							}, {}),

							DisplayName = Roact.createElement("TextLabel", {
								Size = UDim2.fromScale(1, 0.6),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 1,

								Text = DisplayName,
								TextScaled = true,
								TextColor3 = Theme.TextColor,
								FontFace = Theme.Font,
								TextStrokeTransparency = 0,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Bottom,
							}, {}),

							TimeToMine = Roact.createElement("TextLabel", {
								Size = UDim2.fromScale(1, 0.4),
								BackgroundTransparency = 1,
								BorderSizePixel = 0,
								LayoutOrder = 2,

								Text = `{math.clamp(MiningPercentage, 0, 100)}% • {math.abs(
									math.clamp(TimeToMine, 0, math.huge)
								)}S`,
								TextScaled = true,
								TextColor3 = Theme.TextColor,
								FontFace = Theme.Font,
								TextStrokeTransparency = 0,
								TextXAlignment = Enum.TextXAlignment.Left,
								TextYAlignment = Enum.TextYAlignment.Top,
							}, {}),
						}),
					}),

					BarArea = Roact.createElement("Frame", {
						Size = UDim2.fromScale(1, 0.5),
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
					}, {
						Container = Roact.createElement("Frame", {
							Size = UDim2.fromScale(1, 0.35),
							Position = UDim2.fromScale(0.5, 0.3),
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = 1,
							BorderSizePixel = 0,
						}, {
							Bar = Roact.createElement(Bar, { Block = Block }, {}),
						}),
					}),
				}),
			})
		or nil
end

return PickaxeSelection
