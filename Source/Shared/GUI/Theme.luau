local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local AudioEngine = Knit.GetController("AudioEngine")

local Theme = {
	BackgroundColor = Color3.fromRGB(31, 31, 31),
	BackgroundColorRed = Color3.fromRGB(231, 96, 93),
	BackgroundColorGreen = Color3.fromRGB(93, 231, 137),
	BackgroundColorBlue = Color3.fromRGB(43, 142, 235),

	Font = Font.fromEnum(Enum.Font.Highway),
	TextColor = Color3.fromRGB(255, 255, 255),
	TextDisabledColor = Color3.fromRGB(127, 127, 127),
}

Theme.Images = {
	Missing = "http://www.roblox.com/asset/?id=925810526",

	-- Main Menu
	RandomizeButton = "rbxassetid://88848619964213",

	-- Loading screen
	LoadingWheel = "http://www.roblox.com/asset/?id=5221791428", -- TODO: Find a thinner one

	-- Forge
	Delay = "rbxassetid://128100976009074",
	Range = "rbxassetid://129170502469860",
	Power = "rbxassetid://88283392867459",

	-- Misc
	Gold = "rbxassetid://92870304618730",
	TycoonTeleportButton = "rbxassetid://83761770070710",
	SurfaceButton = "rbxassetid://119967532396729",
}

Theme.RawAudio = {
	ButtonHover = AudioEngine:CreateFromSound(ReplicatedStorage.Assets.UI.Audio.HoverSound, false),
	ButtonClick = AudioEngine:CreateFromSound(ReplicatedStorage.Assets.UI.Audio.ClickSound, false),
}

Theme.PlaySound = function(Sound, RandomPitch: boolean?, MinPitch: number?, MaxPitch: number?)
	if RandomPitch then
		Sound = AudioEngine:SetRandomPitch(Sound, MinPitch or 0.9, MaxPitch or 1.1)
	end

	return AudioEngine:PlaySound(Sound)
end

return Theme
