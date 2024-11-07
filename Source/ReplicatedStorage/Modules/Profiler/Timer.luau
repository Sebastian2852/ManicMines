local Timer = {}
Timer.__index = Timer

function Timer._new(Label :string)
    local self = setmetatable({}, Timer)
    self._TimeStarted = os.clock()
    self._Label = Label
    return self
end

function Timer.new()
    return Timer._new("___")
end

function Timer.new(Label :string)
    return Timer._new(Label)
end


function Timer:GetTime()
    local TimeNow = os.clock()
    return TimeNow - self._TimeStarted
end

function Timer:_Destroy()
    self._TimeStarted = nil
end

function Timer:_PrintTime()
    print("TIMER: '"..tostring(self._Label).."' took "..tostring(self:GetTime()).." seconds to execute")
end

function Timer:Destroy()
    self:_Destroy()
end

function Timer:Stop()
    self:_PrintTime()
    self:_Destroy()
end


return Timer
