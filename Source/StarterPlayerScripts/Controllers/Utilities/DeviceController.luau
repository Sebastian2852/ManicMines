local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Enums = require(ReplicatedStorage.Game.Modules.Enums)

--[=[
Despite the name this is just a controller to get device type and stuff
]=]

local DeviceController = Knit.CreateController { Name = "DeviceController" }

local LogService

local LastDeviceType = Enums.DeviceType.Unkown
DeviceController.DeviceChanged = nil

function DeviceController:GetDeviceType() :Enums.Enum
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

function DeviceController:KnitStart()
    LogService = Knit.GetService("LogService")

    local DeviceChangedEvent = Instance.new("BindableEvent")
    self.DeviceChanged = DeviceChangedEvent.Event

    local DeviceType = self:GetDeviceType()
    DeviceChangedEvent:Fire(DeviceType)

    UserInputService.InputBegan:Connect(function()
        local NewDeviceType = self:GetDeviceType()
        if NewDeviceType == LastDeviceType then return end
        LogService:Log("Enums:", Enums.DeviceType)
        LogService:Log("New device type:", NewDeviceType)
        LogService:Log("Last device type:", LastDeviceType)
        LastDeviceType = DeviceType
        DeviceChangedEvent:Fire(NewDeviceType)
    end)

    UserInputService.LastInputTypeChanged:Connect(function()
        local NewDeviceType = self:GetDeviceType()
        if NewDeviceType == LastDeviceType then return end
        LogService:Log("Enums:", Enums.DeviceType)
        LogService:Log("New device type:", NewDeviceType)
        LogService:Log("Last device type:", LastDeviceType)
        LastDeviceType = DeviceType
        DeviceChangedEvent:Fire(NewDeviceType)
    end)
end

return DeviceController