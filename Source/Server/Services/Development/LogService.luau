local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LogService = Knit.CreateService({
	Name = "LogService",
	Client = {},
})

local LOG_SPACING = 40

--[[ PUBLIC ]]
--

--[=[
Get the name of the script which called a function in all caps.
]=]
function LogService:GetNameOfFunctionCaller(UpLevel: number): string
	local FullNameOfCaller: string = debug.info(UpLevel, "s")
	local SplitNameCaller: { string } = FullNameOfCaller:split(".")
	local Name: string = SplitNameCaller[#SplitNameCaller]

	local FinalString
	local LineText = tostring(debug.info(3, "l"))
	local Function = debug.info(UpLevel, "n")

	local FunctionLenth = #Function
	local MaxLength = 10

	if FunctionLenth >= MaxLength then
		Function = string.sub(Function, 1, MaxLength - 3)
		Function = Function .. "..."
	end

	FinalString = Function .. " - " .. Name .. ":" .. LineText

	return FinalString
end

--[=[
Print out the message passed as well as anything else passed with a space between them
]=]
function LogService:Log(Message: string, ...: string)
	if not _G.DEBUG then
		return
	end
	local Extras = { ... }
	local ScriptName = "[" .. self:GetNameOfFunctionCaller(3) .. "]"

	local SpacingToUse = LOG_SPACING - (#ScriptName + 5)
	print("[LOG]", ScriptName, string.rep(" ", SpacingToUse), Message, table.unpack(Extras))
end

--[=[
Print out the message passed as well as anything else passed with a space between them in orange
]=]
function LogService:Warn(Message: string, ...: string)
	if not _G.DEBUG then
		return
	end
	local Extras = { ... }
	local ScriptName = "[" .. self:GetNameOfFunctionCaller(3) .. "]"

	local SpacingToUse = LOG_SPACING - (#ScriptName + 9)
	warn("[WARNING]", ScriptName, string.rep(" ", SpacingToUse), Message, table.unpack(Extras))
end

--[=[
Stop execution and print the message + anything else passed in red
]=]
function LogService:Error(Message: string, ...: string)
	local ScriptName = "[" .. self:GetNameOfFunctionCaller(3) .. "]"

	local AssembledMessage = Message
	if ... ~= nil then
		for _, Item: string in pairs({ ... }) do
			AssembledMessage = AssembledMessage .. " " .. Item
		end
	end

	error(ScriptName .. " " .. AssembledMessage)
end

--[=[
If the given value is nil or false it errors with a given error message.
]=]
function LogService:Assert(Value: any, ErrorMessage: string)
	if not _G.DEBUG then
		return
	end
	if Value == nil or Value == false then
		error("ASSERTION FAILED: " .. ErrorMessage)
	end
end

-- [[ CLIENT ]]--

function LogService.Client:Log(Player: Player, Message: string, ...: string)
	if not _G.DEBUG then
		return
	end
	local Extras = { ... }

	local PlayerName = Player.Name
	local SpacingToUse = LOG_SPACING - (#PlayerName + 9)
	print("[CLIENT]", "[" .. PlayerName .. "]", string.rep(" ", SpacingToUse), Message, table.unpack(Extras))
end

function LogService.Client:Warn(Player: Player, Message: string, ...: string)
	if not _G.DEBUG then
		return
	end
	local Extras = { ... }

	local PlayerName = Player.Name
	local SpacingToUse = LOG_SPACING - (#PlayerName + 19)
	warn("[CLIENT] [WARNING]", "[" .. PlayerName .. "]", string.rep(" ", SpacingToUse), Message, table.unpack(Extras))
end

function LogService.Client:Error(_, Message: string, ...: string)
	local AssembledMessage = Message
	if ... ~= nil then
		for _, Item: string in pairs({ ... }) do
			AssembledMessage = AssembledMessage .. " " .. Item
		end
	end
	error("[CLIENT] " .. AssembledMessage)
end

function LogService.Client:Assert(Player: Player, Value: string, ErrorMessage: string)
	if not _G.DEBUG then
		return
	end
	if Value == nil or Value == false then
		error("[CLIENT]" .. " [" .. Player.Name .. "] " .. "ASSERTION FAILED: " .. ErrorMessage)
	end
end

return LogService
