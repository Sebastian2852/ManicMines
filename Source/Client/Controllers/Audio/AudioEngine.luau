local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)

local DebugFolder = ReplicatedStorage.Player.Debug

local AudioEngine = Knit.CreateController({ Name = "AudioEngine" })

local GLOBALSTORAGEFOLDER -- Used to hold sounds that are played globally
local POSITIONALSTORAGEFOLDER -- Used for sounds that play at a vector without a part

local Sounds = 0
AudioEngine.Sounds = {}
AudioEngine.Objects = {}

function AudioEngine:_ConstructObject(SoundObject: Core.Sound)
	local Location = GLOBALSTORAGEFOLDER
	local TopLevelParent
	Sounds += 1
	local AudioID = Sounds

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

	Sound.Parent = Location
	if Location == GLOBALSTORAGEFOLDER then
		DebugFolder.Audio.ActiveGlobalSounds.Value += 1
		self.Sounds[AudioID] = Sound
	else
		DebugFolder.Audio.ActivePositionalSounds.Value += 1
		self.Sounds[AudioID] = TopLevelParent
	end

	Sound.Ended:Connect(function()
		self:StopSound(AudioID)
	end)

	if SoundObject.Config.Pitch ~= 1 and SoundObject.Config.Pitch ~= nil then
		local PitchShifter = Instance.new("PitchShiftSoundEffect")
		PitchShifter.Octave = SoundObject.Config.Pitch
		PitchShifter.Parent = Sound
	end

	return TopLevelParent, Sound, AudioID
end

function AudioEngine:_ConnectEvents(Sound: Sound, SoundObject: Core.Sound)
	if SoundObject.Looped and SoundObject.OnLoop then
		Sound.DidLoop:Connect(function(_, Times: number)
			SoundObject.OnLoop(Times)
		end)
	end

	if SoundObject.OnFinish then
		Sound.Ended:Connect(SoundObject.OnFinish)
	end

	Sound.Destroying:Connect(function()
		if SoundObject.Config.Positional then
			DebugFolder.Audio.ActivePositionalSounds.Value -= 1
		else
			DebugFolder.Audio.ActiveGlobalSounds.Value -= 1
		end
	end)
end

--[=[
Returns a blank sound type

ALL SETTINGS MUST BE SET, THEY DEFAULT TO NIL
]=]
function AudioEngine:CreateBlankSound(): Core.Sound
	return {
		ClassName = "SoundObjDef",
	}
end

--[=[
Returns a blank sound config type.

ALL SETTINGS MUST BE SET, THEY DEFAULT TO NIL
]=]
function AudioEngine:CreateBlankConfig(): Core.SoundConfig
	return {
		ClassName = "SoundObjConfig",
	}
end

--[=[
Returns a sound type to use for playsound
Note: This function doesnt change anything about the sound passed
]=]
function AudioEngine:CreateFromSound(Sound: Sound, Positional: boolean?, PositionToPlay: Vector3 | BasePart | nil)
	local NewSound = self:CreateBlankSound()
	NewSound.SoundID = Sound.SoundId

	local SoundConfig = self:CreateBlankConfig()
	SoundConfig.Looped = Sound.Looped
	SoundConfig.Positional = Positional or false
	SoundConfig.PositionToPlay = PositionToPlay
	SoundConfig.Speed = Sound.PlaybackSpeed
	SoundConfig.Pitch = 1

	if Sound:FindFirstChildWhichIsA("PitchShiftSoundEffect") then
		SoundConfig.Pitch = Sound:FindFirstChildWhichIsA("PitchShiftSoundEffect").Octave
	end

	NewSound.Config = SoundConfig

	return NewSound
end

--[=[
Sets the pitch of the given sound to a ranom value between Min and Max
]=]
function AudioEngine:SetRandomPitch(Sound: Core.Sound, Min: number, Max: number)
	local NumberGenerator = Random.new()
	local Pitch = NumberGenerator:NextNumber(Min, Max)
	Sound.Config.Pitch = Pitch
	return Sound
end

--[=[
Play a sound!
returns the AudioEngine ID of the sound
]=]
function AudioEngine:PlaySound(SoundObject: Core.Sound): number
	assert(SoundObject.ClassName == "SoundObjDef", "Invalid sound passed")
	assert(SoundObject.SoundID ~= nil, "Sound ID not set")
	assert(SoundObject.Config ~= nil, "Invalid sound config set")

	assert(type(SoundObject.Config) == "table", "Sound object config must be a table")
	assert(SoundObject.Config.ClassName == "SoundObjConfig", "Invalid sound config passed")

	local _, Sound, ID = self:_ConstructObject(SoundObject)
	self:_ConnectEvents(Sound, SoundObject)

	Sound:Play()
	self.Objects[ID] = Sound

	DebugFolder.Audio.TotalSoundsMade.Value = Sounds
	DebugFolder.Audio.ActiveSounds.Value += 1

	return ID
end

--[=[
Get the sound object of the given ID
]=]
function AudioEngine:GetSoundObject(ID: number): Sound
	assert(type(ID) == "number", "SoundID must be a sound")
	if self.Objects[ID] == nil then
		return warn("No sound with ID: " .. tostring(ID))
	end
	return self.Objects[ID]
end

--[=[
Stops and deletes a sound.
Takes in the AudioEngine ID of the sound
]=]
function AudioEngine:StopSound(ID: number)
	assert(type(ID) == "number", "SoundID must be a sound")
	if self.Sounds[ID] == nil then
		return warn("No sound with ID: " .. tostring(ID))
	end

	Debris:AddItem(self.Sounds[ID], 1)
	self.Objects[ID] = nil
	DebugFolder.Audio.ActiveSounds.Value -= 1
end

function AudioEngine:KnitInit()
	GLOBALSTORAGEFOLDER = Instance.new("Folder")
	GLOBALSTORAGEFOLDER.Name = "AudioEngine"
	GLOBALSTORAGEFOLDER.Parent = SoundService

	POSITIONALSTORAGEFOLDER = Instance.new("Folder")
	POSITIONALSTORAGEFOLDER.Name = "AudioEngine"
	POSITIONALSTORAGEFOLDER.Parent = workspace
end

return AudioEngine
