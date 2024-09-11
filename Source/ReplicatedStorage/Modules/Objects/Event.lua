local Event = {}
Event.__index = Event

local EventsModule = script.Parent.Parent.Events

function Event.New(Name :string)
    local self = setmetatable({}, Event)

    if not EventsModule:FindFirstChild("Client") then
        local ClientFolder = Instance.new("Folder")
        ClientFolder.Name = "Client"
        ClientFolder.Parent = EventsModule
    end

    local BindableEvent = Instance.new("BindableEvent")
    BindableEvent.Name = Name
    BindableEvent.Parent = EventsModule

    local RemoteEvent = Instance.new("RemoteEvent")
    RemoteEvent.Name = Name
    RemoteEvent.Parent = EventsModule.Client

    self.BindableEvent = BindableEvent
    self.RemoteEvent = RemoteEvent

    self.OnBindableEvent = BindableEvent.Event

    return self
end

function Event:FireEventForClients(Clients :{Player}, ...)
    local Args = {...}
    for _, Client in pairs(Clients) do
        self.RemoteEvent:FireClient(Client, table.unpack(Args))
    end
end

function Event:FireEventForAllClients(...)
    local Args = {...}
    self.RemoteEvent:FireAllClients(table.unpack(Args))
    print("Fired")
end

function Event:FireEventForClient(Client :Player, ...)
    local Args = {...}
    self.RemoteEvent:FireClient(Client, table.unpack(Args))
end

function Event:FireEventForServer(...)
    local Args = {...}
    self.BindableEvent:Fire(table.unpack(Args))
end


return Event
