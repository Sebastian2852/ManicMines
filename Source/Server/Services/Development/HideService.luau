local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)
local Profiler = require(ReplicatedStorage.Game.Modules.Profiler)

local HideService = Knit.CreateService({
	Name = "HideService",
	Client = {},
})

local HideTag = "_Hide"

--[[ PUBLIC ]]
--

HideService.HiddenObjects = {}

--[=[
Hide a given object, makes it invisible and disables all events for it
]=]
function HideService:Hide(Object: BasePart | Decal | Light)
	local Objects = Object:GetDescendants()
	table.insert(Objects, Object)

	for _, Thing: BasePart | Decal | Light in pairs(Objects) do
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
			Logger:Warn("Cannot hide " .. Core.Util:LogObjectString(Thing) .. " unsupported type")
			continue
		end

		table.insert(self.HiddenObjects, Thing)
		Logger:Log("Hidden " .. Core.Util:LogObjectString(Thing))
	end
end

--[[ KNIT ]]
--

function HideService:KnitStart()
	local Timer = Profiler.Timer.new("[HIDE SERVICE] Hide objects")
	local Tagged = CollectionService:GetTagged(HideTag)

	for _, Object in pairs(Tagged) do
		self:Hide(Object)
	end

	Timer:Stop()
end

return HideService
