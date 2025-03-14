local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Game.Modules.Core)

return {
	Name = "GetSlotInfo",
	Aliases = {},
	Description = "Get the info of a a player's loaded slot",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "Player to check",
		},
	},

	ClientRun = function(_, Player: Player)
		local DataFolder = ReplicatedStorage.PlayerData:FindFirstChild(Player.UserId) :: Core.DataFolder
		if not DataFolder then
			return "Player doesn't have a data folder"
		end

		if not DataFolder.DataLoaded.Value then
			return "Player doesn't have any loaded data"
		end

		local StoneMined = DataFolder.TimesMined.Stone.Value
		local TotalBlocksMined = 0

		for _, OreMined: IntValue in pairs(DataFolder.TimesMined:GetChildren()) do
			TotalBlocksMined += OreMined.Value
		end

		local TotalOresMined = TotalBlocksMined - StoneMined

		return `{Player.Name}'s slot was created on version "{DataFolder.VersionCreated.Value}" and was last played on version "{DataFolder.LastVersionPlayed.Value}" (not including this session). They have mined {TotalBlocksMined} blocks in total (of which {StoneMined} is stone and {TotalOresMined} is ores)`
	end,
}
