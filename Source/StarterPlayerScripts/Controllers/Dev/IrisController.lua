local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Iris = require(ReplicatedStorage.Packages.Iris)

local IrisController = Knit.CreateController { Name = "IrisController" }

function IrisController:Update()
    Iris.ShowDemoWindow()
end

function IrisController:KnitInit()
    Iris.Init()
    Iris:Connect(function()
        self:Update()
    end)
end

return IrisController
