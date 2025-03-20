local RunService = game:GetService("RunService")

local LogService = {}
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
	if not RunService:IsStudio() then
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
	if not RunService:IsStudio() then
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
	if not RunService:IsStudio() then
		return
	end
	if Value == nil or Value == false then
		error("ASSERTION FAILED: " .. ErrorMessage)
	end
end

return LogService
