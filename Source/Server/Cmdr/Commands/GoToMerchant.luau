return {
	Name = "GoToMerchant",
	Aliases = {},
	Description = "Teleport the given player to the mystery merchant",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "Player to teleport",
			Optional = true,
		},
	},
}
