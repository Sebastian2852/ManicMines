local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

return function(_, Player :Player, OreName :string)
    local Character = Player.Character
    if not Character then
        return "Player doesnt have a character!"
    end
    local MineService = Knit.GetService("MineService")
    local Ore = Core.Util:GetOreByName(OreName)

    local ClosestBlock = MineService:GetClosestBlock(Character.PrimaryPart.Position, 12)
    if not ClosestBlock then
        return "Couldn't get closest block"
    end

    MineService:ReplaceBlockAtPosition(ClosestBlock.Position, Ore)
end