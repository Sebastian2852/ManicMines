local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Core = require(ReplicatedStorage.Game.Modules.Core)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Logger = require(ReplicatedStorage.Game.Modules.Logger)

local MusicController = Knit.CreateController({ Name = "MusicController" })

local DataService
local AudioEngine
local SettingsService

local DataFolder
local ActiveSong
local HadSongs = false
local CurrentFolder = nil
local SongQueue = Core.Queue.new()
local UseSettingVolume = false

-- [[ PUBLIC ]] --

--[=[
Stops any active song playing
]=]
function MusicController:StopActiveMusic()
	if ActiveSong ~= nil then
		Logger:Log("Stopping active song")
		AudioEngine:StopSound(ActiveSong)
	end
end

--[=[
Clears the songs in the queue that are meant to be played
]=]
function MusicController:ClearQueue()
	Logger:Log("Clearing song queue")
	SongQueue:Clear()
end

--[=[
Takes a folder and plays all the songs in the queue
(does not stop or clear the music queue)
]=]
function MusicController:PlayMusicFromFolder(Folder: Folder, ApplySettingsVolume: boolean)
	local Songs = Core.Util:RandomiseTable(Folder:GetChildren())
	CurrentFolder = Folder
	HadSongs = true

	for _, Song in pairs(Songs) do
		local Sound = AudioEngine:CreateFromSound(Song, false, nil) :: Core.Sound
		Sound.Config.Volume = ApplySettingsVolume and DataFolder.Settings.MusicVolume.Value or 1
		SongQueue:Enqueue(Sound)
	end

	self:PlayNextSong()
end

--[=[
Plays the music for the given LayerConfig
]=]
function MusicController:PlayMusicForLayer(LayerConfig: Configuration)
	if not DataFolder then
		return
	end
	self:StopActiveMusic()
	self:ClearQueue()

	local MusicFolder = LayerConfig:FindFirstChild("Music")
	if not MusicFolder then
		HadSongs = false
		return
	end

	self:PlayMusicFromFolder(MusicFolder, true)
end

--[=[
Plays the next song; if no songs are in the queue and the config had songs then new queue is made
]=]
function MusicController:PlayNextSong()
	Logger:Log("Playing next song")
	if SongQueue:IsEmpty() then
		if HadSongs and CurrentFolder ~= nil then
			Logger:Log("Refreshing song queue; end of queue")
			self:PlayMusicFromFolder(CurrentFolder, UseSettingVolume)
		else
			return
		end
	end

	self:StopActiveMusic()
	local Song = SongQueue:Dequeue()
	if not Song then
		self:PlayMusicFromFolder(CurrentFolder, UseSettingVolume)
		return
	end

	Song.OnFinish = function()
		Logger:Log("Song finished")
		self:PlayNextSong(UseSettingVolume)
	end

	ActiveSong = AudioEngine:PlaySound(Song)
end

-- [[ KNIT ]] --

function MusicController:KnitStart()
	AudioEngine = Knit.GetController("AudioEngine")
	DataService = Knit.GetService("DataService")
	SettingsService = Knit.GetService("SettingsService")

	task.spawn(function()
		ReplicatedStorage.PlayerData:WaitForChild(Knit.Player.UserId)
		self:PlayMusicFromFolder(Core.Assets.Sounds.MainMenuMusic, false)
	end)

	DataService.DataLoaded:Connect(function(Data: Core.DataFolder)
		DataFolder = Data
		UseSettingVolume = true
		self:PlayMusicForLayer(Core.Assets.Layers:FindFirstChild("Surface"))
	end)

	SettingsService.SettingsChanged:Connect(function()
		Logger:Log("Settings updated, updating sound volume")
		UseSettingVolume = true

		if not ActiveSong then
			Logger:Warn("No active song")
			return
		end

		local CurrentSound = AudioEngine:GetSoundObject(ActiveSong) :: Sound
		if not CurrentSound then
			Logger:Warn("No current sound")
			return
		end

		CurrentSound.Volume = DataFolder.Settings.MusicVolume.Value
		Logger:Log("Updated volume of current song")
	end)
end

return MusicController
