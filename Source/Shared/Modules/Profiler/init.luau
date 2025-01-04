local Profiler = {}

local Timer = require(script.Timer)

Profiler.Timer = Timer

--[=[
Calls the passed function with the args passed to `...` and returns the time it took to run
the function
]=]
function Profiler.TimeFunctionExecution(Function: (any) -> any, ...: any)
	local FunctionTimer = Timer.new()
	Function(...)
	local TimeTaken = FunctionTimer:GetTime()
	FunctionTimer:Destroy()
	return TimeTaken
end

return Profiler
