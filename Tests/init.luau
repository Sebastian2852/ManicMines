local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tests = {}

local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

--[=[
Runs all available tests
]=]
function Tests:RunTests()
    TestEZ.TestBootstrap:run(script:GetChildren())
end

return Tests