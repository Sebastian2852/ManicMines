local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)

local TestComponent = Component.new({
    Tag = "TestComp";
    Ancestors = {workspace};
})

function TestComponent:Construct()
    print("Component constructed")
end

function TestComponent:Start()
    print("Component started")
end

function TestComponent:Stop()
    print("Component stopped")
end

return TestComponent