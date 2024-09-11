local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local ManicDMRController = Knit.CreateController { Name = "ManicDMRController" }

local UnloadedFolder
local TycoonsFolder = workspace:WaitForChild("Game"):WaitForChild("Tycoons")

ManicDMRController.UnloadedAssets = {}

--[=[
Unloads every tycoon and returns their index in the unloaded assets table
]=]
function ManicDMRController:UnloadAllTycoons() :{number}
    local Tycoons = TycoonsFolder:GetChildren()
    local Indexes = {}

    for _, Tycoon in pairs(Tycoons) do
        Tycoon.Parent = UnloadedFolder
        table.insert(self.UnloadedAssets, Tycoon)
        -- Possibly optimize by starting at the second or third last index
        -- Since the newly added tycoon should be at the end
        table.insert(Indexes, table.find(self.UnloadedAssets, Tycoon, 0))
    end

    return Indexes
end

--[[ KNIT ]]--

function ManicDMRController:KnitInit()
    UnloadedFolder = Instance.new("Folder")
    UnloadedFolder.Name = "MDMR_Unloaded"
    UnloadedFolder.Parent = game.ReplicatedStorage
end


return ManicDMRController
