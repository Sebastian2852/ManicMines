local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)
local Roact = require(ReplicatedStorage.Packages.Roact)

local StorageController = Knit.CreateController({ Name = "StorageController" })

local StorageService

local ActiveGUI = nil

-- [[ PUBLIC ]] --

function StorageController:OpenGUI()
	self:CloseGUI()

	local App = Roact.createElement(require(ReplicatedStorage.Game.GUI.Storage), {
		Close = function()
			self:CloseGUI()
		end,
	})
	ActiveGUI = Roact.mount(App, Knit.Player.PlayerGui, "Storage")
	Logger:Log("Mounted storage component")
end

function StorageController:CloseGUI()
	if ActiveGUI ~= nil then
		Roact.unmount(ActiveGUI)
		ActiveGUI = nil
	end
end

-- [[ KNIT ]] --

function StorageController:KnitStart()
	StorageService = Knit.GetService("StorageService")

	StorageService.OpenStorage:Connect(function()
		self:OpenGUI()
	end)
end

return StorageController
