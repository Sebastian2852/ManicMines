local Timer = {}
Timer.__index = Timer

function Timer._new(Label: string)
	local self = setmetatable({}, Timer)

	self._TimeStarted = os.clock()
	self._Label = Label

	return self
end

--[=[
Create and start a new timer
]=]
function Timer.new(Label: string?)
	return Timer._new(Label or "___")
end

--[=[
Get how long the timer has been running for in seconds
]=]
function Timer:GetTime(): number
	local TimeNow = os.clock()
	return TimeNow - self._TimeStarted
end

function Timer:_Destroy()
	self._TimeStarted = nil
end

function Timer:_PrintTime()
	print("TIMER: '" .. tostring(self._Label) .. "' took " .. tostring(self:GetTime()) .. " seconds to execute")
end

--[=[
Destroy the timer object
]=]
function Timer:Destroy()
	self:_Destroy()
end

--[=[
Print out how long the timer has been running and destroy it
]=]
function Timer:Stop()
	self:_PrintTime()
	self:_Destroy()
end

return Timer
