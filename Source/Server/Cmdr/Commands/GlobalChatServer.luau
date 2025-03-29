local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

return function(_, Message: string)
	local MessageService = Knit.GetService("MessageService")
	MessageService:SendMessageToAllServers({
		Message = Message,
		Prefix = "",
		HasPrefix = false,
		MessageColor = Color3.fromRGB(255, 255, 255),
	})
end
