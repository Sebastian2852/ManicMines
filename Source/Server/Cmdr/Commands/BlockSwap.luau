return {
	Name = "blockswap",
	Aliases = {},
	Description = "Swap the closest block to the given player with a given ore",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The player that is affected",
		},
		{
			Type = "ore",
			Name = "New block",
			Description = "The block to replace",
		},
	},
}
