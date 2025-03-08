local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local ChatController = Knit.CreateController({ Name = "ChatController" })

function ChatController:KnitStart()
	local MineService = Knit.GetService("MineService")

	TextChatService.OnIncomingMessage = function(Message)
		local Properties = Instance.new("TextChatMessageProperties")

		if Message.TextSource then
			local Player = Players:GetPlayerByUserId(Message.TextSource.UserId)
			local Character = Player.Character
			local _, Depth =
				MineService:ConvertToDepth(
					Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart.CFrame.Position.Y
						or 100000
				):await()

			local DepthTag = ""
			local PlayerTag = ""
			local LevelTag = ""
			local NameColor = Color3.fromRGB(255, 255, 255):ToHex()
			local LevelColor = Color3.fromRGB(255, 255, 255):ToHex()

			local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(Message.TextSource.UserId) :: Core.DataFolder

			if DataFolder then
				local Level = DataFolder.Level.Value
				local Config = ReplicatedStorage.Assets.Levels:FindFirstChild(Level)
				LevelColor = Config:GetAttribute("LevelColor"):ToHex()
				NameColor = LevelColor
				LevelTag = `<font color='#{LevelColor}'>[{Config:GetAttribute("LevelName")}]</font> `
			end

			if Depth >= 0 then
				DepthTag = `[{Depth + 1}m] `
			end

			if Core.GameConfig.Chat.Players[Message.TextSource.UserId] then
				PlayerTag =
					`<font color='#{Core.GameConfig.Chat.Players[Message.TextSource.UserId].TagColor:ToHex()}'>[{Core.GameConfig.Chat.Players[Message.TextSource.UserId].Tag}]</font> `

				local PossibleNameColor = Core.GameConfig.Chat.Players[Message.TextSource.UserId].NameColor
				if PossibleNameColor then
					NameColor = PossibleNameColor
				end
			end

			Properties.PrefixText =
				`<font color='#{NameColor}'>{PlayerTag .. LevelTag .. DepthTag .. Message.PrefixText}</font>`
		else
			Properties.PrefixText = `<font color='#{Core.GameConfig.Chat.ServerTagColor:ToHex()}'>[SERVER]</font> `
				.. Message.PrefixText
		end

		return Properties
	end
end

return ChatController
