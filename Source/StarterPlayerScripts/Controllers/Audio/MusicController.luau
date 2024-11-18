local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local MusicController = Knit.CreateController { Name = "MusicController" }

local AudioEngine
local ActiveSong

-- [[ PUBLIC ]] --

--[=[
Stops any active song playing
]=]
function MusicController:StopActiveMusic()
    if ActiveSong ~= nil then
        AudioEngine:StopSound(ActiveSong)
    end
end

--[=[
Plays the music for the given LayerConfig
]=]
function MusicController:PlayMusicForLayer(LayerConfig :Configuration)
    self:StopActiveMusic()

    local MusicFolder = LayerConfig:FindFirstChild("Music")
    if not MusicFolder then return end

    local Songs = MusicFolder:GetChildren() :: {Sound}
    local Song = Songs[math.random(1, #Songs)]

    local Sound = AudioEngine:CreateFromSound(Song)
    ActiveSong = AudioEngine:PlaySound(Sound)
end



-- [[ KNIT ]] --

function MusicController:KnitStart()
    AudioEngine = Knit.GetController("AudioEngine")
end


return MusicController