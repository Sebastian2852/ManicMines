local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Core = require(ReplicatedStorage.Game.Modules.Core)

return function(Registry)
	Registry:RegisterHook("BeforeRun", function(Context)
		if Context.Group == "DefaultAdmin" and not Core.GameConfig.Admins.Admins[Context.Executor.UserId] then
			return "You do not have permission to run this command."
		end
	end)
end
