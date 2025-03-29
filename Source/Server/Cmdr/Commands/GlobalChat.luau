return {
	Name = "GlobalChat",
	Aliases = {},
	Description = "Say something in chat as the server for every server (including private servers)",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "Message",
			Description = "Message to say",
			Optional = false,
		},
	},
}
