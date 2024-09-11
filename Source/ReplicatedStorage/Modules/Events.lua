local Events = {}

local Event = require(game.ReplicatedStorage.Game.Modules.Objects.Event)

Events.NewDataFolder = Event.New("NewDataFolder")
Events.DataLoaded = Event.New("DataLoaded")


return Events