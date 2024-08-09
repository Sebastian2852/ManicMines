local Knit = require(game.ReplicatedStorage.Packages.Knit)

local PickaxeController = Knit.CreateController { 
    Name = "PickaxeController"
}


function PickaxeController:SetupPickaxe(Pickaxe :Tool)
    local DupeScript = script.Parent.Parent.Scripts.Pickaxe:Clone()
    DupeScript.Parent = Pickaxe
end


--[[ KNIT ]]--

function PickaxeController:KnitStart()
    local Backpack = Knit.Player.Backpack
    Backpack.ChildAdded:Connect(function(Child)
        if Child:IsA("Tool") and Child:HasTag("Pickaxe") then
            self:SetupPickaxe(Child)
        end
    end)

    for _, Child in pairs(Backpack:GetChildren()) do
        if Child:IsA("Tool") and Child:HasTag("Pickaxe") then
            self:SetupPickaxe(Child)
            break
        end
    end
end

return PickaxeController
