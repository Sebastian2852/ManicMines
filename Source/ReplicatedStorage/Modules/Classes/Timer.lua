local Timer = {}
Timer.__index = Timer

--[=[
Create a new timer
]=]
function Timer.new()
    local self = setmetatable({}, Timer)

    self.Running = false
    self.StartTime = -1
    self.ElapsedTime = 0

    return self
end


--[=[
Start the timer
]=]
function Timer:Start()
    self.Running = true
    self.StartTime = os.clock()
end

--[=[
Ends the timer and returns the time since the timer has started
]=]
function Timer:End() :number
    self.Running = false
    return os.clock() - self.StartTime
end

--[=[
Returns how long the timer has been running  
Accuracy - How many numbers after decemal point the resulting number should have
]=]
function Timer:GetTime(Accuracy :number) :number
    self.ElapsedTime = os.clock() - self.StartTime
    return tonumber(string.format("%."..(Accuracy).."f", self.ElapsedTime))
end

--[=[
returns if the timer is currently running
]=]
function Timer:IsRunning() :boolean
    return self.Running
end

--[=[
Delete the timer by clearing all properties
]=]
function Timer:Delete()
    self.ElapsedTime = nil
    self.StartTime = nil
    self.Running = nil
end

return Timer
