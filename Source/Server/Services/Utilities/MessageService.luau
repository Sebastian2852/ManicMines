local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local MessageService = Knit.CreateService({
	Name = "MessageService",
	Client = {
		SendMessage = Knit.CreateSignal(),
		EnableChannels = Knit.CreateSignal(),
	},
})

local LogService

--[[ PUBLIC ]]
--

MessageService.AdminChannel = nil

--[=[
Sends a chat message to a player
]=]
function MessageService:SendMessageToPlayer(Message: Core.ChatMessage, Player: Player)
	self.Client.SendMessage:Fire(Player, Message)
	LogService:Log("Sent message to player:", Player.Name)
end

--[=[
Sends a chat message to every player in the server
]=]
function MessageService:SendMessage(Message: Core.ChatMessage)
	for _, Player: Player in pairs(game.Players:GetPlayers()) do
		self.Client.SendMessage:Fire(Player, Message)
	end
	LogService:Log("Sent message to all players")
end

--[[ KNIT ]]
--

function MessageService:KnitStart()
	LogService = Knit.GetService("LogService")

	game.Players.PlayerAdded:Connect(function(Player)
		local Message: Core.ChatMessage = {
			Message = Player.DisplayName .. " (@" .. Player.Name .. ") joined the game!",
			HasPrefix = false,
		}

		for _, v in pairs(game.Players:GetPlayers()) do
			if Player.UserId == v.UserId then
				continue
			end
			MessageService:SendMessageToPlayer(Message, v)
		end
	end)

	game.Players.PlayerRemoving:Connect(function(Player)
		local Message: Core.ChatMessage = {
			Message = Player.DisplayName .. " (@" .. Player.Name .. ") left the game!",
			HasPrefix = false,
		}

		MessageService:SendMessage(Message)
	end)
end

return MessageService
