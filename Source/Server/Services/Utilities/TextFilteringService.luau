local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TextFilteringService = Knit.CreateService {
	Name = "TextFilteringService",
	Client = {},
}

-- [[ PUBLIC ]] --

--[=[
Filter a string that the player wrote so that anyone can view it
]=]
function TextFilteringService:FilterTextFromUserToEveryone(Player: Player, RawText: string): string
	local Filtered = TextService:FilterStringAsync(RawText, Player.UserId, Enum.TextFilterContext.PublicChat)
	return Filtered:GetNonChatStringForBroadcastAsync()
end

--[=[
Filter a string that a player wrote for another spesific player
]=]
function TextFilteringService:FilterTextFromUserToUser(Player: Player, RawText: string, ToPlayer: Player): string
	local Filtered = TextService:FilterStringAsync(RawText, Player.UserId, Enum.TextFilterContext.PrivateChat)
	return Filtered:GetNonChatStringForUserAsync(ToPlayer.UserId)
end

-- [[ CLIENT ]] --

function TextFilteringService.Client:FilterTextFromUserToEveryone(Player: Player, RawText: string): string
	return TextFilteringService:FilterTextFromUserToEveryone(Player, RawText)
end

function TextFilteringService.Client:FilterTextFromUserToUser(Player: Player, RawText: string): string
	return TextFilteringService:FilterTextFromUserToUser(Player, RawText)
end

return TextFilteringService
