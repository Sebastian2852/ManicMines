local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Core = require(ReplicatedStorage.Game.Modules.Core)

local AudioEngine = Knit.CreateController { Name = "AudioEngine" }

local GLOBALSTORAGEFOLDER -- Used to hold sounds that are played globally
local POSITIONALSTORAGEFOLDER -- Used for sounds that play at a vector without a part

local Sounds = 0
AudioEngine.Sounds = {}

function AudioEngine:_ConstructObject(SoundObject :Core.Sound)
    local Location = GLOBALSTORAGEFOLDER
    local TopLevelParent
    local AudioID = Sounds + 1

    if SoundObject.Config.Positional then
        local Attachment = Instance.new("Attachment")
        Attachment.WorldCFrame = CFrame.new(Vector3.zero)
        Attachment.Name = `AE_{AudioID}_{SoundObject.SoundID}`

        if type(SoundObject.Config.PositionToPlay) == "vector" then
            local NewPart = Instance.new("MeshPart")
            NewPart.Size = Vector3.one
            NewPart.Name = `AE_{AudioID}_{SoundObject.SoundID}`
            NewPart.CFrame = CFrame.new(SoundObject.Config.PositionToPlay)
            NewPart.Anchored = true
            NewPart.CanCollide = false
            NewPart.Transparency = 1
            NewPart.Parent = POSITIONALSTORAGEFOLDER

            Attachment.Parent = NewPart
            TopLevelParent = NewPart
        else
            Attachment.Parent = SoundObject.Config.PositionToPlay
            TopLevelParent = Attachment
        end

        Location = Attachment
    end

    local Sound = Instance.new("Sound")
    Sound.Name = `AE_{AudioID}_{SoundObject.SoundID}`
    Sound.SoundId = SoundObject.SoundID
    Sound.Looped = SoundObject.Looped or false
    Sound.Volume = SoundObject.Config.Volume or 1
    Sound.PlaybackSpeed = SoundObject.Config.Speed or 1

    Sound.RollOffMode = SoundObject.Config.RollOffMode or Enum.RollOffMode.Inverse
    Sound.RollOffMinDistance = SoundObject.Config.RollOffDistanceBegin or 100
    Sound.RollOffMaxDistance = SoundObject.Config.RollOffMaxDistance or 120

    Sound.Ended:Connect(function()
        self:StopSound(AudioID)
    end)

    Sound.Parent = Location
    self.Sounds[AudioID] = Location

    if SoundObject.Config.Pitch ~= 1 and SoundObject.Config.Pitch ~= nil then
        local PitchShifter = Instance.new("PitchShiftSoundEffect")
        PitchShifter.Octave = SoundObject.Config.Pitch
        PitchShifter.Parent = Sound
    end

    return TopLevelParent, Sound, AudioID
end

function AudioEngine:_ConnectEvents(Sound :Sound, SoundObject :Core.Sound)
    if SoundObject.Looped and SoundObject.OnLoop then
        Sound.DidLoop:Connect(function(_, Times :number)
            SoundObject.OnLoop(Times)
        end)
    end

    if SoundObject.OnFinish then
        Sound.Ended:Connect(SoundObject.OnFinish)
    end
end

--[=[
Returns a blank sound type

ALL SETTINGS MUST BE SET, THEY DEFAULT TO NIL
]=]
function AudioEngine:CreateBlankSound() :Core.Sound
    return {
        ClassName = "SoundObjDef";
    }
end

--[=[
Returns a blank sound config type.

ALL SETTINGS MUST BE SET, THEY DEFAULT TO NIL
]=]
function AudioEngine:CreateBlankConfig() :Core.SoundConfig
    return {
        ClassName = "SoundObjConfig";
    }
end

--[=[
Play a sound!
returns the AudioEngine ID of the sound
]=]
function AudioEngine:PlaySound(SoundObject :Core.Sound) :number
    assert(SoundObject.ClassName == "SoundObjDef", "Invalid sound passed")
    assert(SoundObject.SoundID ~= nil, "Sound ID not set")
    assert(SoundObject.Config ~= nil, "Invalid sound config set")

    assert(type(SoundObject.Config) == "table", "Sound object config must be a table")
    assert(SoundObject.Config.ClassName == "SoundObjConfig", "Invalid sound config passed")

    local _, Sound, ID = self:_ConstructObject(SoundObject)
    self:_ConnectEvents(Sound, SoundObject)
    Sounds += 1

    Sound:Play()

    return ID
end

--[=[
Stops and deletes a sound.
Takes in the AudioEngine ID of the sound
]=]
function AudioEngine:StopSound(ID :number)
    assert(type(ID) == "number", "SoundID must be a sound")
    if self.Sounds[ID] == nil then return warn("No sound with that ID") end

    self.Sounds[ID]:Destroy()
end

function AudioEngine:KnitInit()
    GLOBALSTORAGEFOLDER = Instance.new("Folder")
    GLOBALSTORAGEFOLDER.Name = "AudioEngine"
    GLOBALSTORAGEFOLDER.Parent = SoundService

    POSITIONALSTORAGEFOLDER = Instance.new("Folder")
    POSITIONALSTORAGEFOLDER.Name = "AudioEngine"
    POSITIONALSTORAGEFOLDER.Parent = workspace
end

function AudioEngine:KnitStart()
    -- TESTING ------------------------------------------------------
    local TestConfig = self:CreateBlankConfig()
    TestConfig.Positional = true
    TestConfig.PositionToPlay = Vector3.new(0, 0, 0)
    TestConfig.Volume = 1

    local TestSound = self:CreateBlankSound()
    TestSound.SoundID = "rbxassetid://7098934716" -- Random sound off toolbox
    TestSound.Looped = false
    TestSound.Config = TestConfig

    TestSound.OnFinish = function()
        print("Finished")
    end

    TestSound.OnLoop = function(TimesLooped :number)
        print("Times looped:", TimesLooped)
    end

    --self:PlaySound(TestSound)
    TestSound.Config.Pitch = 2
    --self:PlaySound(TestSound)
    -----------------------------------------------------------------
end

return AudioEngine