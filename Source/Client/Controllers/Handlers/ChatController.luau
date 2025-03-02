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
				MineService:ConvertToDepth(Character and Character.HumanoidRootPart.CFrame.Position.Y or 100000):await()

			local DepthTag = ""
			local PlayerTag = ""
			local NameColor = Color3.fromRGB(255, 255, 255):ToHex()
			if Depth >= 0 then
				DepthTag = `[{Depth + 1}m] `
			end

			if Core.GameConfig.Chat.Players[Message.TextSource.UserId] then
				PlayerTag =
					`<font color='#{Core.GameConfig.Chat.Players[Message.TextSource.UserId].TagColor:ToHex()}'>[{Core.GameConfig.Chat.Players[Message.TextSource.UserId].Tag}]</font> `
				NameColor = Core.GameConfig.Chat.Players[Message.TextSource.UserId].NameColor:ToHex()
			end

			Properties.PrefixText = `<font color='#{NameColor}'>{PlayerTag .. DepthTag .. Message.PrefixText}</font>`
		else
			Properties.PrefixText = `<font color='#{Core.GameConfig.Chat.ServerTagColor:ToHex()}'>[SERVER]</font> `
				.. Message.PrefixText
		end

		return Properties
	end
end

return ChatController
