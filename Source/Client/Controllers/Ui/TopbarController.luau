local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local TopbarPlus = require(ReplicatedStorage.Packages.TopbarPlus)

local TopbarController = Knit.CreateController { Name = "TopbarController" }

--[=[
Create a text element in the top bar with the given text
]=]
function TopbarController:CreateLabel(Text :string)
    TopbarPlus.new():setLabel(Text):disableOverlay(true):lock()
end



-- [[ KNIT ]] --

function TopbarController:KnitInit()
    self:CreateLabel("v 1.0.0")
end

return TopbarController