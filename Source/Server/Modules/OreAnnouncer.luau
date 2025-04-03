local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local URL =
	"https://discord.com/api/webhooks/1348327491739324426/rz87d8gY2BNltY7Uk9IJi2vxOVPfWA3jnB3thdc5ysuuOm6i07tmgbLD_QgdoCXZ3bjd"
local STUDIO_URL =
	"https://discord.com/api/webhooks/1356944078075592704/w9iRA6KvY2oU61t7PjRjcNFfteV-FRryjStNgxCbO6P7dzI0IoJTUfZf0e6PiM40U1rM"

local OreAnnouncer = {}

function OreAnnouncer:AnnounceOreMined(
	Player: Player,
	OreName: string,
	Depth: number,
	InCave: boolean,
	CaveName: string?
)
	local RealOre = ReplicatedStorage.Assets.Ores:FindFirstChild(OreName)
	local OreDisplayName = RealOre:GetAttribute("DisplayName")

	local EmblemID = RealOre:GetAttribute("EmblemImageID")
	local ID = EmblemID:sub(14)

	local CaveConfig = nil

	if InCave then
		CaveConfig = ReplicatedStorage.Assets.Caves.Random:FindFirstChild(CaveName)
	end

	local CaveSpawnRange = CaveConfig and CaveConfig:GetAttribute("DepthRange")
	local CaveSizeRange = CaveConfig and CaveConfig:GetAttribute("Size")

	-- https://roblox-proxy.sebstar2854.workers.dev/thumbnails/v1/users/avatar-headshot?size=48x48&format=png&userIds=3092257097

	local AvatarSuccess, AvatarRequest = pcall(HttpService.RequestAsync, HttpService, {
		Url = `https://roblox-proxy.sebstar2854.workers.dev/thumbnails/v1/users/avatar-headshot?size=48x48&format=png&userIds={Player.UserId}`,
		Method = "GET",
	})

	local Success, Request = pcall(HttpService.RequestAsync, HttpService, {
		Url = `https://roblox-proxy.sebstar2854.workers.dev/thumbnails/v1/assets?assetIds={ID}&returnPolicy=PlaceHolder&size=420x420&format=png`,
		Method = "GET",
	})

	local ImageURL = ""
	if Success then
		local DecodeSuccess, Body = pcall(HttpService.JSONDecode, HttpService, Request.Body)
		if DecodeSuccess then
			if Body.errors then
				warn(Body.errors)
			else
				ImageURL = Body.data[1].imageUrl
			end
		else
			warn(Body)
		end
	end

	local AvatarURL = ""
	if AvatarSuccess then
		local DecodeSuccess, Body = pcall(HttpService.JSONDecode, HttpService, AvatarRequest.Body)
		if DecodeSuccess then
			if Body.errors then
				warn(Body.errors)
			else
				AvatarURL = Body.data[1].imageUrl
			end
		else
			warn(Body)
		end
	end

	local Fields = {
		{
			["name"] = "ERROR",
			["value"] = "Error getting cave/ore data",
			["inline"] = false,
		},
	}

	if CaveConfig then
		Fields = {
			{
				["name"] = OreDisplayName,
				["value"] = RealOre:GetAttribute("OreIndexDescription") or "",
				["inline"] = true,
			},
			{
				["name"] = CaveName,
				["value"] = `{CaveName} is a cave which has a rarity of 1 in {CaveConfig:GetAttribute("Rarity")} and spawns between the depths of {CaveSpawnRange.Min}m - {CaveSpawnRange.Max}m and can be between {CaveSizeRange.Min} blocks - {CaveSizeRange.Max} blocks wide!`,
				["inline"] = true,
			},
		}
	else
		Fields = {
			{
				["name"] = OreDisplayName,
				["value"] = RealOre:GetAttribute("OreIndexDescription") or "",
				["inline"] = true,
			},
		}
	end

	local Rarity = RealOre:GetAttribute("Rarity")

	local Message = {
		["username"] = "Ore Announcer",
		["avatar_url"] = "https://static.wikia.nocookie.net/manic-mines/images/d/d1/ManicMinesLogo.png/revision/latest?cb=20250309161803",
		["embeds"] = {
			{
				["color"] = tonumber(RealOre:GetAttribute("SelectionColor"):ToHex(), 16),
				["title"] = `{Player.DisplayName} mined {OreDisplayName}`,
				["author"] = {
					["name"] = `{Player.DisplayName} (@{Player.Name})`,
					["url"] = `https://www.roblox.com/users/{Player.UserId}/profile`,
					["icon_url"] = AvatarURL,
				},
				["thumbnail"] = Success and {
					["url"] = ImageURL,
				},
				["description"] = `{Player.DisplayName} mined {OreDisplayName} at a depth of {Depth}m which means it had a rarity of 1 in {Rarity}{InCave and ` it was found inside of a {CaveName} cave.` or "."}`,
				["fields"] = Fields,
			},
		},
	}

	HttpService:PostAsync(
		RunService:IsStudio() and STUDIO_URL or URL,
		HttpService:JSONEncode(Message),
		Enum.HttpContentType.ApplicationJson
	)
end

return OreAnnouncer
