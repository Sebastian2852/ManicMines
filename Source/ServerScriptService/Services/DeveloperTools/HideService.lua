local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local Core = require(ReplicatedStorage.Game.Modules.Core)

local CollectionService = game:GetService("CollectionService")

local HideService = Knit.CreateService {
    Name = "HideService",
    Client = {},
}

local LogService

local HideTag = "_Hide"

--[[ PUBLIC ]]--

HideService.HiddenObjects = {}

function HideService:Hide(Object :BasePart|Decal|Light)
    local Objects = Object:GetDescendants()
    table.insert(Objects, Object)

    for i, Thing :BasePart|Decal|Light in pairs(Objects) do
        if Thing:IsA("BasePart") then
            Thing.Transparency = 1
            Thing.CanCollide = false
            Thing.CanTouch = false
            Thing.CanQuery = false
        elseif Thing:IsA("Decal") then
            Thing.Transparency = 1
        elseif Thing:IsA("Light") then
            Thing.Enabled = false
        else
            LogService:Warn("Cannot hide "..Core.Util:LogObjectString(Thing).." unsupported type")
            continue
        end

        table.insert(self.HiddenObjects, Thing)
        LogService:Log("Hidden "..Core.Util:LogObjectString(Thing))
    end
end



--[[ KNIT ]]--

function HideService:KnitStart()
    LogService = Knit.GetService("LogService")

    local Timer = Core.Timer.new()
    Timer:Start()
    local Tagged = CollectionService:GetTagged(HideTag)

    for _, Object in pairs(Tagged) do
        self:Hide(Object)
    end

    local TimeTaken = Timer:End()
    LogService:Log("Hidden "..#self.HiddenObjects.." objects in "..tostring(TimeTaken).." seconds")
end

return HideService
