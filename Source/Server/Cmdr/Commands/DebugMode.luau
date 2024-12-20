local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
return {
    Name = "debugmode";
    Aliases = {};
    Description = "Toggle debug mode";
    Group = "";
    Args = {};

    ClientRun = function()
        if not RunService:IsStudio() then
            return "This command is can only be ran in studio"
        end

        local DebugModeValue = ReplicatedStorage.Player.Debug.DebugMode
        DebugModeValue.Value = not DebugModeValue.Value

        return "Debug mode turned "..(DebugModeValue.Value and "ON" or "OFF")
    end;
}