local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local StorageService

local OreFrame = Roact.PureComponent:extend("OreFrame")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function OreFrame:init()
	StorageService = Knit.GetService("StorageService")
end

function OreFrame:render()
	local LayoutOrder = self.props.LayoutOrder or 0
	local Amount = self.props.Amount or -1
	local IconImage = self.props.Image or Theme.Images.Missing
	local Text = self.props.Text or "[UNKNOWN]"

	local OreName = self.props.OreName or "Stone"

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = LayoutOrder,
	}, {
		Info = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 1),
			Position = UDim2.fromScale(0.5, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.Fill,
			}, {}),

			Icon = Roact.createElement("ImageLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Image = IconImage,
				ScaleType = Enum.ScaleType.Fit,
			}, {
				AspectRatio = Roact.createElement("UIAspectRatioConstraint", {
					AspectRatio = 1,
					AspectType = Enum.AspectType.ScaleWithParentSize,
					DominantAxis = Enum.DominantAxis.Height,
				}, {}),
			}),

			Text = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = Text .. " - " .. Amount,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,
			}, {}),
		}),

		Buttons = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalFlex = Enum.UIFlexAlignment.SpaceEvenly,
			}, {}),

			HalfButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.2, 0.9),
				BackgroundColor3 = Theme.BackgroundColorBlue,
				BorderSizePixel = 0,
				LayoutOrder = 3,

				Text = "50%",
				TextColor3 = Theme.TextColor,
				TextScaled = true,
				FontFace = Theme.Font,

				[Roact.Event.MouseButton1Click] = function()
					StorageService:MoveToInventory(OreName, math.floor(Amount / 2))
				end,
			}, {}),

			FullButton = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.2, 0.9),
				BackgroundColor3 = Theme.BackgroundColorGreen,
				BorderSizePixel = 0,
				LayoutOrder = 2,

				Text = "100%",
				TextColor3 = Theme.BackgroundColor,
				TextScaled = true,
				FontFace = Theme.Font,

				[Roact.Event.MouseButton1Click] = function()
					StorageService:MoveToInventory(OreName, Amount)
				end,
			}, {}),

			Custom = Roact.createElement("TextBox", {
				Size = UDim2.fromScale(0.2, 0.9),
				BackgroundColor3 = Color3.new(0, 0, 0),
				BackgroundTransparency = 0.5,
				BorderSizePixel = 0,
				LayoutOrder = 1,

				Text = "",
				PlaceholderText = "...",
				TextScaled = true,
				TextColor3 = Theme.TextColor,
				FontFace = Theme.Font,

				[Roact.Event.FocusLost] = function(Object: TextBox)
					local EnteredAmount = tonumber(Object.Text)
					Object.Text = ""
					if type(EnteredAmount) ~= "number" then
						return
					end

					local RoundedAmount = math.floor(EnteredAmount)
					local ClamppedAmount = math.clamp(RoundedAmount, 0, Amount)
					StorageService:MoveToInventory(OreName, ClamppedAmount)
				end,
			}, {}),
		}),
	})
end

return OreFrame
