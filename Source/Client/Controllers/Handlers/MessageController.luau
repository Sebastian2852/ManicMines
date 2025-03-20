local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)

local MessageController = Knit.CreateController({ Name = "MessageController" })

local MessageService

local TextChannel

--[[ PRIVATE ]]
--

local function SendChatMessage(MessageInfo: Core.ChatMessage)
	local Message = MessageInfo.Message
	local Color = MessageInfo.MessageColor or Color3.new(1, 1, 1)

	if MessageInfo.HasPrefix then
		Message = "[" .. MessageInfo.Prefix .. "] " .. Message
	end

	TextChannel:SendAsync(Message, `{Color.R};{Color.G};{Color.B}`)
	Logger:Log("Sent chat message:", Message)
end

--[[ KNIT ]]
--

function MessageController:KnitInit()
	TextChannel = Instance.new("TextChannel")
	TextChannel.Name = "SystemMessages"
	TextChannel.Parent = TextChatService
	Logger:Log("Created text channel")
end

function MessageController:KnitStart()
	MessageService = Knit.GetService("MessageService")

	MessageService.SendMessage:Connect(function(MessageInfo: Core.ChatMessage)
		Logger:Log("New chat message from server")
		Logger:Log("    - Message:", MessageInfo.Message)
		Logger:Log("    - HasPrefix:", tostring(MessageInfo.HasPrefix))
		Logger:Log("    - Prefix:", MessageInfo.Prefix)

		SendChatMessage(MessageInfo)
	end)

	MessageService.EnableChannels:Connect(function()
		TextChatService:WaitForChild("ChannelTabsConfiguration").Enabled = true
	end)

	task.wait(1)

	local JoinMessage: Core.ChatMessage = {
		Message = Knit.Player.DisplayName .. " (@" .. Knit.Player.Name .. ") joined the game!",
		HasPrefix = false,
	}
	SendChatMessage(JoinMessage)
end

return MessageController
