local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Roact = require(ReplicatedStorage.Packages.Roact)
local Trove = require(ReplicatedStorage.Packages.trove)

local OverheadGUI = Roact.Component:extend("OverheadGUI")

local LevelFrame = require(ReplicatedStorage.Game.GUI.OverheadGUI.LevelFrame)
local NameFrame = require(ReplicatedStorage.Game.GUI.OverheadGUI.NameFrame)

function OverheadGUI:didMount()
	self.Trove = Trove.new()

	local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(self.props.UserID) :: Core.DataFolder
	if not DataFolder then
		return
	end

	DataFolder.Settings.HideOverheadGUI:GetPropertyChangedSignal("Value"):Connect(function()
		if not DataFolder.Settings.HideOverheadGUI.Value then
			self:setState({
				PlayerToHideFrom = nil,
			})
		else
			self:setState({
				PlayerToHideFrom = Players:GetPlayerByUserId(self.props.UserID),
			})
		end
	end)

	if DataFolder.Settings.HideOverheadGUI.Value then
		self:setState({
			PlayerToHideFrom = DataFolder.Settings.HideOverheadGUI.Value
				and Players:GetPlayerByUserId(self.props.UserID),
		})
	end
end

function OverheadGUI:willUnmount()
	self.Trove:Destroy()
end

function OverheadGUI:render()
	local UserID = self.props.UserID or 0
	local PlayerToHideFrom = self.state.PlayerToHideFrom

	return Roact.createElement("BillboardGui", {
		Size = UDim2.fromScale(7, 3),
		StudsOffset = Vector3.new(0, 5, 0),
		LightInfluence = 0,
		PlayerToHideFrom = PlayerToHideFrom,
		MaxDistance = 30,
		AlwaysOnTop = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		Layout = Roact.createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, {}),

		Level = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
		}, {
			App = Roact.createElement(LevelFrame, {
				UserID = UserID,
			}, {}),
		}),

		Name = Roact.createElement("Frame", {
			Size = UDim2.fromScale(1, 0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, {
			App = Roact.createElement(NameFrame, {
				UserID = UserID,
			}, {}),
		}),
	})
end

return OverheadGUI
