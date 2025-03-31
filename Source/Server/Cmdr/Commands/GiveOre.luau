return {
	Name = "giveore",
	Aliases = {},
	Description = "Shows all commands and how to use them",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "Who to give the ore to",
		},
		{
			Type = "ore",
			Name = "Ore",
			Description = "The ore to give",
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "How much to give the player",
		},
	},
}
