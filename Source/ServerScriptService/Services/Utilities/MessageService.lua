local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local MessageService = Knit.CreateService {
    Name = "MessageService",
    Client = {
        SendMessage = Knit.CreateSignal()
    },
}

local LogService

--[[ PUBLIC ]]--

--[=[
Sends a chat message to a player
]=]
function MessageService:SendMessageToPlayer(Message :Core.ChatMessage, Player :Player)
    self.Client.SendMessage:Fire(Player, Message)
    LogService:Log("Send message to player:", Player.Name)
end

--[=[
Sends a chat message to every player in the server
]=]
function MessageService:SendMessage(Message :Core.ChatMessage)
    for _, Player :Player in pairs(game.Players:GetPlayers()) do
        self.Client.SendMessage:Fire(Player, Message)
    end
    LogService:Log("Send message to all players")
end



--[[ KNIT ]]--

function MessageService:KnitStart()
    LogService = Knit.GetService("LogService")

    game.Players.PlayerAdded:Connect(function(Player)
        local Message :Core.ChatMessage = {
            Message = Player.DisplayName.." (@"..Player.Name..") joined the game!";
            HasPrefix = false;
        }
        MessageService:SendMessage(Message)
    end)
end

return MessageService
