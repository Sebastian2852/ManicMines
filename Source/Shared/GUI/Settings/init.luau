local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Packages.Roact)

local Settings = Roact.Component:extend("Settings")

local Theme = require(ReplicatedStorage.Game.GUI.Theme)

function Settings:PageButton(LayoutOrder: number, Name: string, Page: ModuleScript)
	return Roact.createElement("TextButton", {
		Size = UDim2.fromScale(1, 0.1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = LayoutOrder,

		Text = Name,
		TextScaled = true,
		RichText = true,
		FontFace = Theme.Font,
		TextColor3 = Theme.TextColor,

		[Roact.Event.MouseButton1Click] = function()
			self:setState({
				Page = Roact.createElement(require(Page)),
			})
		end,
	}, {})
end

function Settings:render()
	local CurrentPage = self.state.Page

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		App = Roact.createElement("Frame", {
			Size = UDim2.fromScale(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Theme.BackgroundColor,
			BackgroundTransparency = 0.5,
			BorderSizePixel = 0,
		}, {
			Padding = Roact.createElement("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}, {}),

			Container = Roact.createElement("Frame", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				Layout = Roact.createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
				}, {}),

				TopBar = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.1),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 1,
				}, {
					Title = Roact.createElement("TextLabel", {
						Size = UDim2.fromScale(0.5, 1),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,

						Text = "Settings",
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						FontFace = Theme.Font,
						TextColor3 = Theme.TextColor,
					}, {}),
				}),

				Content = Roact.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.9),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 2,
				}, {
					Layout = Roact.createElement("UIListLayout", {
						Padding = UDim.new(0, 10),
						FillDirection = Enum.FillDirection.Horizontal,
						SortOrder = Enum.SortOrder.LayoutOrder,
					}, {}),

					PageSelect = Roact.createElement("Frame", {
						Size = UDim2.fromScale(0.2, 1),
						BackgroundTransparency = 0.5,
						BackgroundColor3 = Theme.BackgroundColor,
						BorderSizePixel = 0,
						LayoutOrder = 1,
					}, {
						Layout = Roact.createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
						}, {}),

						Graphics = self:PageButton(1, "Graphics", ReplicatedStorage.Game.GUI.Settings.Pages.Graphics),
						Gameplay = self:PageButton(2, "Gameplay", ReplicatedStorage.Game.GUI.Settings.Pages.Gameplay),

						Experimental = self:PageButton(
							999,
							"<font color='#fc9905'> Experimental </font>",
							ReplicatedStorage.Game.GUI.Settings.Pages.Experimental
						),
					}),

					PageContainer = Roact.createElement("Frame", {
						Size = UDim2.new(0.8, -10, 1, 0),
						BackgroundColor3 = Theme.BackgroundColor,
						BackgroundTransparency = 0.5,
						BorderSizePixel = 0,
						LayoutOrder = 2,
					}, {
						App = CurrentPage,
					}),
				}),
			}),
		}),
	})
end

return Settings
