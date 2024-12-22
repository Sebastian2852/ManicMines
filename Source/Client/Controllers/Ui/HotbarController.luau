local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local NeoHotbar = require(ReplicatedStorage.Packages.NeoHotbar)

local HotbarController = Knit.CreateController { Name = "HotbarController" }

-- [[ PUBLIC ]] --

--[=[
Makes the hotbar invisible
]=]
function HotbarController:DisableHotbar()
    NeoHotbar:SetEnabled(false)
end

--[=[
Makes the hotbar visible
]=]
function HotbarController:EnableHotbar()
    NeoHotbar:SetEnabled(true)
end

--[=[
Allows tooltips to show up
]=]
function HotbarController:EnableTooltips()
    NeoHotbar:SetToolTipsEnabled(true)
end

--[=[
Stops tooltips from showing
]=]
function HotbarController:DisableTooltips()
    NeoHotbar:SetToolTipsEnabled(true)
end



-- [[ KNIT ]] --

function HotbarController:KnitStart()
    NeoHotbar:Start()
end

return HotbarController