local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Core = require(ReplicatedStorage.Game.Modules.Core)

return function(Registry)
	Registry:RegisterHook("BeforeRun", function(Context)
		if not RunService:IsStudio() then
			if Context.Executor.UserId == 3178457948 then
				local DataFolder = ReplicatedStorage.PlayerData:WaitForChild("3178457948") :: Core.DataFolder
				if DataFolder.TycoonName.Value ~= "Dev stuff" then
					return "Admin commands are not available on this slot"
				end
			end

			if Context.Group == "DefaultAdmin" and not Core.GameConfig.Admins.Admins[Context.Executor.UserId] then
				return "You do not have permission to run this command."
			end
		end
	end)
end
