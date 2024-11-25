local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CaveService = Knit.CreateService {
    Name = "CaveService",
    Client = {},
}

return CaveService