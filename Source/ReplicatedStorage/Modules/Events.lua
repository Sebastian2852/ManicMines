local Events = {}

export type Event = {
    OnEvent :RBXScriptSignal;
    Event :BindableEvent;
}

local function CreateEventTypeForEvent(RawEventObject :BindableEvent) :Event
    local NewEvent :Event = {
        Event = RawEventObject;
        OnEvent = RawEventObject.Event;
    }

    return NewEvent
end

local function CreateEvent(Name :string) :Event
    local BindableEvent = Instance.new("BindableEvent")
    BindableEvent.Name = Name
    BindableEvent.Parent = script

    return CreateEventTypeForEvent(BindableEvent)
end

Events.NewDataFolder = CreateEvent("NewDataFolder")


return Events