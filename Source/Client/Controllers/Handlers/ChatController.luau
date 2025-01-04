local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local ChatController = Knit.CreateController { Name = "ChatController" }

function ChatController:KnitStart()
	TextChatService.OnIncomingMessage = function(Message)
		local Properties = Instance.new("TextChatMessageProperties")

		if Message.TextSource then
			local CurrentDepth = ReplicatedStorage.Player.Depth.Value

			local DepthTag = ""
			local PlayerTag = ""
			local NameColor = Color3.fromRGB(255, 255, 255):ToHex()
			if CurrentDepth >= 0 then
				DepthTag = `[{CurrentDepth}m] `
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
