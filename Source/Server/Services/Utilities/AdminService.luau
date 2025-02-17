local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local AdminService = Knit.CreateService {
	Name = "AdminService",
	Client = {},
}

local PlayerStatsService

-- [[ PUBLIC ]] --

--[=[
Checks if the given player is in the admin table in game config
]=]
function AdminService:IsPlayerAdmin(Player: Player): boolean
	local UserID = Player.UserId
	local Admins = Core.GameConfig.Admins.Admins

	for AdminID: number, _ in pairs(Admins) do
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
function AdminService:GetAdminPermissions(Player: Player): Core.AdminPermissions
	if not self:IsPlayerAdmin(Player) then
		return {}
	end
	return Core.GameConfig.Admins.Admins[Player.UserId]
end

--[=[
returns true/false if the passed player has the given permission
]=]
function AdminService:HasPermission(Player: Player, Permission: string): boolean
	if not self:IsPlayerAdmin(Player) then
		return false
	end
	local Permissions = self:GetAdminPermissions(Player)
	return Permissions[Permission] :: boolean
end

-- [[ CLIENT ]] --

function AdminService.Client:IsPlayerAdmin(Player: Player)
	return self.Server:IsPlayerAdmin(Player)
end

function AdminService.Client:GetPermissions(Player: Player)
	return self.Server:GetAdminPermissions(Player)
end

function AdminService.Client:GiveOre(Admin: Player, Player: Player, OreName: string, Amount: number)
	if not self:IsPlayerAdmin(Admin) then
		return
	end
	if not self.Server:HasPermission(Admin, "GiveOres") then
		return
	end

	local OreList = Core.OreList.CreateFromOre(OreName, Amount)
	PlayerStatsService:GiveOres(Player, OreList)
	OreList:Destroy()
end

function AdminService.Client:TakeOre(Admin: Player, Player: Player, OreName: string, Amount: number)
	if not self:IsPlayerAdmin(Admin) then
		return
	end
	if not self.Server:HasPermission(Admin, "TakeOres") then
		return
	end

	local OreList = Core.OreList.CreateFromOre(OreName, Amount)
	PlayerStatsService:TakeOres(Player, OreList)
	OreList:Destroy()
end

--[[ KNIT ]]
--

function AdminService:KnitStart()
	PlayerStatsService = Knit.GetService("PlayerStatsService")
end

return AdminService
