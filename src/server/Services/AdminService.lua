local ReplicatedStorage = game.ReplicatedStorage
local Knit = require(ReplicatedStorage.Packages.Knit)

local AdminService = Knit.CreateService {
    Name = "AdminService",
    Client = {},
}

--[=[
A talbe of all the admin's user ids
]=]
AdminService.Admins = {
    3092257097
}

--[=[
All the settings for admin stuff
]=]
AdminService.Settings = {
    NoPermissionMessage = "You don't have permission to run this command";
    CommandDoesntExist = "This command doesnt exist";
    IncorrectUsage = "Incorrect usage";
}

--[=[
Returns true/false if given player is an admin or not
]=]
function AdminService:IsPlayerAdmin(Player :Player) :boolean
    if table.find(self.Admins, Player.UserId) then return true end
    return false
end

function AdminService.Client:IsPlayerAdmin(Player :Player)
    return AdminService:IsPlayerAdmin(Player)
end


return AdminService
