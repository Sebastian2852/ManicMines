local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Iris = require(ReplicatedStorage.Packages.Iris)

local IrisController = Knit.CreateController { Name = "IrisController" }

IrisController.EnableDevMode = false
local LogService

local LogBuffer = {}
local LogSearch = ""

local function NewLog(Messages)
    local Message = ""

    for _, Msg in pairs(Messages) do
        Message = Message.." "..tostring(Msg)
    end

    table.insert(LogBuffer, Message)
end

function IrisController:Console()
    Iris.Window({
        [Iris.Args.Window.Title] = "Console",
        [Iris.Args.Window.NoClose] = true,
    })
        Iris.SameLine()
            if Iris.Button({"Clear console"}).clicked() then
                LogBuffer = {}
            end
            LogSearch = Iris.InputText({"", "Search filter"})
        Iris.End()

        for _, Log in ipairs(LogBuffer) do
            if string.find(string.lower(Log), string.lower(LogSearch.text.value)) then
                Iris.Text({Log})
            end
        end
    Iris.End()
end

function IrisController:Update()
    if self.EnableDevMode then
        self:Console()
    end
end

function IrisController:KnitInit()
    LogService = Knit.GetService("LogService")
    local UserInputService = game:GetService("UserInputService")

    LogService.ActionLog:Connect(function(Color :Color3, ...)
        local Args = {...}
        NewLog(Args)
    end)

    Iris.Init()
    Iris:Connect(function()
        self:Update()
    end)

    UserInputService.InputBegan:Connect(function(Input, Processed)
        if Processed then return end
        if Input.KeyCode ~= Enum.KeyCode.P then return end

        self.EnableDevMode = not self.EnableDevMode
    end)
end

return IrisController
