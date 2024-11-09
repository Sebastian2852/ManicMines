local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[=[
THIS SYSTEM NEEDS TO BE REWORKED

Currently it does everything at the start of the game. That is fine until we conisder things like other players. If you were to invite someone they could use your
upgrades as their own, which shouldn't happen.

The way it is setup right now it is impossible to do the above nor pass anything like "TycoonOwner" or "Level". So rather than doing everything at the start we should do it
by getting the tycoon service to tell us when a new upgrade has been made and then check if anything has a matching tag then set it up right then and there.
]=]

local Knit = require(ReplicatedStorage.Packages.Knit)

local TycoonUpgradeService = Knit.CreateService {
    Name = "TycoonUpgradeService";
    Client = {
        OpenStorage = Knit.CreateSignal();
    };
}

type TagFunctions = {
    CreatePrompt :(Level :number, MaxLevel :number) -> (string, string);
    Triggered :(Player :Player, Level :number) -> nil;
}

local LogService

-- [[ PUBLIC ]] --

TycoonUpgradeService.Tags = {
    -- ["_StorageUpgrade"] = function(Part)
    --     local ProximityPrompt = Instance.new("ProximityPrompt")
    --     ProximityPrompt.Name = "OpenStoragePrompt"
    --     ProximityPrompt.ActionText = "Open"
    --     ProximityPrompt.ObjectText = "Storage"
    --     ProximityPrompt.HoldDuration = 0
    --     ProximityPrompt.Style = Enum.ProximityPromptStyle.Custom
    --     ProximityPrompt.Parent = Part

    --     ProximityPrompt.Triggered:Connect(function(Player)
    --         TycoonUpgradeService.Client.OpenStorage:Fire(Player)
    --     end)
    -- end;
}

function TycoonUpgradeService:Dispatch(Part :BasePart, Tag :string)
    LogService:Log("Dispatching upgrade part ("..Part:GetFullName()..") for setup with tag: "..Tag)
    -- self.Tags[Tag](Part)
end



-- [[ KNIT ]] --

--[=[
Parse setup modules
]=]
-- function TycoonUpgradeService:KnitInit()
--     LogService = Knit.GetService("LogService")

--     LogService:Log("Parsing tycoon setup modules")
--     local Setups = ServerScriptService.Game.TycoonUpgrades

--     for _, SetupModule :ModuleScript in pairs(Setups:GetChildren()) do
--         if not SetupModule:IsA("ModuleScript") then
--             LogService:Warn("Non module script file found in setups folder:", SetupModule:GetFullName())
--             continue
--         end

--         local Tag = SetupModule.Name
--         local Functions = require(SetupModule)
--         self.Tags[Tag] = Functions
--     end

--     LogService:Log("Finished parsing tycoon setups, result:", self.Tags)
-- end

--[=[
Create prompts and setup trigger events
]=]
-- function TycoonUpgradeService:KnitStart()
--     LogService:Log("Creating prompts for all upgrades; connecting events")

--     for Tag :string, Functions :TagFunctions in pairs(self.Tags) do
--         local TaggedParts = CollectionService:GetTagged(Tag)
--         for _, TaggedPart :BasePart in pairs(TaggedParts) do
--             local ObjectText, ActionText = Functions.CreatePrompt(0, 0)
--             local NewPrompt = Instance.new("ProximityPrompt")
--             NewPrompt.Name = "UpgradeFunctionPrompt"
--             NewPrompt.Style = Enum.ProximityPromptStyle.Custom
--             NewPrompt.ObjectText = ObjectText
--             NewPrompt.ActionText = ActionText
--             NewPrompt.Parent = TaggedPart

--             NewPrompt.Triggered:Connect(function(PlayerWhoTriggered)
--                 Functions.Triggered(PlayerWhoTriggered, 0)
--             end)
--         end
--     end
-- end

return TycoonUpgradeService