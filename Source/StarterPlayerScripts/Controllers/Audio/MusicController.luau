local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local MusicController = Knit.CreateController { Name = "MusicController" }

local LogService
local AudioEngine

local ActiveSong
local HadSongs = false
local CurrentConfig = nil
local SongQueue = Core.Queue.new()



-- [[ PUBLIC ]] --

--[=[
Stops any active song playing
]=]
function MusicController:StopActiveMusic()
    if ActiveSong ~= nil then
        LogService:Log("Stopping active song")
        AudioEngine:StopSound(ActiveSong)
    end
end

--[=[
Clears the songs in the queue that are meant to be played
]=]
function MusicController:ClearQueue()
    LogService:Log("Clearing song queue")
    SongQueue:Clear()
end

--[=[
Plays the music for the given LayerConfig
]=]
function MusicController:PlayMusicForLayer(LayerConfig :Configuration)
    self:StopActiveMusic()
    self:ClearQueue()

    CurrentConfig = LayerConfig
    local MusicFolder = LayerConfig:FindFirstChild("Music")
    if not MusicFolder then
        HadSongs = false
        return
    end

    local Songs = Core.Util:RandomiseTable(MusicFolder:GetChildren())
    HadSongs = true

    for _, Song in pairs(Songs) do
        local Sound = AudioEngine:CreateFromSound(Song, false, nil)
        SongQueue:Enqueue(Sound)
    end

    self:PlayNextSong()
end

--[=[
Plays the next song; if no songs are in the queue and the config had songs then new queue is made
]=]
function MusicController:PlayNextSong()
    LogService:Log("Playing next song")
    if SongQueue:IsEmpty() then
        if HadSongs and CurrentConfig ~= nil then
            LogService:Log("Refreshing song queue; end of queue")
            self:PlayMusicForLayer(CurrentConfig)
        else
            return
        end
    end

    self:StopActiveMusic()
    local Song = SongQueue:Dequeue()

    Song.OnFinish = function()
        LogService:Log("Song finished")
        self:PlayNextSong()
    end;

    ActiveSong = AudioEngine:PlaySound(Song)
end



-- [[ KNIT ]] --

function MusicController:KnitStart()
    AudioEngine = Knit.GetController("AudioEngine")
    LogService = Knit.GetService("LogService")
end


return MusicController