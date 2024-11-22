local Queue = {}
Queue.__index = Queue

--[=[
Create a new queue object
]=]
function Queue.new()
    local self = setmetatable({}, Queue)
    self._Queue = {}
    self._Size = 0
    return self
end

--[=[
Clear the queue
]=]
function Queue:Clear()
    self._Size = 0
    self._Queue = {}
end

--[=[
Add something to the queue
]=]
function Queue:Enqueue(Object :any)
    table.insert(self._Queue, Object)
    self._Size += 1
end

--[=[
returns the object first in line
]=]
function Queue:Dequeue()
    if self:IsEmpty() then
        return nil
    end
    self._Size -= 1
    return table.remove(self._Queue, 1)
end

--[=[
return true/false if the queue is currently empty
]=]
function Queue:IsEmpty()
    return self._size == 0
end

--[=[
Destroy the queue object
]=]
function Queue:Destroy()
    self._Queue = nil
    self._Size = nil
    self = nil
end


return Queue
