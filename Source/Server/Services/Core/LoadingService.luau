local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LoadingService = Knit.CreateService({
	Name = "LoadingService",
	Client = {
		LoadingStarted = Knit.CreateSignal(),
		LoadingEnded = Knit.CreateSignal(),
		UpdateActionText = Knit.CreateSignal(),
	},
})

local LogService
LoadingService.Players = {}

-- [[ PUBLIC ]] --

--[=[
Start a loading screen for the given player
]=]
function LoadingService:StartLoading(Player: Player)
	if self.Players[Player.UserId] then
		LogService:Warn("Player is already loading: " .. Player.Name)
		return
	end

	LogService:Log("Starting loading for player: " .. Player.Name)
	self.Players[Player.UserId] = true
	self.Client.LoadingStarted:Fire(Player)
end

--[=[
Stop the loading screen for the given player
]=]
function LoadingService:EndLoading(Player: Player)
	if not self.Players[Player.UserId] then
		LogService:Warn("Player is not currently loading: " .. Player.Name)
		return
	end

	LogService:Log("Stopping loading for player: " .. Player.Name)
	self.Client.LoadingEnded:Fire(Player)
	self.Players[Player.UserId] = false
end

--[=[
Update the text that says what is loading for the given player with the given text
]=]
function LoadingService:UpdateActionText(Player: Player, Text: string)
	self.Client.UpdateActionText:Fire(Player, Text)
end

-- [[ CLIENT ]] --

function LoadingService.Client:StartLoading(Player)
	self.Server:StartLoading(Player)
end

function LoadingService.Client:EndLoading(Player)
	self.Server:EndLoading(Player)
end

-- [[ KNIT ]] --

function LoadingService:KnitStart()
	LogService = Knit.GetService("LogService")
end

return LoadingService
