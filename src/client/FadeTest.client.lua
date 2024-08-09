local Knit = require(game.ReplicatedStorage.Packages.Knit)
local UserInputService = game:GetService("UserInputService")

-- there has to be some other way of doing this
-- This seems like it def has a better way of doing
repeat
    task.wait(0.01)
until Knit.ControllersReady

local FadeController = Knit.GetController("FadeController")
local LogService = Knit.GetService("LogService")

UserInputService.InputBegan:Connect(function(Input)
    LogService:Log("Awesome!")
    if Input.KeyCode == Enum.KeyCode.Z then
        FadeController:FadeGameplayOut(false);
        return
    end

    if Input.KeyCode == Enum.KeyCode.X then
        FadeController:FadeGameplayIn(false);
        return
    end
end)