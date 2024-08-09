local Knit = require(game.ReplicatedStorage.Packages.Knit)

--[[
Log service is like a custom logger, I have done it like this so that we can disable
logging. Also it allows to only have logging for certain scripts and stuff.

There are no errors since there is no reason they shold be disabled/enabled at runtime
they should always just be enabled.
]]--
local LogService = Knit.CreateService{
    Name = "LogService";
    Client = {};
}

local TestService = game:GetService("TestService")

LogService.WarningsEnabled = true
LogService.LoggingEnabled = true
LogService.AssertsEnabled = true

--[[
Get the name of the script which called a function in all caps.
]]--
function LogService:GetNameOfFunctionCaller(UpLevel :number) :string
    local FullNameOfCaller :string = debug.info(UpLevel, "s")
    local SplitNameCaller :{string} = FullNameOfCaller:split(".")

    local Name :string = SplitNameCaller[#SplitNameCaller]
    return Name:upper();
end

--[[
Print out the message passed as well as anything else passed with a space between them in orange
]]--
function LogService:Warn(Message :string, ... :string)
    if not self.WarningsEnabled then return end
    local Extras = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    warn(ScriptName, "[WARNING]", Message, table.unpack(Extras))
end

--[[
Print out the message passed as well as anything else passed with a space between them
]]--
function LogService:Log(Message :string, ... :string)
    if not self.LoggingEnabled then return end
    local Extras = {...}
    local ScriptName = "["..self:GetNameOfFunctionCaller(3).."]"
    print(ScriptName, Message, table.unpack(Extras))
end

--[[
Print out the message passed as well as anything else passed with a space between them in blue.
Not recommended for use since roblox adds "test service: " before the mesage for some reason.
]]--
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

--[[
If the given value is nil or false it errors with a given error message.
]]--
function LogService:Assert(Value :any, ErrorMessage:string)
    if not self.AssertsEnabled then return end
    if Value == nil or Value == false then
        error("ASSERTION FAILED: "..ErrorMessage)
    end
end

return LogService