local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PlayerDataFolder :Folder = nil
local HUDGUI = Knit.Player.PlayerGui:WaitForChild("HUD")

local HUDController = Knit.CreateController {
    Name = "HUDController"
}

function HUDController:UpdateGold()
    local NewGoldAmount :IntValue = PlayerDataFolder:FindFirstChild("Gold").Value
    HUDGUI.Gold.Amount.Text = tostring(NewGoldAmount)
end



--[[ KNIT ]]--

--[[
Setup events for values changing to update their UI as well as getting the player's data folder
]]--
function HUDController:KnitInit()
    PlayerDataFolder = game.ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(Knit.Player.UserId)

    PlayerDataFolder:FindFirstChild("Gold"):GetPropertyChangedSignal("Value"):Connect(function()
        self:UpdateGold()
    end)
end

--[[
Update all UIs on start
]]--
function HUDController:KnitStart()
   self:UpdateGold() 
end


return HUDController
