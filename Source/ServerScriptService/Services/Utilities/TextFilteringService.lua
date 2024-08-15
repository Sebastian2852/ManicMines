local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)

local TextFilteringService = Knit.CreateService {
    Name = "TextFilteringService",
    Client = {},
}

local TextService = game:GetService("TextService")

function TextFilteringService:FilterTextFromUserToEveryone(Player :Player, RawText :string) :string
    local Filtered = TextService:FilterStringAsync(RawText, Player.UserId, Enum.TextFilterContext.PublicChat)
    return Filtered:GetNonChatStringForBroadcastAsync()
end

function TextFilteringService.Client:FilterTextFromUserToEveryone(Player :Player, RawText :string) :string
    return TextFilteringService:FilterTextFromUserToEveryone(Player, RawText)
end


function TextFilteringService:FilterTextFromUserToUser(Player :Player, RawText :string, ToPlayer :Player) :string
    local Filtered = TextService:FilterStringAsync(RawText, Player.UserId, Enum.TextFilterContext.PrivateChat)
    return Filtered:GetNonChatStringForUserAsync(ToPlayer.UserId)
end

function TextFilteringService.Client:FilterTextFromUserToUser(Player :Player, RawText :string) :string
    return TextFilteringService:FilterTextFromUserToUser(Player, RawText)
end


return TextFilteringService
