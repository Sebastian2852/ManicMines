local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Enums = require(ReplicatedStorage.Game.Modules.Enums)
local Knit = require(ReplicatedStorage.Packages.Knit)

--[=[
Despite the name this is just a controller to get device type and stuff
]=]

local DeviceController = Knit.CreateController({ Name = "DeviceController" })

local LastDeviceType = Enums.DeviceType.Unkown

--[=[
Fires whenever the player's device is changed
]=]
DeviceController.DeviceChanged = nil

--[=[
Returns the current device type for the player
]=]
function DeviceController:GetDeviceType(): Enums.Enum
	local DeviceType = Enums.DeviceType.Unkown

	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
		DeviceType = Enums.DeviceType.Mobile
	elseif UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
		DeviceType = Enums.DeviceType.PC
	elseif UserInputService.GamepadEnabled then
		DeviceType = Enums.DeviceType.Console
	end

	if DeviceType ~= LastDeviceType then
		LastDeviceType = DeviceType
	end
	return DeviceType
end

-- [[ KNIT ]] --

function DeviceController:KnitInit()
	local DeviceChangedEvent = Instance.new("BindableEvent")
	self.DeviceChanged = DeviceChangedEvent.Event
	self.DeviceChangedObj = DeviceChangedEvent
end

function DeviceController:KnitStart()
	local DeviceChangedEvent = self.DeviceChangedObj

	local DeviceType = self:GetDeviceType()
	DeviceChangedEvent:Fire(DeviceType)

	UserInputService.InputBegan:Connect(function()
		local NewDeviceType = self:GetDeviceType()
		if NewDeviceType == LastDeviceType then
			return
		end
		LastDeviceType = DeviceType
		DeviceChangedEvent:Fire(NewDeviceType)
	end)

	UserInputService.LastInputTypeChanged:Connect(function()
		local NewDeviceType = self:GetDeviceType()
		if NewDeviceType == LastDeviceType then
			return
		end
		LastDeviceType = DeviceType
		DeviceChangedEvent:Fire(NewDeviceType)
	end)
end

return DeviceController
