return {
	Name = "DumpOres",
	Aliases = {},
	Description = "Moves all ores from inventory to storage",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The player that is affected",
			Optional = true,
		},
	},
}
