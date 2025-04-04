local BadgeService = game:GetService("BadgeService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RobloxMessagingService = game:GetService("MessagingService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)

local MessageService = Knit.CreateService({
	Name = "MessageService",
	Client = {
		SendMessage = Knit.CreateSignal(),
		EnableChannels = Knit.CreateSignal(),
	},
})

--[[ PUBLIC ]]
--

MessageService.AdminChannel = nil

--[=[
Sends a chat message to a player
]=]
function MessageService:SendMessageToPlayer(Message: Core.ChatMessage, Player: Player)
	self.Client.SendMessage:Fire(Player, Message)
	Logger:Log("Sent message to player:", Player.Name)
end

--[=[
Sends a chat message to every player in the server
]=]
function MessageService:SendMessage(Message: Core.ChatMessage)
	for _, Player: Player in pairs(game.Players:GetPlayers()) do
		self.Client.SendMessage:Fire(Player, Message)
	end
	Logger:Log("Sent message to all players")
end

function MessageService:SendMessageToAllServers(Message: Core.ChatMessage)
	local Color = Message.MessageColor
	Message.MessageColor = { Color.R, Color.G, Color.B }
	RobloxMessagingService:PublishAsync("GlobalChatMessage", HttpService:JSONEncode(Message))
end

--[[ KNIT ]]
--

function MessageService:KnitStart()
	game.Players.PlayerAdded:Connect(function(Player)
		local ChatTagInfo = Core.GameConfig.Chat.Players[Player.UserId]

		local Message: Core.ChatMessage = {
			Message = `{ChatTagInfo ~= nil and `[{ChatTagInfo.Tag}] ` or " "} {Player.DisplayName} (@{Player.Name}) joined the game!`,
			HasPrefix = false,
			MessageColor = ChatTagInfo ~= nil and ChatTagInfo.TagColor or Color3.new(1, 1, 1),
		}

		for _, v in pairs(game.Players:GetPlayers()) do
			if Player.UserId == v.UserId then
				continue
			end
			MessageService:SendMessageToPlayer(Message, v)
		end

		for _, v in pairs(Players:GetPlayers()) do
			local ID = Core.GameConfig.Badges[v.UserId]
			if ID == nil then
				continue
			end

			for _, ToAward in pairs(Players:GetPlayers()) do
				local Success, HasBadge, Error = pcall(function()
					return BadgeService:UserHasBadgeAsync(ToAward.UserId, ID.ID)
				end)

				if Success == false then
					warn("Failed to see if the player has badge:", HasBadge, Error)
					continue
				end

				if HasBadge == false then
					BadgeService:AwardBadge(ToAward.UserId, ID.ID)
					MessageService:SendMessageToAllServers({
						Message = `{ToAward.DisplayName} (@{ToAward.Name}) has been awarded the "{ID.Name}" badge`,
						Prefix = "",
						HasPrefix = false,
						MessageColor = Color3.fromRGB(255, 210, 24),
					})
				end
			end
		end
	end)

	game.Players.PlayerRemoving:Connect(function(Player)
		local Message: Core.ChatMessage = {
			Message = Player.DisplayName .. " (@" .. Player.Name .. ") left the game!",
			HasPrefix = false,
		}

		MessageService:SendMessage(Message)
	end)

	RobloxMessagingService:SubscribeAsync("GlobalChatMessage", function(Received)
		local Message = Received.Data

		local Decoded = HttpService:JSONDecode(Message) :: Core.ChatMessage
		local Color = Decoded.MessageColor :: {}
		Decoded.MessageColor = Color3.new(Color[1], Color[2], Color[3])

		self:SendMessage(Decoded)
	end)
end

return MessageService
