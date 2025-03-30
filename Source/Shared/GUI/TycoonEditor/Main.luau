local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Packages.Roact)

local ClientDataController = Knit.GetController("ClientDataController")
local TycoonService = Knit.GetService("TycoonService")

local Main = Roact.Component:extend("Main")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Main:init()
	self.NameInputRef = Roact.createRef()

	self:setState({
		TycoonNameInput = "",
		CanUpdateName = false,
	})
end

function Main:render()
	local CanUpdateName = self.state.CanUpdateName

	return Roact.createElement("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 0.5,
		BackgroundColor3 = Theme.BackgroundColor,
		BorderSizePixel = 0,
	}, {
		Padding = Roact.createElement("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
		}, {}),

		TycoonName = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.2),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			Title = Roact.createElement("TextLabel", {
				Size = UDim2.fromScale(1, 0.3),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,

				Text = "Tycoon Name",
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextColor,
			}, {}),

			Input = Roact.createElement("TextBox", {
				Size = UDim2.fromScale(1, 0.3),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 0.75,
				BackgroundColor3 = Theme.BackgroundColor,
				BorderSizePixel = 0,

				Text = "",
				PlaceholderText = ClientDataController:GetTycoonName(),
				TextScaled = true,
				FontFace = Theme.Font,
				TextColor3 = Theme.TextColor,
				PlaceholderColor3 = Theme.TextDisabledColor,

				[Roact.Ref] = self.NameInputRef,

				[Roact.Event.FocusLost] = function(Box)
					self:setState({
						CanUpdateName = Core.GameConfig.MainMenu.NameTypeCheck:Check(Box.Text),
						TycoonNameInput = Box.Text,
					})
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),
			}),

			Action = Roact.createElement("TextButton", {
				Size = UDim2.fromScale(0.3, 0.25),
				Position = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = CanUpdateName and Theme.BackgroundColorGreen
					or Theme.BackgroundColorGreen:Lerp(Color3.new(0, 0, 0), 0.5),
				BorderSizePixel = 0,

				Text = "Update",
				TextScaled = true,
				TextColor3 = CanUpdateName and Theme.TextColor or Theme.TextDisabledColor,
				FontFace = Theme.Font,

				[Roact.Event.MouseButton1Click] = function(Button: TextButton)
					if not CanUpdateName then
						return
					end

					local NameInput = self.NameInputRef:getValue() :: TextBox?
					Button.Interactable = false

					local NewName = self.state.TycoonNameInput

					TycoonService:RenameTycoon(NewName):andThen(function(UpdatedName)
						NameInput.Text = UpdatedName
						self:setState({
							TycoonNameInput = UpdatedName,
						})
						Button.Interactable = true
					end)
				end,
			}, {
				Corners = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(0, 7),
				}, {}),
			}),
		}),
	})
end

return Main
