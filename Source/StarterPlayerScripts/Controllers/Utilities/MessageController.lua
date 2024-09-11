local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MessageController = Knit.CreateController { Name = "MessageController" }

--[[ PRIVATE ]]--

local LogService
local MessageService
local TextChannel

local function SendChatMessage(MessageInfo :Core.ChatMessage)
    local Message = MessageInfo.Message

    if MessageInfo.HasPrefix then
        Message = "["..MessageInfo.Prefix.."] "..Message
    end

    TextChannel:SendAsync(Message)
    LogService:Log("Sent chat message")
end

--[[ KNIT ]]--

function MessageController:KnitInit()
    LogService = Knit.GetService("LogService")

    TextChannel = Instance.new("TextChannel")
    TextChannel.Name = "MM_SystemMessages"
    TextChannel.Parent = game.TextChatService
    LogService:Log("Created text channel")
end

function MessageController:KnitStart()
    MessageService = Knit.GetService("MessageService")
    MessageService.SendMessage:Connect(function(MessageInfo :Core.ChatMessage)
        LogService:Log("New chat message from server")
        LogService:Log("    - Message:", MessageInfo.Message)
        LogService:Log("    - HasPrefix:", tostring(MessageInfo.HasPrefix))
        LogService:Log("    - Prefix:", MessageInfo.Prefix)

        SendChatMessage(MessageInfo)
    end)

    task.wait(1)

    local JoinMessage :Core.ChatMessage = {
        Message = Knit.Player.DisplayName.."(@"..Knit.Player.Name..") joined the game!";
        HasPrefix = false;
    }
    SendChatMessage(JoinMessage)
end

return MessageController
