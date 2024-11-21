local TestService = game:GetService("TestService")

local Knit = require(game.ReplicatedStorage.Packages.Knit)

local LogService = Knit.CreateService{
    Name = "LogService";
    Client = {};
}

LogService.LoggingEnabled = true
LogService.WarningsEnabled = true
LogService.AssertsEnabled = true

--[[ PUBLIC ]]--

--[=[
Get the name of the script which called a function in all caps.
]=]
function LogService:GetNameOfFunctionCaller(UpLevel :number) :string
    local FullNameOfCaller :string = debug.info(UpLevel, "s")
    local SplitNameCaller :{string} = FullNameOfCaller:split(".")
    local Name :string = SplitNameCaller[#SplitNameCaller]

    local FinalString
    local LineText = tostring(debug.info(3, "l"))
    local Function = debug.info(3, "n")
    FinalString = Function.." in "..Name:upper().." at "..LineText

    return FinalString;
end

--[=[
Print out the message passed as well as anything else passed with a space between them
]=]
function LogService:Log(Message :string, ... :string)
    if not self.LoggingEnabled then return end
    local Extras = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    print(ScriptName, Message, table.unpack(Extras))
end

--[=[
Print out the message passed as well as anything else passed with a space between them in orange
]=]
function LogService:Warn(Message :string, ... :string)
    if not self.WarningsEnabled then return end
    local Extras = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    warn(ScriptName, "[WARNING]", Message, table.unpack(Extras))
end

--[=[
Stop execution and print the message + anything else passed in red
]=]
function LogService:Error(Message :string, ... :string)
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"

    local AssembledMessage = Message
    if ... ~= nil then
        for _, Item :string in pairs({...}) do
            AssembledMessage = AssembledMessage.." "..Item
        end
    end

    error(ScriptName.." "..AssembledMessage)
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
end

function LogService.Client:Warn(Player :Player, Message :string, ... :string)
    if not LogService.WarningsEnabled then return end
    local Extras = {...}
    warn("[CLIENT]", "["..Player.Name.."]", "[WARNING]", Message, table.unpack(Extras))
end

function LogService.Client:Error(_, Message :string, ... :string)
    local AssembledMessage = Message
    if ... ~= nil then
        for _, Item :string in pairs({...}) do
            AssembledMessage = AssembledMessage.." "..Item
        end
    end
    error("[CLIENT] "..AssembledMessage)
end

function LogService.Client:Info(Player :Player, Message :string, ... :string)
    self:Info("[CLIENT]", "["..Player.Name.."]", Message, ...)
end

function LogService.Client:Assert(Player :Player, Value :string, ErrorMessage :string)
    if not self.AssertsEnabled then return end
    if Value == nil or Value == false then
        error("[CLIENT]".." ["..Player.Name.."] ".."ASSERTION FAILED: "..ErrorMessage)
    end
end

return LogService