local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UIService = Knit.CreateService {
    Name = "UIService",
    Client = {
        Inventory = Knit.CreateSignal();
        HUDButtons = Knit.CreateSignal();
    },
}

local LogService

-- [[ PUBLIC ]] --

--[=[
Toggles the given player's inventory
]=]
function UIService:ToggleInventory(Player :Player, New :boolean)
    self.Client.Inventory:Fire(Player, New)
    LogService:Log("Toggling inventory "..tostring(New).." for "..Player.Name)
end

--[=[
Hides the given player's inventory
]=]
function UIService:HideInventory(Player :Player)
    self:ToggleInventory(Player, false)
end

--[=[
Shows the given player's inventory
]=]
function UIService:ShowInventory(Player :Player)
    self:ToggleInventory(Player, true)
end


--[=[
Toggles any HUD buttons for the given player
]=]
function UIService:ToggleHUDButtons(Player :Player, New :boolean)
    self.Client.HUDButtons:Fire(Player, New)
    LogService:Log("Toggling HUD buttons "..tostring(New).." for "..Player.Name)
end

--[=[
Hides any buttons in the HUD
]=]
function UIService:HideHUDButtons(Player :Player)
    self:ToggleHUDButtons(Player, false)
end

--[=[
Shows any buttons in the HUD
]=]
function UIService:ShowHUDButtons(Player :Player)
    self:ToggleHUDButtons(Player, true)
end



-- [[ CLIENT ]] --

--[=[
Toggle the inventory
]=]
function UIService.Client:ToggleInventory(Player :Player, New :boolean)
    self.Server:ToggleInventory(Player, New)
end

--[=[
Toggle any HUD buttons
]=]
function UIService.Client:ToggleHUDButtons(Player :Player, New :boolean)
    self.Server:ToggleHUDButtons(Player, New)
end



-- [[ KNIT ]] --

function UIService:KnitStart()
    LogService = Knit.GetService("LogService")
end

return UIService