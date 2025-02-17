local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

return {
	Name = "movetostorage",
	Aliases = {},
	Description = "Shows all commands and how to use them",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "Ore name",
			Description = "The name of the ore to move",
		},
		{
			Type = "integer",
			Name = "Amount",
			Description = "The amount of ore to move",
		},
	},

	ClientRun = function(_, OreName: string, Amount: number)
		local StorageService = Knit.GetService("StorageService")
		local Success
		StorageService:MoveToStorage(OreName, Amount)
			:andThen(function(WasSuccess)
				Success = WasSuccess
			end)
			:await()

		if Success then
			return "Moved " .. Amount .. " " .. OreName .. " into storage"
		end
		return "Failed"
	end,
}
