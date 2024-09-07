local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MessageController = Knit.CreateController { Name = "MessageController" }

--[[ PRIVATE ]]--

local LogService
local MessageService
local TextChannel

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
        local Message = MessageInfo.Message

        LogService:Log("New chat message from server")
        LogService:Log("    - Message:", Message)
        LogService:Log("    - HasPrefix:", tostring(MessageInfo.HasPrefix))

        if MessageInfo.HasPrefix then
            LogService:Log("    - Prefix:", MessageInfo.Prefix)
            Message = "["..MessageInfo.Prefix.."] "..Message
        end

        TextChannel:SendAsync(Message)
    end)
end

return MessageController
