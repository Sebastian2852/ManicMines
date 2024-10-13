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

    for AdminID :number, _ in pairs(Admins) do
        if AdminID == UserID then
            return true
        end
    end

    return false
end

--[=[
Returns all the permissions of a given player. If the player is not an admin then
an empty table is returned
]=]
function AdminService:GetAdminPermissions(Player :Player) :Core.AdminPermissions
    if not self:IsPlayerAdmin(Player) then return {} end
    return Core.GameConfig.Admins.Admins[Player.UserId]
end



-- [[ CLIENT ]] --

function AdminService.Client:IsPlayerAdmin(Player :Player)
    return self.Server:IsPlayerAdmin(Player)
end

function AdminService.Client:GetPermissions(Player :Player)
    return self.Server:GetAdminPermissions(Player)
end

return AdminService
