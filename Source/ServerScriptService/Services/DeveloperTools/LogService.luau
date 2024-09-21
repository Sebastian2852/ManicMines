local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TestService = game:GetService("TestService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local LogService = Knit.CreateService{
    Name = "LogService";
    Client = {
        ActionLog = Knit.CreateSignal()
    };
}

LogService.LoggingEnabled = true
LogService.WarningsEnabled = true
LogService.AssertsEnabled = true

--[[ PRIVATE ]]--

local function SendLogToPlayers(Color :Color3, ...)
    local Args = {...}

    for i, Player in pairs(game.Players:GetPlayers()) do
        LogService.Client.ActionLog:Fire(Player, Color, table.unpack(Args))
    end
end



--[[ PUBLIC ]]--

--[=[
Get the name of the script which called a function in all caps.
]=]
function LogService:GetNameOfFunctionCaller(UpLevel :number) :string
    local FullNameOfCaller :string = debug.info(UpLevel, "s")
    local SplitNameCaller :{string} = FullNameOfCaller:split(".")

    local Name :string = SplitNameCaller[#SplitNameCaller]
    return Name:upper();
end

--[=[
Print out the message passed as well as anything else passed with a space between them
]=]
function LogService:Log(Message :string, ... :string)
    if not self.LoggingEnabled then return end
    local Extras = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    print(ScriptName, Message, table.unpack(Extras))
    SendLogToPlayers(Color3.fromRGB(255, 255, 255), ScriptName, Message, table.unpack(Extras))
end

--[=[
Print out the message passed as well as anything else passed with a space between them in orange
]=]
function LogService:Warn(Message :string, ... :string)
    if not self.WarningsEnabled then return end
    local Extras = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    warn(ScriptName, "[WARNING]", Message, table.unpack(Extras))
    SendLogToPlayers(Color3.fromRGB(255, 103, 0), ScriptName, "[WARNING]", Message, table.unpack(Extras))
end

--[=[
Print out the message passed as well as anything else passed with a space between them in blue.
Not recommended for use since roblox adds "test service: " before the mesage for some reason.
]=]
function LogService:Info(Message :string, ... :string)
    if not self.LoggingEnabled then return end
    local Extras :{string} = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    local FinalMessage = ScriptName.." [INFO] "..Message

    for _, ExtraString in pairs(Extras) do
        if type(ExtraString) == "string" then
            FinalMessage = FinalMessage.." "..ExtraString
        else
            FinalMessage = FinalMessage.." "..tostring(ExtraString)
        end
    end

    TestService:Message(FinalMessage)
end


--[=[
If the given value is nil or false it errors with a given error message.
]=]
function LogService:Assert(Value :any, ErrorMessage:string)
    if not self.AssertsEnabled then return end
    if Value == nil or Value == false then
        error("ASSERTION FAILED: "..ErrorMessage)
    end
end



-- [[ CLIENT ]]--

function LogService.Client:Log(Player :Player, Message :string, ... :string)
    if not LogService.WarningsEnabled then return end
    local Extras = {...}
    print("[CLIENT]", "["..Player.Name.."]", Message, table.unpack(Extras))
    SendLogToPlayers(Color3.fromRGB(255, 255, 255), "[CLIENT]", "["..Player.Name.."]", Message, table.unpack(Extras))
end

function LogService.Client:Warn(Player :Player, Message :string, ... :string)
    if not LogService.WarningsEnabled then return end
    local Extras = {...}
    warn("[CLIENT]", "["..Player.Name.."]", "[WARNING]", Message, table.unpack(Extras))
    SendLogToPlayers(Color3.fromRGB(255, 103, 0), "[CLIENT]", "["..Player.Name.."]", "[WARNING]", Message, table.unpack(Extras))
end

function LogService.Client:Info(Player :Player, Message :string, ... :string)
    self:Info("[CLIENT] "..Message, ...)
end

function LogService.Client:Assert(Player :Player, Value :string, ErrorMessage :string)
    if not self.AssertsEnabled then return end
    if Value == nil or Value == false then
        error("[CLIENT]", "["..Player.Name.."]".." ASSERTION FAILED: "..ErrorMessage)
    end
end

return LogService