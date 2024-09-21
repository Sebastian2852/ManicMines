local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local AdminService = Knit.CreateService {
    Name = "AdminService",
    Client = {},
}

-- [[ PUBLIC ]] --

--[=[
Checks if the given player is in the admin table in game config
]=]
function AdminService:IsPlayerAdmin(Player :Player) :boolean
    local UserID = Player.UserId
    local Admins = Core.GameConfig.Admins.Admins

    for AdminID :number, Permissions :Core.AdminPermissions in pairs(Admins) do
        if AdminID == UserID then
            return true
        end
    end

    return false
end



-- [[ CLIENT ]] --

--[=[
Checks if the given player is in the admin table in game config
]=]
function AdminService.Client:IsPlayerAdmin(Player :Player)
    return self.Server:IsPlayerAdmin(Player)
end

return AdminService
