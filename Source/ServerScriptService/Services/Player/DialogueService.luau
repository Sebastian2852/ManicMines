local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local DialogueService = Knit.CreateService {
    Name = "DialogueService",
    Client = {
        StartDialogue = Knit.CreateSignal();
    },
}

local LogService

type DialogueChoice = {
    Text :string;
    Index :number;
    CanLeave :boolean;
    LeaveText :string?;
    Choices :{[string] :DialogChoice};
}

type InfoModule = {
    NpcName :string;
    InteractMessage :string;
    Dialogue :DialogueChoice;
}

-- [[ PUBLUC ]] --

DialogueService.ProximityPromptTag = "Dialogue/Prompt/Generated"
DialogueService.ModuleTag = "Dialogue/Module/Config"

function DialogueService:ConnectNpcsWithModules(Modules :{ModuleScript})
    local New = {}

    for _, Module in pairs(Modules) do
        local Npc = Module.Parent
        New[Npc] = Module
    end

    return New
end

-- [[ CLIENT ]] --

function DialogueService.Client:GetTags() :(string, string)
    return self.Server.ProximityPromptTag, self.Server.ModuleTag
end

-- [[ KNIT ]] --

function DialogueService:KnitStart()
    LogService = Knit.GetService("LogService")

    local Modules = CollectionService:GetTagged(self.ModuleTag)

    LogService:Log("Sorting NPCs with their modules")
    local NpcsSorted = self:ConnectNpcsWithModules(Modules)

    LogService:Log("Creating proximity prompts", NpcsSorted)
    for Npc, Module in pairs(NpcsSorted) do
        local Info :InfoModule = require(Module)

        local ProximityPrompt = Instance.new("ProximityPrompt")
        ProximityPrompt.Name = "DialogueInteraction"
        ProximityPrompt.ObjectText = Info.NpcName
        ProximityPrompt.ActionText = Info.InteractMessage
        ProximityPrompt:AddTag(self.ProximityPromptTag)
        ProximityPrompt.RequiresLineOfSight = false
        ProximityPrompt.Parent = Npc

        ProximityPrompt.Triggered:Connect(function(Player)
            self.Client.StartDialogue:Fire(Player, Info, Module:FindFirstChildWhichIsA("BasePart"))
        end)

        LogService:Log("Created proximity prompt for: "..Info.NpcName)
    end
end

return DialogueService