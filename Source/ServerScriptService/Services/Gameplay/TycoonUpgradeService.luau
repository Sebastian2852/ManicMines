local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local TycoonUpgradeService = Knit.CreateService {
    Name = "TycoonUpgradeService";
    Client = {};
}

local LogService

-- [[ PUBLIC ]] --

TycoonUpgradeService.Tags = {
    ["_StorageUpgrade"] = function(Part)
        local ProximityPrompt = Instance.new("ProximityPrompt")
        ProximityPrompt.Name = "OpenStoragePrompt"
        ProximityPrompt.ActionText = "Open"
        ProximityPrompt.ObjectText = "Storage"
        ProximityPrompt.HoldDuration = 0
        ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
        ProximityPrompt.Parent = Part

        ProximityPrompt.Triggered:Connect(function(Player)
            print(Player, "opened storage")
        end)
    end;
}

function TycoonUpgradeService:Dispatch(Part :BasePart, Tag :string)
    self.Tags[Tag](Part)
end



-- [[ KNIT ]] --

function TycoonUpgradeService:KnitInit()
    LogService = Knit.GetService("LogService")

    for Tag :string, _ in pairs(self.Tags) do
        local Tagged = CollectionService:GetTagged(Tag)
        for _, Part :BasePart in pairs(Tagged) do
            self:Dispatch(Part, Tag)
        end
    end
end

return TycoonUpgradeService