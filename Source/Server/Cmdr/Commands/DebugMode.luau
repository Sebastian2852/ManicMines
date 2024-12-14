local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
    Name = "debugmode";
    Aliases = {};
    Description = "Toggle debug mode";
    Group = "";
    Args = {};

    ClientRun = function()
        local DebugModeValue = ReplicatedStorage.Player.Debug.DebugMode
        DebugModeValue.Value = not DebugModeValue.Value

        return "Debug mode turned "..(DebugModeValue.Value and "ON" or "OFF")
    end;
}