print("Setting up test env")

script.Parent.Parent.Game.KnitServerBootstrap.Enabled = false
require(game.ServerScriptService.Game.Services.DeveloperTools.LogService).LoggingEnabled = false

local LogService = game:GetService("LogService")
LogService:ClearOutput()

print("Test env ready")
local PackageTest = require(script.Parent.Packages)

local Results = {}
local PackagesResult = PackageTest()
table.insert(Results, PackagesResult)